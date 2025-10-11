import 'package:android_auto/Screens/Home_Screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Services/mysql_service.dart';
import 'ConfigScreen.dart';
import 'MessajesScreen.dart';
import 'Paradas_screen.dart';

class DetailsRoutsScreen extends StatefulWidget {
  final Map<String, dynamic> ruta;

  const DetailsRoutsScreen({super.key, required this.ruta});

  @override
  State<DetailsRoutsScreen> createState() => _DetailsRoutsScreenState();
}

class _DetailsRoutsScreenState extends State<DetailsRoutsScreen> {
  late GoogleMapController _mapController;
  Map<String, dynamic>? _rutaDetalle;
  String? _error;
  bool _cargando = true;
  final MySQLService _db = MySQLService();

  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(19.8165058, -97.3656139),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _cargarRutaDetalle();
  }

  Future<void> _cargarRutaDetalle() async {
    try {
      await _db.connect();
      Map<String, dynamic>? data;

      // Prioriza por id si viene en el Map
      if (widget.ruta['id_ruta'] != null) {
        final id = int.tryParse(widget.ruta['id_ruta'].toString());
        if (id != null) {
          data = await _db.getRutaById(id);
        }
      }

      // Si no hay id o no se encontró, intenta por nombre
      if (data == null && widget.ruta['nombre'] != null) {
        data = await _db.getRutaByNombre(widget.ruta['nombre'].toString());
      }

      setState(() {
        _rutaDetalle = data;
        _cargando = false;
        if (data == null) _error = 'No se encontró la ruta solicitada';
      });
    } catch (e) {
      setState(() {
        _error = 'Error al conectar: $e';
        _cargando = false;
      });
    }
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final ruta = widget.ruta;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de ${ruta['nombre']}"),
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
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.purple[50],
              padding: const EdgeInsets.all(16),
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                  ? Center(child: Text(_error!))
                  : (_rutaDetalle == null)
                  ? const Center(child: Text('No hay datos para esta ruta'))
                  : Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _rutaDetalle!['nombre']?.toString() ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Ruta: ${_rutaDetalle!['id_ruta']}'),
                      Text('Horario: ${_rutaDetalle!['id_horario']}'),
                      Text('Origen: ${_rutaDetalle!['origen']}'),
                      Text('Destino: ${_rutaDetalle!['destino']}'),
                      Text('Duración Estimada: ${_rutaDetalle!['duracion_estimada']}'),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ParadasScreen(
                                  ruta: _rutaDetalle!['nombre']?.toString() ?? '',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Ver Paradas'),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                child: const Icon(Icons.graphic_eq, color: Colors.black, size: 24),
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