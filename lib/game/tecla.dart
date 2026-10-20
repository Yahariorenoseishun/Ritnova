import 'dart:ui';
import 'package:flame/components.dart';
import '../models/partida.dart';
import '../theme/app_colors.dart';
import 'ritnova_game.dart';

// Una tecla que cae. Su posición sale del reloj de la partida.
class Tecla extends Component with HasGameReference<RitnovaGame> {
  final int carril;
  final double tiempoObjetivo; // segundo en que debe tocarse
  double progreso = 0; // 0 = arriba, 1 = en la zona de toque
  bool resuelta = false; // ya se tocó o ya se falló

  Tecla({required this.carril, required this.tiempoObjetivo});

  @override
  void update(double dt) {
    // Qué tan cerca está de la zona, según el reloj
    progreso = 1 - (tiempoObjetivo - game.tiempo) / game.tiempoCaida;

    // Si pasó el tiempo límite y nadie la tocó, es Miss
    if (!resuelta && game.tiempo - tiempoObjetivo > RitnovaGame.ventanaBad) {
      resuelta = true;
      game.partida.registrar(Juicio.miss);
    }

    // Cuando ya salió de la pantalla, se elimina
    if (progreso > 1.2) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final izquierda = game.xBorde(carril, progreso);
    final derecha = game.xBorde(carril + 1, progreso);
    final anchoCarril = derecha - izquierda;

    final ancho = anchoCarril * 0.94;
    final alto = anchoCarril * 0.18;
    final centroX = (izquierda + derecha) / 2;
    final centroY = progreso * game.yZona;

    final forma = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centroX, centroY),
        width: ancho,
        height: alto,
      ),
      Radius.circular(alto / 3),
    );

    // Gris si ya se falló, de color si todavía se puede tocar
    final color = resuelta
        ? AppColors.textMuted
        : (carril.isEven ? AppColors.secondary : AppColors.primary);
    canvas.drawRRect(forma, Paint()..color = color);
  }
}