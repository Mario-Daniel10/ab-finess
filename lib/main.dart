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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
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