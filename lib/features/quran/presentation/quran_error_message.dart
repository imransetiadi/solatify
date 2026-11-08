import 'package:solatify/features/quran/data/quran_repository.dart';

/// A short, localised explanation of why Quran data could not be loaded.
/// The technical detail only goes to the debug log, never to the screen.
String quranErrorMessage(Object error, {required bool isEnglish}) {
  final failure = error is QuranLoadException
      ? error.failure
      : QuranLoadFailure.server;
  return switch (failure) {
    QuranLoadFailure.offline =>
      isEnglish
          ? 'No internet connection. Connect once to download this, then it works offline.'
          : 'Tidak ada koneksi internet. Sambungkan sekali untuk mengunduh, setelah itu bisa dibaca offline.',
    QuranLoadFailure.timeout =>
      isEnglish
          ? 'The Qur\'an server took too long to respond. Please try again.'
          : 'Server Al-Qur\'an terlalu lama merespons. Silakan coba lagi.',
    QuranLoadFailure.server || QuranLoadFailure.format =>
      isEnglish
          ? 'The Qur\'an server could not be reached right now. Please try again.'
          : 'Server Al-Qur\'an belum dapat dihubungi. Silakan coba lagi.',
  };
}
