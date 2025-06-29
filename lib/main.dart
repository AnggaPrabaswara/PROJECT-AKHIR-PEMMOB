import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:melaly/auth_screen.dart';
import 'package:melaly/pages/home_page.dart';
import 'package:melaly/pages/add_wisata_page.dart';
import 'package:melaly/pages/detail_wisata_page.dart';
import 'package:melaly/pages/settings_page.dart';
import 'package:melaly/models/wisata_model.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'utils/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MelalyApp(),
    ),
  );
}

class MelalyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Melaly',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.blue[50],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => AuthScreen(),
            '/home': (context) => HomePage(),
            '/add': (context) => AddWisataPage(),
            '/settings': (context) => SettingsPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final args = settings.arguments as WisataModel;
              return MaterialPageRoute(
                builder: (context) => DetailWisataPage(args: args),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

