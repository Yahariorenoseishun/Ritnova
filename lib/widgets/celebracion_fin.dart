import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

// Animación al terminar un nivel: anillos de luz y un mensaje que "salta" al centro
class CelebracionFin extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final Color color;

  const CelebracionFin({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.color,
  });

  @override
  State<CelebracionFin> createState() => _CelebracionFinState();
}

class _CelebracionFinState extends State<CelebracionFin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control;

  @override
  void initState() {
    super.initState();
    _control = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  // Mantiene un número entre 0 y 1
  double _acotar(double v) => v < 0 ? 0.0 : (v > 1 ? 1.0 : v);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _control,
      builder: (context, _) {
        final t = _control.value; // va de 0 a 1 durante 2 segundos
        final aparece = _acotar(t / 0.2); // el fondo y el texto se aclaran al inicio
        final salto = Curves.elasticOut.transform(_acotar(t / 0.5)); // el texto "salta"
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.base.withAlpha((170 * aparece).round()),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(painter: _AnillosPainter(t, widget.color)),
            ),
            Center(
              child: Opacity(
                opacity: aparece,
                child: Transform.scale(
                  scale: 0.4 + 0.6 * salto,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.titulo,
                        textAlign: TextAlign.center,
                        style: AppText.titulo
                            .copyWith(fontSize: 46, color: widget.color),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitulo,
                        style: AppText.subtitulo
                            .copyWith(fontSize: 20, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Dibuja tres anillos que se expanden y se desvanecen
class _AnillosPainter extends CustomPainter {
  final double t;
  final Color color;

  _AnillosPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radioMax = size.longestSide * 0.5;
    for (int i = 0; i < 3; i++) {
      final p = (t - 0.05 - i * 0.12) / 0.6; // avance de este anillo (0 a 1)
      if (p <= 0 || p >= 1) continue;
      final colorAnillo = i == 1 ? AppColors.primary : color;
      canvas.drawCircle(
        centro,
        radioMax * p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7 - 4 * p
          ..color = colorAnillo.withAlpha((255 * (1 - p)).round()),
      );
    }
  }

  @override
  bool shouldRepaint(_AnillosPainter anterior) => anterior.t != t;
}