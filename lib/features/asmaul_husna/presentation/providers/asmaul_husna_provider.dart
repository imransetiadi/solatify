import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/asmaul_husna/data/datasources/asmaul_husna_local_data_source.dart';
import 'package:solatify/features/asmaul_husna/data/repositories/asmaul_husna_repository_impl.dart';
import 'package:solatify/features/asmaul_husna/domain/entities/asmaul_husna.dart';
import 'package:solatify/features/asmaul_husna/domain/repositories/asmaul_husna_repository.dart';
import 'package:solatify/features/asmaul_husna/domain/usecases/get_asmaul_husna.dart';

// Data Source Provider
final asmaulHusnaLocalDataSourceProvider = Provider<AsmaulHusnaLocalDataSource>((ref) {
  return const AsmaulHusnaLocalDataSourceImpl();
});

// Repository Provider
final asmaulHusnaRepositoryProvider = Provider<AsmaulHusnaRepository>((ref) {
  final localDataSource = ref.watch(asmaulHusnaLocalDataSourceProvider);
  return AsmaulHusnaRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Provider
final getAsmaulHusnaUseCaseProvider = Provider<GetAsmaulHusna>((ref) {
  final repository = ref.watch(asmaulHusnaRepositoryProvider);
  return GetAsmaulHusna(repository);
});

// Presentation State Provider (Asynchronously fetch Asmaul Husna)
final asmaulHusnaProvider = FutureProvider<List<AsmaulHusna>>((ref) async {
  final getAsmaulHusna = ref.watch(getAsmaulHusnaUseCaseProvider);
  return getAsmaulHusna.execute();
});
