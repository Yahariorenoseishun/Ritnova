import 'package:flame/game.dart' show GameWidget;
import 'package:material_ui/material_ui.dart';
import '../game/ritnova_game.dart';
import '../models/cancion.dart';
import '../models/nivel.dart';
import '../models/nota.dart';
import '../models/partida.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class JuegoScreen extends StatefulWidget {
  final Nivel nivel; // el nivel que el jugador eligió

  const JuegoScreen({super.key, required this.nivel});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  late final RitnovaGame _juego;

  @override
  void initState() {
    super.initState();
    // Busca la canción del nivel y le pasa su patrón y su audio al juego
    final cancion = canciones[widget.nivel.cancionId];
    _juego = RitnovaGame(
      patron: cancion?.patron ?? patronPrueba,
      archivoAudio: cancion?.archivo,
    );
  }

  @override
  void dispose() {
    _juego.detener(); // por si sales con la música sonando
    super.dispose();
  }

  String _texto(Juicio? j) {
    if (j == Juicio.perfect) return 'PERFECT';
    if (j == Juicio.great) return 'GREAT';
    if (j == Juicio.bad) return 'BAD';
    if (j == Juicio.miss) return 'MISS';
    return '';
  }

  Color _color(Juicio? j) {
    if (j == Juicio.perfect) return AppColors.secondary;
    if (j == Juicio.great) return AppColors.primary;
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
                          Center(child: Text('FIN', style: AppText.titulo)),
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