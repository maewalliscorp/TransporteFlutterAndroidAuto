import 'package:android_auto/Screens/MessajesScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ConfigScreen.dart';
import '../Responsive/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;

  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(19.8165058, -97.3656139),
    zoom: 13.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android Auto', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.purple,
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
          IconButton(icon: const Icon(Icons.home), onPressed: () {}),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = isWideWidth(constraints.maxWidth);

          final sidePanel = Container(
            color: Colors.purple[50],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'El camino más rapido en pantalla',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/rutas'),
                  icon: const Icon(Icons.map, size: 24),
                  label: const Text('Rutas', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/car.png',
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          );

          final map = GoogleMap(
            initialCameraPosition: _initialCamera,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          );

          if (isWide) {
            // Pantallas anchas: layout en fila
            return Row(
              children: [
                Expanded(flex: 2, child: sidePanel),
                Expanded(flex: 3, child: map),
              ],
            );
          } else {
            // Pantallas estrechas: layout en columna
            final h = MediaQuery.of(context).size.height;
            final panelHeight = h * 0.45;
            return Column(
              children: [
                Expanded(child: map),
                SizedBox(
                  height: panelHeight,
                  child: sidePanel,
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[350],
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: const Text(
                  '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              const _BottomIcon(icon: Icons.mic),
              const SizedBox(width: 16),
              _BottomIcon(
                icon: Icons.chat_bubble,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Messajesscreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              const _BottomIcon(icon: Icons.notifications),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.pushNamed(context, '/rutas'),
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text('Rutas', style: TextStyle(fontSize: 18)),
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
              const _SquareButton(icon: Icons.remove),
              const SizedBox(width: 8),
              const _SquareButton(icon: Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}

// Widgets privados integrados

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _BottomIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white),
    );
    return onTap == null ? child : GestureDetector(onTap: onTap, child: child);
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _SquareButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
    return onTap == null ? child : GestureDetector(onTap: onTap, child: child);
  }
}