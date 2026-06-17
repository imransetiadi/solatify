import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/duas/data/datasources/dua_local_data_source.dart';
import 'package:solatify/features/duas/data/repositories/dua_repository_impl.dart';
import 'package:solatify/features/duas/domain/entities/dua.dart';
import 'package:solatify/features/duas/domain/repositories/dua_repository.dart';
import 'package:solatify/features/duas/domain/usecases/get_duas.dart';

// Data Source Provider
final duaLocalDataSourceProvider = Provider<DuaLocalDataSource>((ref) {
  return const DuaLocalDataSourceImpl();
});

// Repository Provider
final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  final localDataSource = ref.watch(duaLocalDataSourceProvider);
  return DuaRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Provider
final getDuasUseCaseProvider = Provider<GetDuas>((ref) {
  final repository = ref.watch(duaRepositoryProvider);
  return GetDuas(repository);
});

// Presentation State Provider (Asynchronously fetch Duas)
final duasProvider = FutureProvider<List<Dua>>((ref) async {
  final getDuas = ref.watch(getDuasUseCaseProvider);
  return getDuas.execute();
});

// Category-filtered Provider
final duasByCategoryProvider = Provider.family<AsyncValue<List<Dua>>, String>((
  ref,
  category,
) {
  final duasAsync = ref.watch(duasProvider);
  return duasAsync.whenData((allDuas) {
    return allDuas.where((dua) => dua.category == category).toList();
  });
});
