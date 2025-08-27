import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sampleintegrateekyc/ekyc_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(const EkycApp());
}

class EkycApp extends StatelessWidget {
  const EkycApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final lightScheme = ShadColorScheme.fromName('green');
    final darkScheme =
        ShadColorScheme.fromName('green', brightness: Brightness.dark);

    return ShadApp(
      title: 'Ekyc NFC',
      debugShowCheckedModeBanner: false,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: lightScheme,
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: darkScheme,
      ),
      home: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const ScaffoldMessenger(
          child: EkycScreen(),
        ),
      ),
    );
  }
}
