import '../../domain/entities/asmaul_husna.dart';
import '../../domain/repositories/asmaul_husna_repository.dart';
import '../datasources/asmaul_husna_local_data_source.dart';

class AsmaulHusnaRepositoryImpl implements AsmaulHusnaRepository {
  AsmaulHusnaRepositoryImpl({required this.localDataSource});

  final AsmaulHusnaLocalDataSource localDataSource;

  @override
  Future<List<AsmaulHusna>> getAsmaulHusna() async {
    return localDataSource.getAsmaulHusna();
  }
}
