import 'package:android_auto/Services/mysql_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ConfigScreen.dart';
import 'DetailsRoutsScreens.dart';
import 'DetailsRoutsScreens.dart';
import 'Home_Screen.dart';
import 'MessajesScreen.dart';

class RutasScreen extends StatefulWidget {
  const RutasScreen({super.key});

  @override
  State<RutasScreen> createState() => _RutasScreenState();
}

class _RutasScreenState extends State<RutasScreen> {
  late GoogleMapController _mapController;
  List<Map<String, dynamic>> _rutas = [];
  bool _cargando = true;
  final MySQLService _db = MySQLService();
  String? _error;

  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(19.8165058, -97.3656139),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    _cargarRutas();
  }

  Future<void> _cargarRutas() async {
    try {
      await _db.connect();
      final data = await _db.getRutas();
      setState(() {
        _rutas = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al conectar: $e';
        _cargando = false;
      });
    }
  }

  // Helpers
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToDetails(int index) {
    if (index < 0 || index >= _rutas.length) return;
    final r = _rutas[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsRoutsScreen(
          ruta: {
            'id_ruta': r['id_ruta'],
            'nombre': r['nombre'],
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Android Auto - Rutas"),
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
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(child: Text(_error!))
          : Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.purple[50],
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rutas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Columnas según ancho disponible (responsivo)
                        int crossAxisCount = 1;
                        if (constraints.maxWidth >= 1000) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth >= 700) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 16 / 9,
                          ),
                          itemCount: _rutas.length,
                          itemBuilder: (context, index) {
                            final ruta = _rutas[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _goToDetails(index),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              ruta['nombre']?.toString() ?? 'Sin nombre',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Ver detalles',
                                            icon: const Icon(Icons.visibility, color: Colors.purple),
                                            onPressed: () => _goToDetails(index),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Origen: ${ruta['origen'] ?? ''}'),
                                      Text('Destino: ${ruta['destino'] ?? ''}'),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          const Icon(Icons.route, size: 18, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Ruta: ${ruta['id_ruta'] ?? ''}',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              (ruta['duracion_estimada']?.toString() ?? '').isEmpty
                                                  ? 'Duración N/D'
                                                  : 'Duración: ${ruta['duracion_estimada']}',
                                              style: const TextStyle(color: Colors.purple),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
        ],
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Messajesscreen()),
                  );
                },
                child: _bottomIcon(Icons.chat_bubble),
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

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}