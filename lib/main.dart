import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/signup_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const SkincareApp(),
    ),
  );
}

class SkincareApp extends StatelessWidget {
  const SkincareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final GoRouter _router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final loggedIn = userProvider.isLoggedIn;
        final loggingIn = state.uri.toString() == '/login';
        final signingUp = state.uri.toString() == '/signup';

        if (!loggedIn && !loggingIn && !signingUp) return '/login';
        if (loggedIn && (loggingIn || signingUp)) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Skincare App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8BBD0), // light pink
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
          accentColor: Color(0xFFF8BBD0), // light pink
          backgroundColor: Colors.white,
        ).copyWith(
          secondary: Color(0xFFF8BBD0), // light pink
          surface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF8BBD0), // light pink
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.pink,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFCE4EC), // very light pink
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF8BBD0)),
          ),
        ),
        cardColor: Color(0xFFFCE4EC), // very light pink
        chipTheme: ChipThemeData(
          backgroundColor: Color(0xFFF8BBD0),
          labelStyle: const TextStyle(color: Colors.black),
          selectedColor: Colors.pink,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
          headlineLarge: TextStyle(color: Colors.black),
          headlineMedium: TextStyle(color: Colors.black),
          headlineSmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
        ),
      ),
      routerConfig: _router,
    );
  }
}
