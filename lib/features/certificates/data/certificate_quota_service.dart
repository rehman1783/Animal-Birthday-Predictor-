import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Certificate Quota Model representing the user's entitlement state
class CertificateQuota {
  final int totalAllocated;
  final int usedCount;
  final int remaining;
  final bool isLoading;

  const CertificateQuota({
    required this.totalAllocated,
    required this.usedCount,
    required this.remaining,
    this.isLoading = false,
  });

  CertificateQuota copyWith({
    int? totalAllocated,
    int? usedCount,
    int? remaining,
    bool? isLoading,
  }) {
    return CertificateQuota(
      totalAllocated: totalAllocated ?? this.totalAllocated,
      usedCount: usedCount ?? this.usedCount,
      remaining: remaining ?? this.remaining,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory CertificateQuota.initial() {
    return const CertificateQuota(
      totalAllocated: 5,
      usedCount: 0,
      remaining: 5,
      isLoading: true,
    );
  }
}

/// Service handling certificate usage control, quota enforcement, and purchase credits
class CertificateQuotaService {
  final SupabaseClient? _client;

  CertificateQuotaService({SupabaseClient? client}) : _client = client;

  SupabaseClient get _supabase {
    final client = _client;
    if (client != null) return client;
    return Supabase.instance.client;
  }

  static const String _prefTotalKey = 'abp_cert_quota_total';
  static const String _prefUsedKey = 'abp_cert_quota_used';
  static const String _prefIssuedPrefix = 'abp_cert_issued_';

  /// Fetch the current user's quota from Supabase (with SharedPreferences offline cache fallback)
  Future<CertificateQuota> fetchQuota() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTotal = prefs.getInt(_prefTotalKey) ?? 5;
    final cachedUsed = prefs.getInt(_prefUsedKey) ?? 0;
    final cachedRemaining = (cachedTotal - cachedUsed).clamp(0, 999999);

    final user = _supabase.auth.currentUser;
    if (user == null) {
      return CertificateQuota(
        totalAllocated: cachedTotal,
        usedCount: cachedUsed,
        remaining: cachedRemaining,
        isLoading: false,
      );
    }

    try {
      final res = await _supabase
          .from('certificate_entitlements')
          .select('total_allocated, used_count')
          .eq('user_id', user.id)
          .maybeSingle();

      if (res != null) {
        final total = (res['total_allocated'] as num?)?.toInt() ?? 5;
        final used = (res['used_count'] as num?)?.toInt() ?? 0;
        final remaining = (total - used).clamp(0, 999999);

        // Cache locally
        await prefs.setInt(_prefTotalKey, total);
        await prefs.setInt(_prefUsedKey, used);

        return CertificateQuota(
          totalAllocated: total,
          usedCount: used,
          remaining: remaining,
          isLoading: false,
        );
      } else {
        // Initialize entitlement row in Supabase
        await _supabase.from('certificate_entitlements').insert({
          'user_id': user.id,
          'total_allocated': 5,
          'used_count': 0,
        });
        return const CertificateQuota(
          totalAllocated: 5,
          usedCount: 0,
          remaining: 5,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Certificate quota fetch fallback: $e');
      return CertificateQuota(
        totalAllocated: cachedTotal,
        usedCount: cachedUsed,
        remaining: cachedRemaining,
        isLoading: false,
      );
    }
  }

  /// Check if a certificate for this specific target has already been generated
  Future<bool> isCertificateAlreadyIssued(String targetId) async {
    final cleanId = targetId.trim();
    if (cleanId.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final isLocallyIssued = prefs.getBool('$_prefIssuedPrefix$cleanId') ?? false;
    if (isLocallyIssued) return true;

    final user = _supabase.auth.currentUser;
    if (user == null) return isLocallyIssued;

    try {
      final res = await _supabase
          .from('generated_certificates')
          .select('id')
          .eq('user_id', user.id)
          .eq('target_id', cleanId)
          .maybeSingle();
      if (res != null) {
        await prefs.setBool('$_prefIssuedPrefix$cleanId', true);
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// Consume 1 credit to issue a new certificate.
  /// Returns updated quota if successful, or throws Exception if quota exceeded.
  Future<CertificateQuota> consumeCredit({
    required String targetId,
    required String certType,
    required String certId,
    String targetName = '',
  }) async {
    final cleanTargetId = targetId.trim();

    // Check if already issued
    final alreadyIssued = await isCertificateAlreadyIssued(cleanTargetId);
    if (alreadyIssued) {
      debugPrint('Certificate already issued for $cleanTargetId. No credit deducted.');
      return fetchQuota();
    }

    final currentQuota = await fetchQuota();
    if (currentQuota.remaining <= 0) {
      throw Exception('Certificate quota reached. Additional certificates required.');
    }

    final user = _supabase.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      try {
        final rpcRes = await _supabase.rpc('consume_certificate_credit', params: {
          'cert_id_param': certId,
          'cert_type_param': certType,
          'target_id_param': cleanTargetId,
          'target_name_param': targetName,
        });

        if (rpcRes is Map && rpcRes['success'] == false) {
          throw Exception(rpcRes['error']?.toString() ?? 'Failed to consume credit.');
        }
      } catch (e) {
        debugPrint('Supabase consume_certificate_credit notice: $e');
        // Fallback: update directly
        try {
          await _supabase.from('generated_certificates').insert({
            'user_id': user.id,
            'certificate_id': certId,
            'certificate_type': certType,
            'target_id': cleanTargetId,
            'target_name': targetName,
          });
          await _supabase.from('certificate_entitlements').upsert({
            'user_id': user.id,
            'total_allocated': currentQuota.totalAllocated,
            'used_count': currentQuota.usedCount + 1,
          });
        } catch (_) {}
      }
    }

    // Mark issued locally
    await prefs.setBool('$_prefIssuedPrefix$cleanTargetId', true);
    final newUsed = currentQuota.usedCount + 1;
    await prefs.setInt(_prefUsedKey, newUsed);

    return CertificateQuota(
      totalAllocated: currentQuota.totalAllocated,
      usedCount: newUsed,
      remaining: (currentQuota.totalAllocated - newUsed).clamp(0, 999999),
      isLoading: false,
    );
  }

  /// Add additional certificate credits (e.g. after in-app purchase or admin grant)
  Future<CertificateQuota> addCredits(int creditsToAdd) async {
    final current = await fetchQuota();
    final newTotal = current.totalAllocated + creditsToAdd;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTotalKey, newTotal);

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('certificate_entitlements').upsert({
          'user_id': user.id,
          'total_allocated': newTotal,
          'used_count': current.usedCount,
        });
      } catch (e) {
        debugPrint('Supabase add credits error: $e');
      }
    }

    return CertificateQuota(
      totalAllocated: newTotal,
      usedCount: current.usedCount,
      remaining: (newTotal - current.usedCount).clamp(0, 999999),
      isLoading: false,
    );
  }
}

/// StateNotifier for Certificate Quota Provider
class CertificateQuotaNotifier extends StateNotifier<CertificateQuota> {
  final CertificateQuotaService _service;

  CertificateQuotaNotifier(this._service) : super(CertificateQuota.initial()) {
    refreshQuota();
  }

  Future<void> refreshQuota() async {
    final q = await _service.fetchQuota();
    state = q;
  }

  Future<bool> checkIsAlreadyIssued(String targetId) async {
    return _service.isCertificateAlreadyIssued(targetId);
  }

  Future<void> consumeCredit({
    required String targetId,
    required String certType,
    required String certId,
    String targetName = '',
  }) async {
    final updated = await _service.consumeCredit(
      targetId: targetId,
      certType: certType,
      certId: certId,
      targetName: targetName,
    );
    state = updated;
  }

  Future<void> purchaseCertificateCredits(int count) async {
    final updated = await _service.addCredits(count);
    state = updated;
  }
}

final certificateQuotaServiceProvider = Provider<CertificateQuotaService>((ref) {
  return CertificateQuotaService();
});

final certificateQuotaProvider =
    StateNotifierProvider<CertificateQuotaNotifier, CertificateQuota>((ref) {
  final service = ref.watch(certificateQuotaServiceProvider);
  return CertificateQuotaNotifier(service);
});
