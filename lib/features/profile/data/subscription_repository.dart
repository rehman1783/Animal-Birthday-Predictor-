import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSubscriptionModel {
  final String userId;
  final String planTier;
  final String status;
  final String billingCycle;
  final double pricePaid;
  final int maxAnimalQuota;
  final DateTime? expiresAt;
  final bool autoRenew;

  UserSubscriptionModel({
    required this.userId,
    required this.planTier,
    required this.status,
    required this.billingCycle,
    required this.pricePaid,
    required this.maxAnimalQuota,
    this.expiresAt,
    required this.autoRenew,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      userId: json['user_id'] ?? '',
      planTier: json['plan_tier'] ?? 'Free',
      status: json['status'] ?? 'active',
      billingCycle: json['billing_cycle'] ?? 'monthly',
      pricePaid: (json['price_paid'] ?? 0.0).toDouble(),
      maxAnimalQuota: json['max_animal_quota'] ?? 1,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      autoRenew: json['auto_renew'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'plan_tier': planTier,
      'status': status,
      'billing_cycle': billingCycle,
      'price_paid': pricePaid,
      'max_animal_quota': maxAnimalQuota,
      'expires_at': expiresAt?.toIso8601String(),
      'auto_renew': autoRenew,
    };
  }
}

class SubscriptionRepository {
  final SupabaseClient _supabase;

  SubscriptionRepository(this._supabase);

  /// Fetch user active subscription from Supabase DB
  Future<UserSubscriptionModel?> getUserSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return UserSubscriptionModel.fromJson(response);
      }

      // If no subscription row exists yet, initialize default Free tier
      final defaultSub = {
        'user_id': userId,
        'plan_tier': 'Free',
        'status': 'active',
        'billing_cycle': 'monthly',
        'price_paid': 0.00,
        'max_animal_quota': 1,
        'auto_renew': true,
      };

      await _supabase.from('user_subscriptions').insert(defaultSub);
      return UserSubscriptionModel.fromJson(defaultSub);
    } catch (e) {
      return null;
    }
  }

  /// Upgrade / change user subscription plan tier
  Future<bool> updateUserPlanTier({
    required String userId,
    required String newTier,
    required int maxQuota,
    required double pricePaid,
    required String billingCycle,
  }) async {
    try {
      final DateTime newExpiry = billingCycle == 'annual'
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 30));

      await _supabase.from('user_subscriptions').upsert({
        'user_id': userId,
        'plan_tier': newTier,
        'status': 'active',
        'billing_cycle': billingCycle,
        'price_paid': pricePaid,
        'max_animal_quota': maxQuota,
        'expires_at': newExpiry.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(Supabase.instance.client);
});
