// lib/screens/clients_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
                            trailing: SizedBox(
                              height: 55, // Altura fija segura para evitar el desbordamiento
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _mostrarDialogoEditar(cli),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                      child: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
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