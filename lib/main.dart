import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_studio/screens/main/home_screen.dart';
import 'package:qr_studio/screens/onboarding/first_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Studio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ElmsSans',
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'ElmsSans'),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'ElmsSans',
        textTheme: ThemeData.dark().textTheme
            .apply(fontFamily: 'ElmsSans')
            .copyWith(
              bodyMedium: const TextStyle(color: Colors.white),
              bodyLarge: const TextStyle(color: Colors.white),
            ),
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 3, 62, 114),
          secondary: Colors.blue[500]!,
          surface: const Color(0xFF1E1E1E),
          outlineVariant: const Color(0xFF3A3A3A),
          surfaceContainerHighest: const Color(0xFF2C2C2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: const CardThemeData(color: Color(0xFF1E1E1E), elevation: 0),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        dividerColor: const Color(0xFF2C2C2C),
      ),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _scale = Tween(
    begin: 0.9,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);
  late final Animation<double> _fade = Tween(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.easeIn)).animate(_controller);

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _startDelay();
  }

  Future<void> _startDelay() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    if (!mounted) return;
    if (onboardingComplete) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const FirstScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0E0E0E);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2, size: 96, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'QR Studio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan • Create • Share',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
