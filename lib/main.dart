// lib/main.dart
import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'screens/admin_home_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserModel? savedUser = await SessionService.getUser();

  runApp(MyApp(initialUser: savedUser));
}

class MyApp extends StatelessWidget {
  final UserModel? initialUser;
  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AB Fitness',
      debugShowCheckedModeBanner: false,
      // Aplicamos el tema oscuro y la paleta de colores oficial de AB Fitness
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE50914), // Rojo intenso de la marca
        scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro moderno
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914), // Color principal para botones y elementos activos
          secondary: Colors.white,   // Detalles secundarios
          surface: Color(0xFF1E1E1E),  // Color para tarjetas (Cards) y contenedores
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A), // Barra superior oscura elegante
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: initialUser == null
          ? const LoginScreen()
          : (initialUser!.rol.toUpperCase() == 'ADMIN'
              ? AdminHomeScreen(user: initialUser!)
              : ClientHomeScreen(user: initialUser!)),
    );
  }
}