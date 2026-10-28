// lib/screens/training_types_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TrainingTypesView extends StatefulWidget {
  const TrainingTypesView({super.key});
  @override
  State<TrainingTypesView> createState() => _TrainingTypesViewState();
}

class _TrainingTypesViewState extends State<TrainingTypesView> {
  bool _isLoading = true;
  List<String> _entrenamientos = [];

  @override
  void initState() {
    super.initState();
    _loadEntrenamientos();
  }

  void _loadEntrenamientos() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getTiposEntrenamiento();
    setState(() {
      if (res['success'] == true && res['entrenamientos'] != null) {
        _entrenamientos = List<String>.from(res['entrenamientos'].map((e) => e.toString()));
      }
      _isLoading = false;
    });
  }

  void _mostrarDialogoAgregar() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Entrenamiento'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre (ej: Crossfit, Pilates)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = controller.text.trim();
                if (nombre.isEmpty) return;
                Navigator.pop(context);
                setState(() => _isLoading = true);

                final res = await ApiService.agregarTipoEntrenamiento(nombre);
                if (res['success'] == true) {
                  _loadEntrenamientos();
                } else {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message']?.toString() ?? 'Error')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tipos de Clases:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _mostrarDialogoAgregar,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _entrenamientos.isEmpty
                ? const Center(child: Text('No hay entrenamientos cargados.'))
                : ListView.builder(
                    itemCount: _entrenamientos.length,
                    itemBuilder: (context, index) {
                      final ent = _entrenamientos[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center, color: Colors.blueAccent),
                          title: Text(ent, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Disciplina activa.'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}