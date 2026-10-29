// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Importante para controlar el color de las barras del sistema
import 'models/user_model.dart';
import 'screens/admin_home_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Forzamos las barras de estado y navegación del celular a modo oscuro elegante
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF121212), // Fondo de la barra superior (reloj/batería)
      statusBarIconBrightness: Brightness.light, // Iconos claros en la barra superior
      systemNavigationBarColor: Color(0xFF121212), // Fondo de la barra inferior de Android
      systemNavigationBarIconBrightness: Brightness.light, // Iconos claros en la barra inferior
    ),
  );

  UserModel? savedUser = await SessionService.getUser();

  runApp(MyApp(initialUser: savedUser));
}

class MyApp extends StatelessWidget {
  final UserModel? initialUser;
  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NB Fitness',
      debugShowCheckedModeBanner: false,
      // Aplicamos el tema oscuro y la paleta de colores oficial de NB Fitness
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE50914), // Rojo intenso de la marca[cite: 2]
        scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro moderno[cite: 2]
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914), // Color principal para botones y elementos activos[cite: 2]
          secondary: Colors.white,   // Detalles secundarios[cite: 2]
          surface: Color(0xFF1E1E1E),  // Color para tarjetas (Cards) y contenedores[cite: 2]
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A), // Barra superior oscura elegante[cite: 2]
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