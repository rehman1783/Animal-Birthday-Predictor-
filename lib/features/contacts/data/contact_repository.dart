import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/contact.dart';

class ContactRepository {
  final SupabaseClient? _supabase;
  final List<Contact> _mockContacts = [];

  ContactRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<Contact>> getContacts({String? role}) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        var query = c.from('contacts').select().eq('account_id', user.id);
        if (role != null && role.isNotEmpty && role != 'all') {
          query = query.eq('role', role);
        }
        final data = await query.order('name', ascending: true);
        if (data is List) {
          return data.map((json) => Contact.fromMap(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getContacts error: $e');
        rethrow;
      }
    }

    if (role != null && role.isNotEmpty && role != 'all') {
      return _mockContacts.where((item) => item.role.toLowerCase() == role.toLowerCase()).toList();
    }
    return List.unmodifiable(_mockContacts);
  }

  Future<Contact?> getContactById(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c.from('contacts').select().eq('account_id', user.id).eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          return Contact.fromMap(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getContactById error: $e');
        rethrow;
      }
    }

    try {
      return _mockContacts.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Contact> saveContact(Contact contact) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(contact.accountId) ? contact.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(contact.id) ? contact.id : AppUuid.generate();
    final toSave = contact.copyWith(id: validId, accountId: accountId);

    if (c != null && user != null) {
      try {
        final data = await c.from('contacts').upsert(toSave.toMap()).select();
        if (data is List && data.isNotEmpty) {
          return Contact.fromMap(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveContact error: $e');
        rethrow;
      }
    }

    final idx = _mockContacts.indexWhere((item) => item.id == toSave.id);
    if (idx >= 0) {
      _mockContacts[idx] = toSave;
    } else {
      _mockContacts.insert(0, toSave);
    }
    return toSave;
  }

  Future<void> deleteContact(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        await c.from('contacts').delete().eq('account_id', user.id).eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteContact error: $e');
        rethrow;
      }
    }
    _mockContacts.removeWhere((item) => item.id == id);
  }
}
