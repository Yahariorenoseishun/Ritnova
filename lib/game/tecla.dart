import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import '../models/habilidades.dart';
import '../models/partida.dart';
import '../theme/app_colors.dart';
import 'ritnova_game.dart';

// Una tecla que cae. Puede ser normal o larga, de 1 a 4 carriles de ancho,
// de un tipo (color) y con una sílaba escrita encima.
class Tecla extends Component with HasGameReference<RitnovaGame> {
  // Colores por tipo: 0 usa el color del carril, 1 voz, 2 instrumento, 3 coro
  static const List<Color> _coloresTipo = [
    Color(0x00000000),
    Color(0xFF4DD6FF),
    Color(0xFFFF5FA2),
    Color(0xFF5BE08A),
  ];

    // Poner en true para ver la sílaba escrita sobre cada tecla
  static const bool mostrarTexto = false;

  final int carril; // carril donde empieza
  final int ancho; // cuántos carriles cubre
  final int tipo;
  final String texto;
  final double tiempoObjetivo; // segundo en que debe tocarse la cabeza
  final double duracion; // 0 = normal; más de 0 = larga

  double progreso = 0; // posición de la cabeza (0 = arriba, 1 = zona de toque)
  double progresoCola = 0; // posición del final de una tecla larga
  bool resuelta = false; // la cabeza ya se juzgó
  bool sosteniendo = false; // el jugador la está manteniendo presionada
  bool fallida = false; // se falló: se dibuja en gris
  int? dedo; // qué dedo la está sosteniendo
  ui.Paragraph? _parrafo; // el texto ya preparado para dibujar

  Tecla({
    required this.carril,
    required this.tiempoObjetivo,
    this.duracion = 0,
    this.ancho = 1,
    this.tipo = 0,
    this.texto = '',
  }) {
    if (texto.isNotEmpty) {
      final constructor = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        maxLines: 1,
        ellipsis: '…',
      ))
        ..pushStyle(ui.TextStyle(
          color: AppColors.text,
          fontSize: 40,
          fontWeight: ui.FontWeight.w700,
        ))
        ..addText(texto);
      _parrafo = constructor.build()
        ..layout(const ui.ParagraphConstraints(width: 300));
    }
  }

  bool get esLarga => duracion > 0;
  double get tiempoFin => tiempoObjetivo + duracion; // cuándo termina la larga

  // Color normal de la tecla: por tipo, o por carril si es tipo 0
  Color get _colorBase => (tipo > 0 && tipo < _coloresTipo.length)
      ? _coloresTipo[tipo]
      : (carril.isEven ? AppColors.secondary : AppColors.primary);

  // Tecla larga mantenida hasta el final: suma el bonus y desaparece
  void _completar() {
    sosteniendo = false;
    game.partida.registrar(Juicio.hold);
    removeFromParent();
  }

  // Lo llama el juego cuando el jugador levanta el dedo
  void soltar() {
    if (!sosteniendo) return;
    if (game.tiempo >= tiempoFin - RitnovaGame.margenSoltar) {
      _completar(); // soltó justo al final: cuenta como completada
    } else {
      sosteniendo = false; // soltó antes de tiempo: cuenta como Bad
      fallida = true;
      game.partida.registrar(Juicio.bad);
    }
  }

  @override
  void update(double dt) {
    final t = game.tiempo;
    progreso = 1 - (tiempoObjetivo - t) / game.tiempoCaida;
    progresoCola = 1 - (tiempoFin - t) / game.tiempoCaida;

    // La cabeza pasó de largo sin que la tocaran: Miss
    if (!resuelta &&
        t - tiempoObjetivo >
            RitnovaGame.ventanaBad * Habilidades.factorVentana) {
      resuelta = true;
      fallida = true;
      game.partida.registrar(Juicio.miss);
    }

    // Tecla larga mantenida hasta el final: ¡completada!
    if (sosteniendo && t >= tiempoFin - RitnovaGame.margenSoltar) {
      _completar();
      return;
    }

    // Cuando ya salió de la pantalla, se elimina
    final salida = esLarga ? progresoCola : progreso;
    if (salida > 1.2) {
      removeFromParent();
    }
  }

  // x del borde izquierdo o derecho de la tecla (con un pequeño margen)
  double _borde(double p, {required bool izquierda}) {
    final i = game.xBorde(carril, p);
    final d = game.xBorde(carril + ancho, p);
    final margen = (d - i) * 0.03;
    return izquierda ? i + margen : d - margen;
  }

  @override
  void render(Canvas canvas) {
    final color = fallida ? AppColors.textMuted : _colorBase;

    // Mientras la sostienes, la cabeza se queda pegada a la zona de toque
    final cabeza = (esLarga && sosteniendo) ? 1.0 : progreso;

    // Cuerpo de la tecla larga: un trapecio desde la cola hasta la cabeza
    if (esLarga) {
      final cola = progresoCola < 0 ? 0.0 : progresoCola; // lo de arriba no se ve
      if (cola < cabeza) {
        final cuerpo = Path()
          ..moveTo(_borde(cola, izquierda: true), cola * game.yZona)
          ..lineTo(_borde(cola, izquierda: false), cola * game.yZona)
          ..lineTo(_borde(cabeza, izquierda: false), cabeza * game.yZona)
          ..lineTo(_borde(cabeza, izquierda: true), cabeza * game.yZona)
          ..close();
        canvas.drawPath(cuerpo, Paint()..color = color.withAlpha(110));
      }
    }

    // Cabeza de la tecla: una barra delgada que cubre todos sus carriles
    final izq = game.xBorde(carril, cabeza);
    final der = game.xBorde(carril + ancho, cabeza);
    final anchoTotal = der - izq;
    final unidad = anchoTotal / ancho; // ancho de un solo carril a esta altura
    final alto = unidad * 0.18;
    final forma = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset((izq + der) / 2, cabeza * game.yZona),
        width: anchoTotal * 0.94,
        height: alto,
      ),
      Radius.circular(alto / 3),
    );
    canvas.drawRRect(forma, Paint()..color = color);

    // Borde blanco mientras se sostiene
    if (sosteniendo) {
      canvas.drawRRect(
        forma,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.text,
      );
    }

    // La sílaba, escrita encima de la tecla
    final parrafo = _parrafo;
    if (mostrarTexto && parrafo != null && !fallida) {
      final escala = unidad / 170; // el texto crece al acercarse, igual que la tecla
      canvas.save();
      canvas.translate(
          (izq + der) / 2, cabeza * game.yZona - alto / 2 - 26 * escala);
      canvas.scale(escala);
      canvas.drawParagraph(parrafo, Offset(-150, -parrafo.height / 2));
      canvas.restore();
    }
  }
}