import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/islamic_tips/data/datasources/islamic_tip_local_data_source.dart';
import 'package:solatify/features/islamic_tips/data/repositories/islamic_tip_repository_impl.dart';
import 'package:solatify/features/islamic_tips/domain/entities/islamic_tip.dart';
import 'package:solatify/features/islamic_tips/domain/repositories/islamic_tip_repository.dart';
import 'package:solatify/features/islamic_tips/domain/usecases/get_islamic_tips.dart';

// Data Source Provider
final islamicTipLocalDataSourceProvider = Provider<IslamicTipLocalDataSource>((
  ref,
) {
  return const IslamicTipLocalDataSourceImpl();
});

// Repository Provider
final islamicTipRepositoryProvider = Provider<IslamicTipRepository>((ref) {
  final localDataSource = ref.watch(islamicTipLocalDataSourceProvider);
  return IslamicTipRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Provider
final getIslamicTipsUseCaseProvider = Provider<GetIslamicTips>((ref) {
  final repository = ref.watch(islamicTipRepositoryProvider);
  return GetIslamicTips(repository);
});

// Presentation State Provider (Asynchronously fetch Tips)
final tipsProvider = FutureProvider<List<IslamicTip>>((ref) async {
  final getIslamicTips = ref.watch(getIslamicTipsUseCaseProvider);
  return getIslamicTips.execute();
});

// Provider for daily random tip
final randomTipProvider = FutureProvider<IslamicTip>((ref) async {
  final tips = await ref.watch(tipsProvider.future);
  final random = Random(DateTime.now().day);
  return tips[random.nextInt(tips.length)];
});
