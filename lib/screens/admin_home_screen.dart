// lib/screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final UserModel user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _menuTitles = [
    'Calendario',
    'Clientes',
    'Caja e Historial de Pagos',
    'Suscripciones a Vencer',
    'Tipos de Entrenamiento',
    'Agregar Cliente',
  ];

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
    // Detectamos si es una pantalla angosta (celular) o ancha (PC)
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text('AB Fitness - ${_menuTitles[_selectedIndex]}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Text(
                'Hola, ${widget.user.nombre}',
                style: const TextStyle(fontSize: 14),
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
      // Si es móvil, agregamos un Drawer (menú hamburguesa)
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('AB FITNESS', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.user.email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  _buildDrawerItem(0, 'Calendario', Icons.calendar_today),
                  _buildDrawerItem(1, 'Clientes', Icons.people),
                  _buildDrawerItem(2, 'Caja / Pagos', Icons.point_of_sale),
                  _buildDrawerItem(3, 'Por Vencer', Icons.warning_amber),
                  _buildDrawerItem(4, 'Entrenamientos', Icons.fitness_center),
                  _buildDrawerItem(5, 'Agregar Cliente', Icons.person_add),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          // Si es PC, mostramos el NavigationRail lateral fijo
          if (!isMobile) ...[
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.calendar_today), label: Text('Calendario')),
                NavigationRailDestination(icon: Icon(Icons.people), label: Text('Clientes')),
                NavigationRailDestination(icon: Icon(Icons.point_of_sale), label: Text('Caja / Pagos')),
                NavigationRailDestination(icon: Icon(Icons.warning_amber), label: Text('Por Vencer')),
                NavigationRailDestination(icon: Icon(Icons.fitness_center), label: Text('Entrenamientos')),
                NavigationRailDestination(icon: Icon(Icons.person_add), label: Text('Agregar')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          // Contenido principal de la pantalla seleccionada
          Expanded(
            child: _getSelectedScreen(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Cierra el menú drawer en celulares
      },
    );
  }

  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0:
        return const CalendarView();
      case 1:
        return const ClientsView();
      case 2:
        return const PaymentsAndCashView();
      case 3:
        return const ExpiringSubscriptionsView();
      case 4:
        return const TrainingTypesView();
      case 5:
        return const AddClientView();
      default:
        return const Center(child: Text('Sección en construcción'));
    }
  }
}

// --- VISTA 1: CALENDARIO Y CLASES ---
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

// --- VISTA 2: CLIENTES (CON BUSCADOR RESPONSIVE) ---
class ClientsView extends StatefulWidget {
  const ClientsView({super.key});
  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  bool _isLoading = true;
  List<dynamic> _clientes = [];
  List<dynamic> _clientesFiltrados = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  void _loadClientes() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getClientes();
    setState(() {
      if (res['success'] == true) {
        _clientes = res['clientes'];
        _clientesFiltrados = _clientes;
      }
      _isLoading = false;
    });
  }

  void _filtrarClientes(String query) {
    setState(() {
      _clientesFiltrados = _clientes.where((cli) {
        final nombre = (cli['nombre'] ?? '').toString().toLowerCase();
        final telefono = (cli['telefono'] ?? '').toString().toLowerCase();
        final q = query.toLowerCase();
        return nombre.contains(q) || telefono.contains(q);
      }).toList();
    });
  }

  void _mostrarDialogoEditar(Map<String, dynamic> cliente) {
    final nombreController = TextEditingController(text: cliente['nombre']?.toString() ?? '');
    final emailController = TextEditingController(text: cliente['email']?.toString() ?? '');
    final telefonoController = TextEditingController(text: cliente['telefono']?.toString() ?? '');
    String estadoSeleccionado = cliente['estado']?.toString() ?? 'ACTIVO';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Editar: ${cliente['nombre']?.toString() ?? ''}'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre y Apellido', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: estadoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'ACTIVO', child: Text('ACTIVO')),
                        DropdownMenuItem(value: 'INACTIVO', child: Text('INACTIVO')),
                      ],
                      onChanged: (val) {
                        setStateDialog(() => estadoSeleccionado = val!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    final res = await ApiService.actualizarCliente({
                      "id": cliente['id']?.toString() ?? '',
                      "nombre": nombreController.text.trim(),
                      "email": emailController.text.trim(),
                      "telefono": telefonoController.text.trim(),
                      "estado": estadoSeleccionado,
                    });

                    if (res['success'] == true) {
                      _loadClientes();
                      _searchController.clear();
                    } else {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['message']?.toString() ?? 'Error al actualizar')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
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
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filtrarClientes,
            decoration: InputDecoration(
              labelText: 'Buscar por nombre o teléfono',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filtrarClientes('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _clientesFiltrados.isEmpty
                ? const Center(child: Text('No se encontraron clientes.'))
                : ListView.builder(
                    itemCount: _clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cli = _clientesFiltrados[index];
                      final nombre = cli['nombre']?.toString() ?? 'Sin nombre';
                      final telefono = cli['telefono']?.toString() ?? 'Sin teléfono';
                      final estado = cli['estado']?.toString() ?? 'ACTIVO';
                      final tipoPlan = cli['tipo_plan']?.toString() ?? 'Sin plan';
                      final fechaFin = cli['fecha_fin']?.toString() ?? '-';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.person, color: Colors.blueAccent),
                            title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Tel: $telefono'),
                                Text('Plan: $tipoPlan | Vence: $fechaFin', style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => _mostrarDialogoEditar(cli),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  estado,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: estado == 'ACTIVO' ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
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

// --- VISTA 3: CAJA E HISTORIAL DE PAGOS ---
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

// Sub-pestaña B: Historial y Caja Diaria (Filtros en columna para celulares sin superposición)
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
          // Filtros responsivos: Se apilan en columna en celulares para evitar superposiciones
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

// --- VISTA 4: SUSCRIPCIONES A VENCER ---
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

// --- VISTA 5: TIPOS DE ENTRENAMIENTO ---
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

// --- VISTA 6: AGREGAR CLIENTES ---
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