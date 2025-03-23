import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'language_provider.dart';
import 'features/call_feature.dart';  // Fraud Warning Feature

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Load the .env file
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    print("⚠️ Error loading .env file: $e");
  }

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("🔥 Firebase initialization failed: $e");
  }

  // Request necessary permissions
  await _requestPermissions();

  // Initialize Call Feature (no need to call `initialize()`)
  CallFeature();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.phone,
    Permission.microphone,
  ].request();

  if (statuses[Permission.phone] != PermissionStatus.granted ||
      statuses[Permission.microphone] != PermissionStatus.granted) {
    debugPrint("⚠️ Warning: Phone or Microphone permission was denied.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment App',
      theme: ThemeData(primarySwatch: Colors.teal),

      // Localization Support
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      locale: context.watch<LanguageProvider>().selectedLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomeScreen();  // If logged in, go to HomeScreen
          } else {
            return const LoginScreen();  // Otherwise, show LoginScreen
          }
        },
      ),
    );
  }

  // Function to check login status using SharedPreferences
  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}