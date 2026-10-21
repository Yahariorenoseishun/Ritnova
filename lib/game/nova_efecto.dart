import 'dart:ui';
import 'package:flame/components.dart';
import '../theme/app_colors.dart';
import 'ritnova_game.dart';

// Efecto "nova": anillos de luz que se expanden desde la zona de toque
// y se van desvaneciendo.
class NovaEfecto extends Component with HasGameReference<RitnovaGame> {
  static const double duracion = 0.9; // segundos
  double _edad = 0; // cuánto tiempo lleva el efecto

  @override
  void update(double dt) {
    _edad += dt;
    if (_edad >= duracion) removeFromParent(); // cuando termina, se elimina
  }

  @override
  void render(Canvas canvas) {
    final avance = _edad / duracion; // va de 0 a 1
    final centro = Offset(game.size.x / 2, game.yZona);
    final radioMaximo = game.size.x * 0.45;
    final opacidad = ((1 - avance) * 255).round(); // se desvanece

    // Anillo amarillo
    canvas.drawCircle(
      centro,
      radioMaximo * avance,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = AppColors.secondary.withAlpha(opacidad),
    );
    // Anillo naranja, un poco más pequeño
    canvas.drawCircle(
      centro,
      radioMaximo * avance * 0.7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = AppColors.primary.withAlpha(opacidad),
    );
    // Destello blanco en el centro
    canvas.drawCircle(
      centro,
      30 * (1 - avance) + 6,
      Paint()..color = AppColors.text.withAlpha((opacidad * 0.6).round()),
    );
  }
}