// lib/screens/client_home_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final UserModel user;
  const ClientHomeScreen({super.key, required this.user});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _suscripcion;
  List<dynamic> _clases = [];

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  void _loadClientData() async {
    final resSub = await ApiService.getClientDashboard(widget.user.id);
    final resClases = await ApiService.getClases();

    setState(() {
      if (resSub['success'] == true) {
        _suscripcion = resSub['suscripcion'];
      }
      if (resClases['success'] == true) {
        _clases = resClases['clases'];
      }
      _isLoading = false;
    });
  }

  void _onLogout() async {
    await SessionService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Portal - AB Fitness'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: Text('Hola, ${widget.user.nombre}')),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _onLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadClientData(),
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Tarjeta de Estado de Suscripción
                  Card(
                    elevation: 4,
                    color: (_suscripcion?['dias_restantes'] ?? 0) > 3 ? Colors.green[50] : Colors.orange[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estado de tu Suscripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Chip(
                                label: Text(_suscripcion?['estado'] ?? 'INACTIVA'),
                                backgroundColor: _suscripcion?['estado'] == 'ACTIVA' ? Colors.green[200] : Colors.red[200],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text('Plan Actual: ${_suscripcion?['tipo_plan'] ?? 'Ninguno'}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Válido hasta: ${_suscripcion?['fecha_fin'] ?? '-'}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            'Días restantes: ${_suscripcion?['dias_restantes'] ?? 0} días',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: (_suscripcion?['dias_restantes'] ?? 0) > 3 ? Colors.green[800] : Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Clases y Horarios Disponibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _clases.isEmpty
                      ? const Text('No hay clases publicadas por el momento.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _clases.length,
                          itemBuilder: (context, index) {
                            final c = _clases[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.fitness_center, color: Colors.blue),
                                title: Text(c['nombre_clase'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Días: ${c['dias']} | Horario: ${c['horario']}'),
                                trailing: Chip(label: Text('Cupo: ${c['cupo_maximo']}')),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}