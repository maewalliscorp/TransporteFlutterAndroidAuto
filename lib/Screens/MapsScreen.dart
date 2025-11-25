import 'package:flutter/material.dart';

import 'ConfigScreen.dart';
import 'Home_Screen.dart';
import 'MessajesScreen.dart';
import 'TimeScreen.dart';
import '../Responsive/responsive.dart'; // <- utilidades responsivas

class MapsScreen extends StatelessWidget {
  final String codigo;
  const MapsScreen({super.key, required this.codigo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(codigo: codigo),
            Expanded(
              child: Stack(
                children: [
                  // Fondo: imagen de assets
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/navegation.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Overlay opcional: línea de ruta azul
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _RoutePainter(),
                      ),
                    ),
                  ),

                  // Flecha de navegación al centro
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Barra inferior
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomBar(codigo: codigo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- TopBar ----------------------
class _TopBar extends StatelessWidget {
  final String codigo;
  const _TopBar({required this.codigo});

  @override
  Widget build(BuildContext context) {
    final wide = isWideWidth(MediaQuery.of(context).size.width);

    return Container(
      color: Colors.purple,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 24 : 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          const _TopIcon(icon: Icons.send),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Timescreen(
                      ruta: {'nombre': 'Android Auto'},
                      codigo: codigo),
                ),
              );
            },
            child: const _TopIcon(icon: Icons.alarm),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Android Auto',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: wide ? 20 : 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConfigScreen(codigo: codigo)),
              );
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(codigo: codigo)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  const _TopIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

// ---------------------- BottomBar ----------------------
class _BottomBar extends StatelessWidget {
  final String codigo;
  const _BottomBar({required this.codigo});

  @override
  Widget build(BuildContext context) {
    final wide = isWideWidth(MediaQuery.of(context).size.width);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 16 : 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomIcon(icon: Icons.mic),
            const SizedBox(width: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Messajesscreen(codigo: codigo)),
                );
              },
              child: _BottomIcon(icon: Icons.chat_bubble),
            ),

            const SizedBox(width: 16),
            _BottomIcon(icon: Icons.notifications),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 20 : 16,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Messajesscreen(codigo: codigo)),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(wide ? 'Mensajes' : 'Msg'),
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
            _SquareButton(icon: Icons.remove),
            const SizedBox(width: 8),
            _SquareButton(icon: Icons.add),
          ],
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  const _BottomIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
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
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  const _SquareButton({required this.icon});

  @override
  Widget build(BuildContext context) {
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
}

// Pintor de la línea de ruta azul
class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = const Color(0xFF1E88E5)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final cx = size.width * 0.55;
    path.moveTo(cx, size.height * 0.95);
    path.lineTo(cx, size.height * 0.6);
    path.cubicTo(
      cx, size.height * 0.5,
      cx - 40, size.height * 0.45,
      cx - 10, size.height * 0.35,
    );
    path.lineTo(cx - 10, size.height * 0.1);

    final outline = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, outline);

    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
