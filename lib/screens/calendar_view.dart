// lib/screens/calendar_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});
  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  bool _isLoading = true;
  List<dynamic> _clases = [];

  @override
  void initState() {
    super.initState();
    _loadClases();
  }

  void _loadClases() async {
    final res = await ApiService.getClases();
    setState(() {
      if (res['success'] == true) {
        _clases = res['clases'];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_clases.isEmpty) return const Center(child: Text('No hay clases configuradas en Sheets.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clases.length,
      itemBuilder: (context, index) {
        final c = _clases[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.blue),
            title: Text(c['nombre_clase']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Días: ${c['dias']?.toString() ?? ''} | Horario: ${c['horario']?.toString() ?? ''}'),
            trailing: Chip(label: Text('Cupo máx: ${c['cupo_maximo']?.toString() ?? ''}')),
          ),
        );
      },
    );
  }
}