import 'package:flutter/material.dart';
import '../Services/mysql_service.dart';
import 'Home_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codigoController = TextEditingController();
  bool _loading = false;

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _login() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _showMessage('Por favor ingresa tu código');
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await MySQLService.instance.loginOperador(codigo);
      if (success) {
        _showMessage('Bienvenido', success: true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(codigo: codigo),
          ),
        );
      } else {
        _showMessage('Código incorrecto ❌');
      }
    } catch (e) {
      debugPrint("⚠️ Error: $e");
      _showMessage('Error al conectar con la base de datos');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Limitamos el ancho máximo del formulario
          double width = constraints.maxWidth * 0.8;
          if (width > 400) width = 400;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _codigoController,
                      decoration: const InputDecoration(
                        labelText: "Código",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text("Ingresar"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
