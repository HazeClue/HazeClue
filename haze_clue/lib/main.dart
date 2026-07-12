import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onnxruntime/onnxruntime.dart';

const Color kPrimaryPurple = Color.fromARGB(255, 101, 67, 194);
const Color kTextDark = Color(0xFF1A1A2E);
const Color kTextLightGrey = Color(0xFF7A7A8C);
const Color kInputBg = Color(0xFFF5F5F7);
const Color kSuccessGreen = Color(0xFF00A86B);

// Shared Preferences Provider
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

// Global Theme Provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final isLight = prefs.getBool('isLightMode') ?? false;
    return isLight ? ThemeMode.light : ThemeMode.dark;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ONNX Runtime
  OrtEnv.instance.init();


  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: currentMode,
      // --- Light Theme ---
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(
          0xFFF0F4F8,
        ), // Very light cool grey/blue
        primaryColor: kPrimaryPurple,
        colorScheme: const ColorScheme.light(
          primary: kPrimaryPurple,
          secondary: Color(0xFF4F46E5), // Indigo
          surface: Colors.white,
          onSurface: Color(0xFF1A1A2E),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF1A1A2E),
          displayColor: const Color(0xFF1A1A2E),
        ),
      ),
      // --- Dark Theme ---
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep dark blue/grey
        primaryColor: kPrimaryPurple,
        colorScheme: const ColorScheme.dark(
          primary: kPrimaryPurple,
          secondary: Color(0xFF9333EA), // Purple
          surface: Color(0xFF1E1E2A),
          onSurface: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
