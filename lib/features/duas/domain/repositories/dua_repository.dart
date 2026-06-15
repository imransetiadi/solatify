import '../entities/dua.dart';

abstract class DuaRepository {
  Future<List<Dua>> getDuas();
}
