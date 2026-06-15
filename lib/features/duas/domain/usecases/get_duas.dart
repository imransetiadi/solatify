import '../entities/dua.dart';
import '../repositories/dua_repository.dart';

class GetDuas {
  const GetDuas(this.repository);

  final DuaRepository repository;

  Future<List<Dua>> execute() async {
    return repository.getDuas();
  }
}
