import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFEDEEEF),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BeetleApp());
}

class BeetleApp extends StatelessWidget {
  const BeetleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightColorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF006079),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF006079),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFB7EAFF),
          onPrimaryContainer: const Color(0xFF001F28),
          secondary: const Color(0xFF00677F),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFDFE3FF),
          onSecondaryContainer: const Color(0xFF001452),
          surface: const Color(0xFFF8F9FA),
          onSurface: const Color(0xFF191C1D),
          surfaceContainerHighest: const Color(0xFFE1E3E4),
          onSurfaceVariant: const Color(0xFF3F484D),
          error: const Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: const Color(0xFFFFDAD6),
          onErrorContainer: const Color(0xFF93000A),
          outline: const Color(0xFF6F797E),
          outlineVariant: const Color(0xFFBEC8CD),
        );

    return MaterialApp(
      title: 'Nhận diện bọ cánh cứng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF006079)),
          titleTextStyle: TextStyle(
            color: Color(0xFF006079),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
