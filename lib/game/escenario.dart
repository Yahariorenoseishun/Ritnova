import 'dart:ui';
import 'package:flame/components.dart';
import '../theme/app_colors.dart';
import 'ritnova_game.dart';

// Dibuja las líneas de los carriles y la barra de la zona de toque
class Escenario extends Component with HasGameReference<RitnovaGame> {
  final Paint _linea = Paint()
    ..color = AppColors.secondary.withAlpha(110)
    ..strokeWidth = 2;

  final Paint _zona = Paint()
    ..color = AppColors.primary
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  @override
  void render(Canvas canvas) {
    final alto = game.size.y;
    // Progreso que alcanzan las líneas al llegar al borde inferior de la pantalla
    final tFinal = alto / game.yZona;

    // 5 líneas: los bordes de los 4 carriles
    for (int i = 0; i <= RitnovaGame.carriles; i++) {
      canvas.drawLine(
        Offset(game.xBorde(i, 0), 0),
        Offset(game.xBorde(i, tFinal), alto),
        _linea,
      );
    }

    // Barra de la zona de toque: queda dentro de las líneas de los carriles
    // (se deja la mitad del grosor de la línea para que no se salga)
    final mitad = _zona.strokeWidth / 2;
    final barra = RRect.fromLTRBR(
      game.xBorde(0, 1) + mitad,
      game.yZona - 12,
      game.xBorde(RitnovaGame.carriles, 1) - mitad,
      game.yZona + 12,
      const Radius.circular(6),
    );
    canvas.drawRRect(barra, _zona);
  }
}