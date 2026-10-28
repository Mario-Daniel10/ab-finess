// lib/screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'training_types_view.dart';
import 'clients_view.dart';
import 'add_client_view.dart';
import 'payments_and_cash_view.dart';
import 'calendar_view.dart';
import 'expiring_subscriptions_view.dart'; // <--- ¡Última importación!
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
        return const ExpiringSubscriptionsView(); // <--- Viene de expiring_subscriptions_view.dart
      case 4:
        return const TrainingTypesView();
      case 5:
        return const AddClientView();
      default:
        return const Center(child: Text('Sección en construcción'));
    }
  }
}