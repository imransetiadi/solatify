import '../entities/islamic_tip.dart';

abstract class IslamicTipRepository {
  Future<List<IslamicTip>> getIslamicTips();
}
