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
    final int diasRestantes = _suscripcion?['dias_restantes'] ?? 0;
    final bool isActiva = (_suscripcion?['estado'] ?? 'INACTIVA') == 'ACTIVA';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text('Mi Portal', style: TextStyle(fontSize: 17)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Hola, ${widget.user.nombre}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
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
                  // Tarjeta de Estado de Suscripción adaptada a modo oscuro
                  Card(
                    elevation: 4,
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: diasRestantes > 3 ? Colors.green.withOpacity(0.4) : Colors.orange.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estado de tu Suscripción',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Chip(
                                label: Text(
                                  _suscripcion?['estado'] ?? 'INACTIVA',
                                  style: TextStyle(
                                    color: isActiva ? Colors.green[900] : Colors.red[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: isActiva ? Colors.green[300] : Colors.red[300],
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Colors.white24),
                          Text(
                            'Plan Actual: ${_suscripcion?['tipo_plan'] ?? 'Ninguno'}',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Válido hasta: ${_suscripcion?['fecha_fin'] ?? '-'}',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Días restantes: $diasRestantes días',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: diasRestantes > 3 ? Colors.greenAccent : Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Clases y Horarios Disponibles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  _clases.isEmpty
                      ? const Text(
                          'No hay clases publicadas por el momento.',
                          style: TextStyle(color: Colors.white70),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _clases.length,
                          itemBuilder: (context, index) {
                            final c = _clases[index];
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.fitness_center, color: Color(0xFFE50914)),
                                title: Text(
                                  c['nombre_clase'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Días: ${c['dias']} | Horario: ${c['horario']}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Chip(
                                  label: Text(
                                    'Cupo: ${c['cupo_maximo']}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: Colors.grey[850],
                                ),
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