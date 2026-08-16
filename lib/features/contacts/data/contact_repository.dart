import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/contact.dart';

class ContactRepository {
  final SupabaseClient? _supabase;
  final List<Contact> _inMemoryContacts = [];

  ContactRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<Contact>> getContacts({String? role}) async {
    final c = client;
    if (c == null) {
      if (role != null && role.isNotEmpty && role != 'all') {
        return _inMemoryContacts.where((item) => item.role.toLowerCase() == role.toLowerCase()).toList();
      }
      return List.unmodifiable(_inMemoryContacts);
    }
    try {
      var query = c.from('contacts').select();
      if (role != null && role.isNotEmpty && role != 'all') {
        query = query.eq('role', role);
      }
      final data = await query.order('name', ascending: true);
      final list = (data as List).map((json) => Contact.fromMap(json)).toList();
      return list;
    } catch (e) {
      debugPrint('Supabase getContacts error: $e');
      if (role != null && role.isNotEmpty && role != 'all') {
        return _inMemoryContacts.where((item) => item.role.toLowerCase() == role.toLowerCase()).toList();
      }
      return List.unmodifiable(_inMemoryContacts);
    }
  }

  Future<Contact?> getContactById(String id) async {
    final c = client;
    if (c == null) {
      try {
        return _inMemoryContacts.firstWhere((item) => item.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c.from('contacts').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Contact.fromMap(data);
    } catch (e) {
      debugPrint('Supabase getContactById error: $e');
      return null;
    }
  }

  Future<Contact> saveContact(Contact contact) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(contact.accountId) ? contact.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(contact.id) ? contact.id : AppUuid.generate();
    final toSave = contact.copyWith(id: validId, accountId: accountId);

    if (c == null) {
      final index = _inMemoryContacts.indexWhere((item) => item.id == toSave.id);
      if (index >= 0) {
        _inMemoryContacts[index] = toSave;
      } else {
        _inMemoryContacts.insert(0, toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('contacts').upsert(toSave.toMap()).select().single();
      final saved = Contact.fromMap(data);
      final index = _inMemoryContacts.indexWhere((item) => item.id == saved.id);
      if (index >= 0) {
        _inMemoryContacts[index] = saved;
      } else {
        _inMemoryContacts.insert(0, saved);
      }
      return saved;
    } catch (e) {
      debugPrint('Supabase saveContact error: $e');
      final index = _inMemoryContacts.indexWhere((item) => item.id == toSave.id);
      if (index >= 0) {
        _inMemoryContacts[index] = toSave;
      } else {
        _inMemoryContacts.insert(0, toSave);
      }
      return toSave;
    }
  }

  Future<void> deleteContact(String id) async {
    final c = client;
    _inMemoryContacts.removeWhere((item) => item.id == id);
    if (c != null) {
      try {
        await c.from('contacts').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteContact error: $e');
      }
    }
  }
}
