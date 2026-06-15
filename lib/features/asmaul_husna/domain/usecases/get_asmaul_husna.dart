import '../entities/asmaul_husna.dart';
import '../repositories/asmaul_husna_repository.dart';

class GetAsmaulHusna {
  GetAsmaulHusna(this.repository);

  final AsmaulHusnaRepository repository;

  Future<List<AsmaulHusna>> execute() async {
    return repository.getAsmaulHusna();
  }
}
