import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ConfigScreen.dart';
import 'Home_Screen.dart';
import 'MapsScreen.dart';
import 'MessajesScreen.dart';
import '../Services/mysql_service.dart';

class ParadasScreen extends StatefulWidget {
  final String ruta;

  const ParadasScreen({super.key, required this.ruta});

  @override
  State<ParadasScreen> createState() => _ParadasScreenState();
}

class _ParadasScreenState extends State<ParadasScreen> {
  late GoogleMapController _mapController;

  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(19.8165058, -97.3656139),
    zoom: 13.0,
  );

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

  final MySQLService _db = MySQLService.instance;

  List<Map<String, dynamic>> _paradas = [];
  late List<bool> _selected;
  bool _loading = true;
  String? _error;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadParadas();
  }

  Future<void> _loadParadas() async {
    try {
      final data = await _db.getParadasByRutaNombre(widget.ruta);
      _paradas = data
          .map((p) => {
        'name': p['nombre']?.toString() ?? 'Parada',
        'post': LatLng(
          (p['latitud'] as num).toDouble(),
          (p['longitud'] as num).toDouble(),
        ),
      })
          .toList();
      _selected = List<bool>.filled(_paradas.length, false);
      _loading = false;
      _error = null;

      _updateMarkers();
      _updatePolylines();

      if (_paradas.isNotEmpty) {
        final first = _paradas.first['post'] as LatLng;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(first, 14.0),
          );
        });
      }
      setState(() {});
    } catch (e) {
      _loading = false;
      _error = 'Error al cargar paradas: $e';
      setState(() {});
    }
  }

  void _updateMarkers() {
    _markers.clear();
    for (int i = 0; i < _paradas.length; i++) {
      final parada = _paradas[i];
      final position = parada['post'] as LatLng;

      _markers.add(
        Marker(
          markerId: MarkerId('p$i'),
          position: position,
          infoWindow: InfoWindow(title: parada['name']),
        ),
      );
    }
    setState(() {});
  }

  void _updatePolylines() {
    _polylines.clear();
    final points = <LatLng>[];
    for (int i = 0; i < _paradas.length; i++) {
      if (_selected[i]) points.add(_paradas[i]['post'] as LatLng);
    }
    if (points.length >= 2) {
      _polylines.add(Polyline(
        polylineId: const PolylineId('selected_route'),
        points: points,
        width: 5,
        color: Colors.blue,
      ));
    }
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleSelection(int index, bool? value) {
    setState(() {
      _selected[index] = value ?? !_selected[index];
    });
    _updateMarkers();
    _updatePolylines();

    if (_selected[index]) {
      final position = _paradas[index]['post'] as LatLng;
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 15.0));
    }
  }

  void _fitBoundsSelected() {
    final selectedPoints = <LatLng>[];
    for (int i = 0; i < _paradas.length; i++) {
      if (_selected[i]) selectedPoints.add(_paradas[i]['post'] as LatLng);
    }

    if (selectedPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay paradas seleccionadas')),
      );
      return;
    }

    final first = selectedPoints.first;
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(first, 14.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Paradas de ${widget.ruta}"),
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
              }),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isWide = w >= 600;

        final sidePanel = Container(
          color: Colors.purple[50],
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paradas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_error != null)
                    ? Center(child: Text(_error!))
                    : ListView.separated(
                  itemCount: _paradas.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final name = _paradas[index]['name'] as String;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          'P${index + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      title: Text(name),
                      trailing: Checkbox(
                        value: _selected[index],
                        onChanged: (val) =>
                            _toggleSelection(index, val),
                      ),
                      onTap: () => _toggleSelection(
                          index, !_selected[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _fitBoundsSelected,
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Centrar seleccion'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selected =
                        List<bool>.filled(_paradas.length, false);
                      });
                      _updateMarkers();
                      _updatePolylines();
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              )
            ],
          ),
        );

        final map = GoogleMap(
          initialCameraPosition: _initialCamera,
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 2, child: sidePanel),
              Expanded(flex: 3, child: map),
            ],
          );
        } else {
          final h = MediaQuery.of(context).size.height;
          final panelHeight = h * 0.45;
          return Column(
            children: [
              Expanded(child: map),
              SizedBox(
                height: panelHeight,
                child: sidePanel,
              )
            ],
          );
        }
      }),
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
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MapsScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar'),
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