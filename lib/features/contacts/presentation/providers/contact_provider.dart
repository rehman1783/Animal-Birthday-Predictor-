import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/contact_repository.dart';
import '../../domain/contact.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepository();
});

final contactsListProvider = FutureProvider.autoDispose.family<List<Contact>, String?>((ref, role) async {
  final repo = ref.watch(contactRepositoryProvider);
  return repo.getContacts(role: role);
});

final contactByIdProvider = FutureProvider.autoDispose.family<Contact?, String>((ref, id) async {
  final repo = ref.watch(contactRepositoryProvider);
  return repo.getContactById(id);
});
