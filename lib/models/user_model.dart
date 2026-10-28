// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String nombre;
  final String rol; // 'ADMIN' o 'CLIENTE'
  final String telefono;

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'].toString(),
      nombre: json['nombre'].toString(),
      rol: json['rol'].toString(),
      telefono: json['telefono'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'telefono': telefono,
    };
  }
}