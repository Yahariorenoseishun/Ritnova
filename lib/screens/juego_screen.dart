import 'package:flame/game.dart' show GameWidget;
import 'package:material_ui/material_ui.dart';
import '../game/ritnova_game.dart';
import '../models/cancion.dart';
import '../models/nivel.dart';
import '../models/nota.dart';
import '../models/partida.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'resultado_screen.dart';

class JuegoScreen extends StatefulWidget {
  final Nivel nivel; // el nivel que el jugador eligió

  const JuegoScreen({super.key, required this.nivel});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  late final RitnovaGame _juego;
  bool _yaNavego = false; // evita abrir RESULTADO dos veces
  bool _esRecord = false; // se llena al terminar el nivel

  @override
  void initState() {
    super.initState();
    // Busca la canción del nivel y le pasa su patrón y su audio al juego
    final cancion = canciones[widget.nivel.cancionId];
    _juego = RitnovaGame(
      patron: cancion?.patron ?? patronPrueba,
      archivoAudio: cancion?.archivo,
    );
    // Se entera cada vez que la partida cambia (para saber cuándo termina)
    _juego.partida.addListener(_alCambiarPartida);
  }

  // Cuando la partida termina: guarda el puntaje y pasa a RESULTADO
  void _alCambiarPartida() {
    if (_juego.partida.terminada && !_yaNavego) {
      _yaNavego = true;
      // Solo cuenta como récord si completaste el nivel (te quedó vida)
      if (_juego.partida.vida > 0) {
        _esRecord = Progreso.instancia
            .registrarPuntaje(widget.nivel.id, _juego.partida.puntaje);
      }
      Future.delayed(const Duration(milliseconds: 1800), _irAResultado);
    }
  }

  void _irAResultado() {
    if (!mounted) return; // si ya saliste de la pantalla, no hace nada
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadoScreen(
          partida: _juego.partida,
          nivel: widget.nivel,
          esRecord: _esRecord,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _juego.partida.removeListener(_alCambiarPartida);
    _juego.detener(); // por si sales con la música sonando
    super.dispose();
  }

  String _texto(Juicio? j) {
    if (j == Juicio.perfect) return 'PERFECT';
    if (j == Juicio.great) return 'GREAT';
    if (j == Juicio.bad) return 'BAD';
    if (j == Juicio.miss) return 'MISS';
    if (j == Juicio.hold) return 'HOLD!';    return '';
  }

  Color _color(Juicio? j) {
    if (j == Juicio.perfect) return AppColors.secondary;
    if (j == Juicio.great) return AppColors.primary;
    if (j == Juicio.hold) return AppColors.secondary;
    if (j == Juicio.bad) return AppColors.textMuted;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _juego)),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListenableBuilder(
                  listenable: _juego.partida,
                  builder: (context, _) {
                    final p = _juego.partida;
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PTS: ${p.puntaje}',
                                  style: AppText.subtitulo
                                      .copyWith(color: AppColors.secondary)),
                              if (p.combo > 1)
                                Text('COMBO x${p.combo}',
                                    style: AppText.etiqueta
                                        .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite,
                                  color: AppColors.error, size: 24),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 160,
                                child: LinearProgressIndicator(
                                  value: p.vida / 100,
                                  minHeight: 10,
                                  color: AppColors.primary,
                                  backgroundColor: AppColors.surface,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.pause_circle_filled,
                                color: AppColors.text, size: 40),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.3),
                          child: Text(_texto(p.ultimoJuicio),
                              style: AppText.titulo
                                  .copyWith(color: _color(p.ultimoJuicio))),
                        ),
                        if (p.terminada)
                          Center(
                            child: Text(p.vida > 0 ? 'COMPLETADO' : 'FIN',
                                style: AppText.titulo),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}