// lib/screens/payments_and_cash_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentsAndCashView extends StatefulWidget {
  const PaymentsAndCashView({super.key});
  @override
  State<PaymentsAndCashView> createState() => _PaymentsAndCashViewState();
}

class _PaymentsAndCashViewState extends State<PaymentsAndCashView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue[50],
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue[800],
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(icon: Icon(Icons.add_card, size: 20), text: 'Cobrar'),
              Tab(icon: Icon(Icons.history, size: 20), text: 'Historial / Caja'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              RegistrarPagoTab(),
              HistorialPagosTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Sub-pestaña A: Registrar Cobro
class RegistrarPagoTab extends StatefulWidget {
  const RegistrarPagoTab({super.key});
  @override
  State<RegistrarPagoTab> createState() => _RegistrarPagoTabState();
}

class _RegistrarPagoTabState extends State<RegistrarPagoTab> {
  bool _isLoading = true;
  List<dynamic> _clientes = [];
  List<String> _entrenamientos = ['Musculación', 'Funcional'];
  String? _clienteSeleccionadoId;
  final _montoController = TextEditingController();
  
  String _tipoPlan = 'Mensual';
  String _entrenamiento = 'Musculación';
  String _metodoPago = 'Efectivo';
  DateTime _fechaInicio = DateTime.now();
  String _mensaje = '';

  final List<String> _planes = ['Mensual', 'Semanal', 'Por clase', 'Libre'];
  final List<String> _metodos = ['Efectivo', 'Transferencia', 'Tarjeta'];

  @override
  void initState() {
    super.initState();
    _loadDatos();
  }

  void _loadDatos() async {
    final resClientes = await ApiService.getClientes();
    final resEnt = await ApiService.getTiposEntrenamiento();

    setState(() {
      if (resClientes['success'] == true) {
        _clientes = resClientes['clientes'];
        _clienteSeleccionadoId = null;
      }
      if (resEnt['success'] == true && resEnt['entrenamientos'] != null) {
        _entrenamientos = List<String>.from(resEnt['entrenamientos'].map((e) => e.toString()));
        if (_entrenamientos.isNotEmpty) {
          _entrenamiento = _entrenamientos.first;
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

  void _cobrarRenovacion() async {
    if (_clienteSeleccionadoId == null || _montoController.text.trim().isEmpty) {
      setState(() => _mensaje = 'Selecciona un cliente e ingresa el monto');
      return;
    }

    setState(() => _isLoading = true);
    String fechaInicioStr = _fechaInicio.toIso8601String().split('T')[0];

    final res = await ApiService.registrarPago({
      "id_usuario": _clienteSeleccionadoId,
      "monto": _montoController.text.trim(),
      "tipo_plan": _tipoPlan,
      "entrenamiento": _entrenamiento,
      "metodo_pago": _metodoPago,
      "concepto": "Renovación Cuota $_tipoPlan ($_entrenamiento)",
      "fecha_inicio": fechaInicioStr,
    });

    setState(() {
      _isLoading = false;
      _mensaje = res['success'] == true ? (res['message'] ?? '¡Renovación exitosa!') : (res['message'] ?? 'Error');
    });

    if (res['success'] == true) {
      _montoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Registrar Cobro / Renovación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Autocomplete<Map<String, dynamic>>(
              displayStringForOption: (option) => '${option['nombre']} (${option['telefono']})',
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return _clientes.cast<Map<String, dynamic>>().where((cli) {
                  final nombre = (cli['nombre'] ?? '').toString().toLowerCase();
                  final telefono = (cli['telefono'] ?? '').toString().toLowerCase();
                  final q = textEditingValue.text.toLowerCase();
                  return nombre.contains(q) || telefono.contains(q);
                });
              },
              onSelected: (selection) {
                setState(() {
                  _clienteSeleccionadoId = selection['id']?.toString();
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Cliente (Nombre o Teléfono)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _entrenamientos.contains(_entrenamiento) ? _entrenamiento : (_entrenamientos.isNotEmpty ? _entrenamientos.first : null),
              decoration: const InputDecoration(labelText: 'Tipo de Entrenamiento', border: OutlineInputBorder()),
              items: _entrenamientos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _entrenamiento = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoPlan,
              decoration: const InputDecoration(labelText: 'Plan a Renovar', border: OutlineInputBorder()),
              items: _planes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _tipoPlan = val!),
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
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto a Cobrar (\$)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _metodoPago,
              decoration: const InputDecoration(labelText: 'Método de Pago', border: OutlineInputBorder()),
              items: _metodos.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _metodoPago = val!),
            ),
            const SizedBox(height: 16),
            if (_mensaje.isNotEmpty)
              Text(_mensaje, style: TextStyle(color: _mensaje.contains('exitosa') || _mensaje.contains('registrado') ? Colors.green : Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _cobrarRenovacion,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Confirmar Pago y Extender', style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}

// Sub-pestaña B: Historial y Caja Diaria
class HistorialPagosTab extends StatefulWidget {
  const HistorialPagosTab({super.key});
  @override
  State<HistorialPagosTab> createState() => _HistorialPagosTabState();
}

class _HistorialPagosTabState extends State<HistorialPagosTab> {
  bool _isLoading = true;
  List<dynamic> _pagos = [];
  List<dynamic> _pagosFiltrados = [];
  String _filtroMetodo = 'Todos';
  String _filtroFecha = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadPagos();
  }

  void _loadPagos() async {
    final res = await ApiService.getPagos();
    setState(() {
      if (res['success'] == true) {
        _pagos = res['pagos'];
        _aplicarFiltros();
      }
      _isLoading = false;
    });
  }

  void _aplicarFiltros() {
    String hoyStr = DateTime.now().toIso8601String().split('T')[0];

    setState(() {
      _pagosFiltrados = _pagos.where((p) {
        bool cumpleMetodo = (_filtroMetodo == 'Todos' || p['metodo_pago'] == _filtroMetodo);
        bool cumpleFecha = true;

        if (_filtroFecha == 'Hoy') {
          cumpleFecha = (p['fecha_pago'] == hoyStr);
        }
        return cumpleMetodo && cumpleFecha;
      }).toList();
    });
  }

  double get _totalRecaudado {
    double total = 0;
    for (var p in _pagosFiltrados) {
      total += (double.tryParse(p['monto']?.toString() ?? '0') ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.green[50],
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total en Caja', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 2),
                      Text('${_pagosFiltrados.length} operaciones', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  Text(
                    '\$ ${_totalRecaudado.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _filtroFecha,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Filtrar por Fecha', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Todas las Fechas')),
                        DropdownMenuItem(value: 'Hoy', child: Text('Solo el Día de Hoy')),
                      ],
                      onChanged: (val) {
                        setState(() => _filtroFecha = val!);
                        _aplicarFiltros();
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _filtroMetodo,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Método de Pago', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Todos los Métodos')),
                        DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                        DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                      ],
                      onChanged: (val) {
                        setState(() => _filtroMetodo = val!);
                        _aplicarFiltros();
                      },
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filtroFecha,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Filtrar por Fecha', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'Todos', child: Text('Todas las Fechas')),
                          DropdownMenuItem(value: 'Hoy', child: Text('Solo el Día de Hoy')),
                        ],
                        onChanged: (val) {
                          setState(() => _filtroFecha = val!);
                          _aplicarFiltros();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filtroMetodo,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Método de Pago', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'Todos', child: Text('Todos los Métodos')),
                          DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                          DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                          DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                        ],
                        onChanged: (val) {
                          setState(() => _filtroMetodo = val!);
                          _aplicarFiltros();
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 12),
          const Text('Listado de Pagos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: _pagosFiltrados.isEmpty
                ? const Center(child: Text('No hay pagos registrados.'))
                : ListView.builder(
                    itemCount: _pagosFiltrados.length,
                    itemBuilder: (context, index) {
                      final p = _pagosFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.attach_money, color: Colors.white, size: 20),
                            ),
                            title: Text(p['nombre_cliente']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Concepto: ${p['concepto']?.toString() ?? ''}', style: const TextStyle(fontSize: 13)),
                                Text('Fecha: ${p['fecha_pago']?.toString() ?? ''} | Método: ${p['metodo_pago']?.toString() ?? ''}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: Text(
                              '\$ ${p['monto']?.toString() ?? '0'}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
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