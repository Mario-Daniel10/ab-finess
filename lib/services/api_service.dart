// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Tu URL de Google Apps Script
  static const String url = "https://script.google.com/macros/s/AKfycbyxYMh-OkAOdKcTdEyQSRWLLI4gVZ8z-PMWXjJCofTsXzkz5rwIr7KpgZiz9N54sHXw/exec";

  // 1. LOGIN DE USUARIO
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "login",
          "email": email,
          "password": password,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error de servidor: ${response.statusCode}"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 2. OBTENER CLIENTES (Con casteo de ID a String para evitar errores de tipo)
  static Future<Map<String, dynamic>> getClientes() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"action": "getClientes"}),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['clientes'] != null) {
          for (var cli in decoded['clientes']) {
            cli['id'] = cli['id'].toString();
          }
        }
        return decoded;
      }
      return {"success": false, "message": "Error al obtener clientes"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 3. AGREGAR CLIENTE
  static Future<Map<String, dynamic>> agregarCliente(Map<String, dynamic> clienteData) async {
    try {
      clienteData["action"] = "agregarCliente";
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(clienteData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al agregar cliente"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 4. REGISTRAR PAGO
  static Future<Map<String, dynamic>> registrarPago(Map<String, dynamic> pagoData) async {
    try {
      pagoData["action"] = "registrarPago";
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(pagoData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al registrar pago"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 5. OBTENER CLASES (CALENDARIO)
  static Future<Map<String, dynamic>> getClases() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"action": "getClases"}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al obtener clases"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 6. SUSCRIPCIONES A VENCER
  static Future<Map<String, dynamic>> getSuscripcionesVencer() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"action": "getSuscripcionesVencer"}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al obtener suscripciones"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 7. OBTENER DASHBOARD DEL CLIENTE
  static Future<Map<String, dynamic>> getClientDashboard(String idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "getClientDashboard",
          "id_usuario": idUsuario,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error de servidor: ${response.statusCode}"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 8. OBTENER HISTORIAL DE PAGOS (CAJA)
  static Future<Map<String, dynamic>> getPagos() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"action": "getPagos"}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al obtener historial de pagos"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // 9. ACTUALIZAR DATOS O ESTADO DE CLIENTE
  static Future<Map<String, dynamic>> actualizarCliente(Map<String, dynamic> clienteData) async {
    try {
      clienteData["action"] = "actualizarCliente";
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(clienteData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al actualizar cliente"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
  // OBTENER TIPOS DE ENTRENAMIENTO
  static Future<Map<String, dynamic>> getTiposEntrenamiento() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"action": "getTiposEntrenamiento"}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al obtener entrenamientos"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // AGREGAR TIPO DE ENTRENAMIENTO
  static Future<Map<String, dynamic>> agregarTipoEntrenamiento(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "action": "agregarTipoEntrenamiento",
          "nombre": nombre,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Error al guardar entrenamiento"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }
}