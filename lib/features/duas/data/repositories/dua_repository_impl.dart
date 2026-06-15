import '../../domain/entities/dua.dart';
import '../../domain/repositories/dua_repository.dart';
import '../datasources/dua_local_data_source.dart';

class DuaRepositoryImpl implements DuaRepository {
  const DuaRepositoryImpl({required this.localDataSource});

  final DuaLocalDataSource localDataSource;

  @override
  Future<List<Dua>> getDuas() async {
    return localDataSource.getDuas();
  }
}
