import 'package:flutter/material.dart';
import 'Home_Screen.dart';
import 'MessajesScreen.dart';
import 'Rutas_Screen.dart';
import '../Responsive/responsive.dart';
import '../Services/mysql_service.dart';
import 'LoginScreen.dart';

class ConfigScreen extends StatefulWidget {
  final String codigo;
  const ConfigScreen({super.key, required this.codigo});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  Map<String, dynamic>? _perfil;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final p = await MySQLService.instance.getPerfilOperador(widget.codigo);
      setState(() {
        _perfil = p;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error al cargar perfil: $e';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await MySQLService.instance.close();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Widget _pillButton(BuildContext context, String text, {VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        onPressed: onTap ??
                () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
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

  Widget _perfilCard() {
    if (_loading) return const LinearProgressIndicator(minHeight: 2);
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_perfil == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No se encontró información del operador'),
      );
    }
    final nombre = (_perfil?['nombre'] ?? '—').toString();
    final email = (_perfil?['email'] ?? '—').toString();
    final licencia = (_perfil?['licencia'] ?? '—').toString();
    final telefono = (_perfil?['telefono'] ?? '—').toString();
    final codigo = (_perfil?['codigo'] ?? widget.codigo).toString();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Licencia: $licencia'),
                Text('Teléfono: $telefono'),
                Text('Código de Operador: $codigo'),
              ],
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Android Auto"),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(codigo: widget.codigo)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey[300],
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = isWideWidth(constraints.maxWidth);
              final maxBodyWidth = wide ? 1000.0 : 800.0;

              final buttons = <Widget>[
                _pillButton(context, 'Preferencias de notificaciones'),
                _pillButton(context, 'Preferencias de idioma/voz'),
                _pillButton(context, 'Información del vehículo o servicio'),
                _pillButton(context, 'Acerca de la aplicación'),
              ];

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxBodyWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        _perfilCard(),
                        const SizedBox(height: 12),
                        const Text(
                          'Configuración',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 24),
                        if (!wide) ...[
                          for (int i = 0; i < buttons.length; i++) ...[
                            buttons[i],
                            if (i != buttons.length - 1) const SizedBox(height: 18),
                          ],
                        ] else ...[
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: buttons
                                .map(
                                  (b) => SizedBox(
                                width: halfWrapWidth(constraints.maxWidth),
                                child: b,
                              ),
                            )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Messajesscreen(codigo: widget.codigo)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RutasScreen(codigo: widget.codigo)),
                  );
                },
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
}