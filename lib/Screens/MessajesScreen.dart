import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ConfigScreen.dart';
import 'Home_Screen.dart';
import '../Responsive/responsive.dart';

class Messajesscreen extends StatefulWidget {
  const Messajesscreen({super.key});

  @override
  State<Messajesscreen> createState() => _MessajesscreenState();
}

class _MessajesscreenState extends State<Messajesscreen> {
  GoogleMapController? _mapController;

  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(19.8165058, -97.3656139),
    zoom: 13.0,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // ---- helpers UI ----
  Widget _bottomIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _squareButton(IconData icon) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _messageButton({
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        onPressed: onPressed ??
                () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Mensaje: $text'))),
        icon: Icon(icon, size: 20),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ---- build ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Android Auto"),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfigScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = isWideWidth(constraints.maxWidth);

            final messagesPanel = Container(
              color: Colors.grey[300],
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enviar mensajes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _messageButton(
                      icon: Icons.place_outlined,
                      text: 'Estoy en la parada X',
                    ),
                    const SizedBox(height: 14),
                    _messageButton(
                      icon: Icons.timer_outlined,
                      text: 'Tengo un retraso de  X minutos',
                    ),
                    const SizedBox(height: 14),
                    _messageButton(
                      icon: Icons.car_repair_outlined,
                      text: 'Tengo un problema con el vehículo',
                    ),
                    const SizedBox(height: 14),
                    _messageButton(
                      icon: Icons.error_outline,
                      text: 'Hay un Accidente',
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );

            final map = GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _initialCamera,
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
            );

            if (wide) {
              // Dos paneles lado a lado
              return Row(
                children: [
                  Expanded(flex: 10, child: messagesPanel),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(flex: 16, child: map),
                ],
              );
            } else {
              // Mapa arriba, mensajes abajo con altura proporcional
              final h = MediaQuery.of(context).size.height;
              final panelHeight = h * 0.5;
              return Column(
                children: [
                  Expanded(child: map),
                  const Divider(height: 1, thickness: 1),
                  SizedBox(height: panelHeight, child: messagesPanel),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[350],
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomIcon(Icons.mic),
              const SizedBox(width: 16),
              _bottomIcon(Icons.chat_bubble),
              const SizedBox(width: 16),
              _bottomIcon(Icons.notifications),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.pushNamed(context, '/rutas'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Rutas'),
              ),
              const SizedBox(width: 16),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF1DB954),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                const Icon(Icons.graphic_eq, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 12),
              _squareButton(Icons.remove),
              const SizedBox(width: 8),
              _squareButton(Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}