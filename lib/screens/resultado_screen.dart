import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../models/partida.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/boton_lleno.dart';
import '../widgets/boton_pildora.dart';
import 'juego_screen.dart';

class ResultadoScreen extends StatelessWidget {
  final Partida partida; // los datos de la partida que acaba de terminar
  final Nivel nivel; // el nivel jugado (para poder reiniciarlo)
  final bool esRecord; // si se superó el mejor puntaje

  const ResultadoScreen({
    super.key,
    required this.partida,
    required this.nivel,
    required this.esRecord,
  });

  bool get _completado => partida.vida > 0; // si te quedó vida, terminaste la canción
  bool get _sinFallos => partida.bads == 0 && partida.misses == 0;

  // Precisión de 0 a 100 según los juicios obtenidos
  double get _precision {
    final total =
        partida.perfects + partida.greats + partida.bads + partida.misses;
    if (total == 0) return 0;
    return 100 *
        (partida.perfects + 0.6 * partida.greats + 0.2 * partida.bads) /
        total;
  }

  // Rango según la precisión (F si te quedaste sin vida)
  String get _rango {
    if (!_completado) return 'F';
    final p = _precision;
    if (p >= 95) return 'S';
    if (p >= 85) return 'A';
    if (p >= 70) return 'B';
    if (p >= 50) return 'C';
    return 'D';
  }

  Color get _colorRango {
    switch (_rango) {
      case 'S':
        return AppColors.secondary;
      case 'A':
        return AppColors.primary;
      case 'F':
        return AppColors.error;
      default:
        return AppColors.text;
    }
  }

  // Hace aparecer un widget deslizándolo y aclarándolo, con un retraso
  Widget _aparece({
    required Widget child,
    int retrasoMs = 0,
    Offset desde = const Offset(0, 14),
  }) {
    const duracion = 600;
    final inicio = retrasoMs / (retrasoMs + duracion);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: retrasoMs + duracion),
      curve: Interval(inicio, 1.0, curve: Curves.easeOutCubic),
      builder: (context, v, hijo) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(desde.dx * (1 - v), desde.dy * (1 - v)),
          child: hijo,
        ),
      ),
      child: child,
    );
  }

  // Un dato de la tarjeta: etiqueta pequeña arriba y valor grande abajo
  Widget _dato(String etiqueta, String valor, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta,
                style: AppText.etiqueta
                    .copyWith(fontSize: 11, color: AppColors.textMuted)),
            Text(valor,
                style: AppText.subtitulo.copyWith(fontSize: 24, color: color)),
          ],
        ),
      ),
    );
  }

  // Tarjeta con los datos de la partida
  Widget _tarjeta() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            _dato('PERFECT', '${partida.perfects}', AppColors.secondary),
            _dato('GREAT', '${partida.greats}', AppColors.primary),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _dato('BAD', '${partida.bads}', AppColors.textMuted),
            _dato('MISS', '${partida.misses}', AppColors.error),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _dato('COMBO MÁXIMO', '${partida.comboMaximo}', AppColors.text),
            _dato('PRECISIÓN', '${_precision.round()}%', AppColors.text),
          ]),
        ],
      ),
    );
  }

  // Círculo con el rango; "salta" al aparecer, después de contar los puntos
  Widget _rangoCirculo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: const Interval(0.55, 1.0, curve: Curves.elasticOut),
      builder: (context, v, hijo) => Transform.scale(scale: v, child: hijo),
      child: Container(
        width: 84,
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _colorRango, width: 4),
        ),
        child: Text(_rango,
            style: AppText.titulo.copyWith(fontSize: 44, color: _colorRango)),
      ),
    );
  }

  // Los puntos (cuentan desde 0), la insignia de récord y el promedio de toques
  Widget _puntos() {
    final mejor = Progreso.instancia.mejorPuntaje(nivel.id);
    final prom = partida.promedioMs;
    final textoProm = prom > 0 ? '+$prom' : '$prom';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PUNTOS',
            style: AppText.etiqueta
                .copyWith(fontSize: 12, color: AppColors.textMuted)),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: partida.puntaje.toDouble()),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Text('${v.round()}',
              style: AppText.titulo
                  .copyWith(fontSize: 48, color: AppColors.secondary)),
        ),
        const SizedBox(height: 4),
        if (esRecord)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text('¡NUEVO RÉCORD!',
                style: AppText.etiqueta
                    .copyWith(fontSize: 12, color: AppColors.base)),
          )
        else
          Text('MEJOR: $mejor',
              style: AppText.etiqueta
                  .copyWith(fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Text('Promedio de tus toques: $textoProm ms',
            style: AppText.etiqueta
                .copyWith(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitulo = (_completado && _sinFallos)
        ? '${nivel.nombre}  ·  FULL COMBO'
        : nivel.nombre;

    return Scaffold(
      body: SafeArea(
        child: Center(
          // FittedBox encoge el contenido si no cabe, así no hace falta scroll
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 780,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _aparece(
                      child: Text(
                        _completado ? 'NIVEL COMPLETADO' : 'NIVEL FALLIDO',
                        style: AppText.titulo.copyWith(fontSize: 30),
                      ),
                    ),
                    Text(subtitulo,
                        style: AppText.etiqueta
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _rangoCirculo(),
                              const SizedBox(width: 16),
                              _puntos(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _aparece(
                            retrasoMs: 250,
                            desde: const Offset(30, 0),
                            child: _tarjeta(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _aparece(
                      retrasoMs: 500,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BotonLleno(
                            texto: 'REINICIAR',
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => JuegoScreen(nivel: nivel)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          BotonPildora(
                            texto: 'SALIR',
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}