import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import 'inicio_screen.dart';

// Pantalla de carga: el logo y una barra de 10 segmentos que se va llenando
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const int total = 10; // segmentos de la barra
  int _llenos = 0; // cuántos van llenos
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    // Cada 220 ms se llena un segmento más; al terminar pasa a INICIO
    _reloj = Timer.periodic(const Duration(milliseconds: 220), (timer) {
      if (_llenos < total) {
        setState(() => _llenos++);
      } else {
        timer.cancel();
        _entrar();
      }
    });
  }

  void _entrar() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InicioScreen()),
    );
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/ritnova_logo.png', height: 150),
            const SizedBox(height: 24),
            // Marco naranja con los segmentos adentro
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < total; i++)
                    Container(
                      width: 24,
                      height: 16,
                      margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        // Los llenos son naranjas y los últimos 3, amarillos
                        color: i < _llenos
                            ? (i < 7 ? AppColors.primary : AppColors.secondary)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(3),
                      ),
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