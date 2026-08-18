import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getUserStats();
});
