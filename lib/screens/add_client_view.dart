// lib/screens/add_client_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddClientView extends StatefulWidget {
  const AddClientView({super.key});
  @override
  State<AddClientView> createState() => _AddClientViewState();
}

class _AddClientViewState extends State<AddClientView> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _montoController = TextEditingController();
  
  String _tipoPlanSeleccionado = 'Mensual';
  String _entrenamientoSeleccionado = 'Musculación';
  String _metodoPagoSeleccionado = 'Efectivo';
  DateTime _fechaInicio = DateTime.now();
  bool _isLoading = true;
  String _mensaje = '';

  final List<String> _planes = ['Mensual', 'Semanal', 'Por clase', 'Libre'];
  List<String> _entrenamientos = ['Musculación', 'Funcional'];
  final List<String> _metodosPago = ['Efectivo', 'Transferencia', 'Tarjeta'];

  @override
  void initState() {
    super.initState();
    _loadEntrenamientos();
  }

  void _loadEntrenamientos() async {
    final res = await ApiService.getTiposEntrenamiento();
    setState(() {
      if (res['success'] == true && res['entrenamientos'] != null) {
        _entrenamientos = List<String>.from(res['entrenamientos'].map((e) => e.toString()));
        if (_entrenamientos.isNotEmpty) {
          _entrenamientoSeleccionado = _entrenamientos.first;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (seleccionada != null && seleccionada != _fechaInicio) {
      setState(() {
        _fechaInicio = seleccionada;
      });
    }
  }

  void _guardarCliente() async {
    if (_nombreController.text.trim().isEmpty) {
      setState(() => _mensaje = 'El nombre es obligatorio');
      return;
    }

    setState(() {
      _isLoading = true;
      _mensaje = '';
    });

    String fechaInicioStr = _fechaInicio.toIso8601String().split('T')[0];

    final res = await ApiService.agregarCliente({
      "nombre": _nombreController.text.trim(),
      "email": _emailController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "tipo_plan": _tipoPlanSeleccionado,
      "entrenamiento": _entrenamientoSeleccionado,
      "monto": _montoController.text.trim(),
      "metodo_pago": _metodoPagoSeleccionado,
      "fecha_inicio": fechaInicioStr,
    });

    setState(() {
      _isLoading = false;
      _mensaje = res['success'] == true ? '¡Cliente registrado con éxito!' : (res['message'] ?? 'Error');
    });

    if (res['success'] == true) {
      _nombreController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _montoController.clear();
      setState(() {
        _fechaInicio = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Registrar Nuevo Cliente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre y Apellido *', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _entrenamientos.contains(_entrenamientoSeleccionado) ? _entrenamientoSeleccionado : (_entrenamientos.isNotEmpty ? _entrenamientos.first : null),
              decoration: const InputDecoration(labelText: 'Tipo de Entrenamiento', border: OutlineInputBorder()),
              items: _entrenamientos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _entrenamientoSeleccionado = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoPlanSeleccionado,
              decoration: const InputDecoration(labelText: 'Plan a Pagar', border: OutlineInputBorder()),
              items: _planes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _tipoPlanSeleccionado = val!),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Fecha de Inicio', border: OutlineInputBorder()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.year}',
                      style: const TextStyle(fontSize: 16)),
                  TextButton.icon(
                    onPressed: () => _seleccionarFecha(context),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Cambiar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _montoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto Abonado (\$)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _metodoPagoSeleccionado,
              decoration: const InputDecoration(labelText: 'Método de Pago', border: OutlineInputBorder()),
              items: _metodosPago.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _metodoPagoSeleccionado = val!),
            ),
            const SizedBox(height: 16),
            if (_mensaje.isNotEmpty)
              Text(_mensaje, style: TextStyle(color: _mensaje.contains('éxito') ? Colors.green : Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _guardarCliente,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Guardar Cliente y Suscripción', style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}