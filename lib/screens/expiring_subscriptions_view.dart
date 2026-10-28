// lib/screens/expiring_subscriptions_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ExpiringSubscriptionsView extends StatefulWidget {
  const ExpiringSubscriptionsView({super.key});
  @override
  State<ExpiringSubscriptionsView> createState() => _ExpiringSubscriptionsViewState();
}

class _ExpiringSubscriptionsViewState extends State<ExpiringSubscriptionsView> {
  bool _isLoading = true;
  List<dynamic> _subs = [];

  @override
  void initState() {
    super.initState();
    _loadSubs();
  }

  void _loadSubs() async {
    final res = await ApiService.getSuscripcionesVencer();
    setState(() {
      if (res['success'] == true) {
        _subs = res['suscripciones'];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_subs.isEmpty) {
      return const Center(
        child: Text(
          'No hay suscripciones próximas a vencer.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _subs.length,
      itemBuilder: (context, index) {
        final s = _subs[index];
        return Card(
          // Fondo oscuro elegante para la tarjeta con un borde sutil en tono rojo/alerta
          color: const Color(0xFF1E1E1E),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.red.withOpacity(0.4), width: 1),
          ),
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE50914), size: 28),
            title: Text(
              s['nombre_cliente']?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Plan: ${s['tipo_plan']?.toString() ?? ''} | Vence: ${s['fecha_fin']?.toString() ?? ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE50914)),
              ),
              child: Text(
                'Restan ${s['dias_restantes']?.toString() ?? '0'} días',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE50914), fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}