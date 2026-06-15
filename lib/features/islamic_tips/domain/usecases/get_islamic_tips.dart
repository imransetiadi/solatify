import '../entities/islamic_tip.dart';
import '../repositories/islamic_tip_repository.dart';

class GetIslamicTips {
  const GetIslamicTips(this.repository);

  final IslamicTipRepository repository;

  Future<List<IslamicTip>> execute() async {
    return repository.getIslamicTips();
  }
}
