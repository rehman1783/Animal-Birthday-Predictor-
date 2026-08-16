import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mare_repository.dart';
import '../../domain/animal.dart';
import '../../domain/markings.dart';

final mareRepositoryProvider = Provider<MareRepository>((ref) {
  return MareRepository();
});

final maresListProvider = FutureProvider<List<Animal>>((ref) async {
  final repo = ref.watch(mareRepositoryProvider);
  return repo.getMares();
});

final markingsForOwnerProvider = FutureProvider.family<Markings?, ({String ownerType, String ownerId})>((ref, arg) async {
  final repo = ref.watch(mareRepositoryProvider);
  return repo.getMarkings(arg.ownerType, arg.ownerId);
});
