import '../../domain/entities/islamic_tip.dart';
import '../../domain/repositories/islamic_tip_repository.dart';
import '../datasources/islamic_tip_local_data_source.dart';

class IslamicTipRepositoryImpl implements IslamicTipRepository {
  const IslamicTipRepositoryImpl({required this.localDataSource});

  final IslamicTipLocalDataSource localDataSource;

  @override
  Future<List<IslamicTip>> getIslamicTips() async {
    return localDataSource.getIslamicTips();
  }
}
