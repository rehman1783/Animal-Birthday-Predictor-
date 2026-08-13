import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mare_repository.dart';
import '../../domain/mare.dart';
import '../../domain/markings.dart';

final mareRepositoryProvider = Provider<MareRepository>((ref) {
  return MareRepository();
});

final maresListProvider = FutureProvider<List<Mare>>((ref) async {
  final repo = ref.watch(mareRepositoryProvider);
  return repo.getMares();
});

final recipientMaresListProvider = FutureProvider<List<RecipientMare>>((ref) async {
  final repo = ref.watch(mareRepositoryProvider);
  return repo.getRecipientMares();
});

final markingsProvider = FutureProvider.family<Markings?, ({String ownerType, String ownerId})>((ref, arg) async {
  final repo = ref.watch(mareRepositoryProvider);
  return repo.getMarkings(arg.ownerType, arg.ownerId);
});
