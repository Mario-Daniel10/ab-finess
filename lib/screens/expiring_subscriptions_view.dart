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
    if (_subs.isEmpty) return const Center(child: Text('No hay suscripciones próximas a vencer.'));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _subs.length,
      itemBuilder: (context, index) {
        final s = _subs[index];
        return Card(
          color: Colors.orange[50],
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: Text(s['nombre_cliente']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Plan: ${s['tipo_plan']?.toString() ?? ''} | Vence: ${s['fecha_fin']?.toString() ?? ''}'),
            trailing: Text('Restan ${s['dias_restantes']?.toString() ?? '0'} días', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)),
          ),
        );
      },
    );
  }
}