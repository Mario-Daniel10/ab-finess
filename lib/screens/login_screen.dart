// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../models/user_model.dart';
import 'admin_home_screen.dart';
import 'client_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      UserModel user = UserModel.fromJson(result['user']);
      await SessionService.saveUser(user);

      if (!mounted) return;

      // Redirigir según el rol
      if (user.rol.toUpperCase() == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen(user: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClientHomeScreen(user: user)),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Error al iniciar sesión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo de AB Fitness centrado arriba del formulario
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 90, // Un tamaño destacado para el login
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFE50914), // Botón con el rojo de la marca
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}