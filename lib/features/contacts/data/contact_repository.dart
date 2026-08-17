import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/contact.dart';

class ContactRepository {
  static const String _storageKey = 'abp_cached_contacts_records';
  final SupabaseClient? _supabase;
  final List<Contact> _inMemoryContacts = [];
  bool _hasLoadedFromStorage = false;

  ContactRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client) {
    _initLocalStorage();
  }

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> _initLocalStorage() async {
    if (_hasLoadedFromStorage) return;
    _hasLoadedFromStorage = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey);
      if (list != null && list.isNotEmpty) {
        for (final item in list) {
          try {
            final json = jsonDecode(item) as Map<String, dynamic>;
            final contact = Contact.fromMap(json);
            if (!_inMemoryContacts.any((c) => c.id == contact.id)) {
              _inMemoryContacts.add(contact);
            }
          } catch (e) {
            debugPrint('Error decoding contact cache: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('ContactRepository: error reading local cache: $e');
    }
  }

  Future<void> _persistToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryContacts.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (e) {
      debugPrint('ContactRepository: error persisting to local cache: $e');
    }
  }

  Future<List<Contact>> getContacts({String? role}) async {
    await _initLocalStorage();
    final c = client;
    if (c != null) {
      try {
        var query = c.from('contacts').select();
        if (role != null && role.isNotEmpty && role != 'all') {
          query = query.eq('role', role);
        }
        final data = await query.order('name', ascending: true);
        if (data is List) {
          final list = data.map((json) => Contact.fromMap(json as Map<String, dynamic>)).toList();
          for (final contact in list) {
            final idx = _inMemoryContacts.indexWhere((x) => x.id == contact.id);
            if (idx >= 0) {
              _inMemoryContacts[idx] = contact;
            } else {
              _inMemoryContacts.add(contact);
            }
          }
          await _persistToLocalStorage();
          return list;
        }
      } catch (e) {
        debugPrint('Supabase getContacts error: $e');
      }
    }

    if (role != null && role.isNotEmpty && role != 'all') {
      return _inMemoryContacts.where((item) => item.role.toLowerCase() == role.toLowerCase()).toList();
    }
    return List.unmodifiable(_inMemoryContacts);
  }

  Future<Contact?> getContactById(String id) async {
    await _initLocalStorage();
    final c = client;
    if (c != null) {
      try {
        final data = await c.from('contacts').select().eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          final saved = Contact.fromMap(data.first as Map<String, dynamic>);
          final idx = _inMemoryContacts.indexWhere((x) => x.id == saved.id);
          if (idx >= 0) {
            _inMemoryContacts[idx] = saved;
          } else {
            _inMemoryContacts.add(saved);
          }
          await _persistToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase getContactById error: $e');
      }
    }

    try {
      return _inMemoryContacts.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Contact> saveContact(Contact contact) async {
    await _initLocalStorage();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(contact.accountId) ? contact.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(contact.id) ? contact.id : AppUuid.generate();
    final toSave = contact.copyWith(id: validId, accountId: accountId);

    final index = _inMemoryContacts.indexWhere((item) => item.id == toSave.id);
    if (index >= 0) {
      _inMemoryContacts[index] = toSave;
    } else {
      _inMemoryContacts.insert(0, toSave);
    }
    await _persistToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('contacts').upsert(toSave.toMap()).select();
        if (data is List && data.isNotEmpty) {
          final saved = Contact.fromMap(data.first as Map<String, dynamic>);
          final idx = _inMemoryContacts.indexWhere((item) => item.id == saved.id);
          if (idx >= 0) {
            _inMemoryContacts[idx] = saved;
          } else {
            _inMemoryContacts.add(saved);
          }
          await _persistToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase saveContact error: $e');
      }
    }

    return toSave;
  }

  Future<void> deleteContact(String id) async {
    await _initLocalStorage();
    final c = client;
    _inMemoryContacts.removeWhere((item) => item.id == id);
    await _persistToLocalStorage();

    if (c != null) {
      try {
        await c.from('contacts').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteContact error: $e');
      }
    }
  }
}
