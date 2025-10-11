import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ConfigScreen.dart';
import 'Home_Screen.dart';
import 'MessajesScreen.dart';

class Timescreen extends StatefulWidget {
  const Timescreen({super.key, required this.ruta});

  final Map<String, dynamic> ruta;

  @override
  State<Timescreen> createState() => _TimescreenState();
}

class _TimescreenState extends State<Timescreen> {
  GoogleMapController? _mapController;

  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(19.8165058, -97.3656139),
    zoom: 13.0,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

  }

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

  @override
  Widget build(BuildContext context) {
    final ruta = widget.ruta;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de ${ruta['nombre'] ?? 'Android Auto'}"),
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
        child: Row(
          children: [
            // Izquierda: imagen (reloj)
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/time.png',
                      fit: BoxFit.contain,
                      height: 260,
                      errorBuilder: (context, error, stack) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.image, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'clock.png no encontrado',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            // Derecha: Google Map con onMapCreated
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialCamera,
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[350],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              _bottomIcon(Icons.mic),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Messajesscreen()),
                  );
                },
                child :_bottomIcon(Icons.chat_bubble),

              ),
              const SizedBox(width: 16),
              _bottomIcon(Icons.notifications),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.pushNamed(context, '/rutas'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Rutas'),
              ),
              const Spacer(),
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