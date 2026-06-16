import 'dart:io';

void main() {
  final file = File('lib/features/settings/presentation/screens/settings_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'return Scaffold(',
    '''return Scaffold(
      extendBodyBehindAppBar: true,
      '''
  );
  file.writeAsStringSync(content);
}
