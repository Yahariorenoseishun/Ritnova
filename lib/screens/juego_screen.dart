import 'dart:async';
import 'dart:ui' show AppLifecycleState;
import 'package:flame/game.dart' show GameWidget;
import 'package:material_ui/material_ui.dart';
import '../audio/musica_menu.dart';
import '../game/ritnova_game.dart';
import '../models/cancion.dart';
import '../models/nivel.dart';
import '../models/nota.dart';
import '../models/partida.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/boton_pildora.dart';
import '../widgets/celebracion_fin.dart';
import 'resultado_screen.dart';

class JuegoScreen extends StatefulWidget {
  final Nivel nivel; // el nivel que el jugador eligió

  const JuegoScreen({super.key, required this.nivel});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

// "with WidgetsBindingObserver" permite enterarse de cuando la app sale a segundo plano
class _JuegoScreenState extends State<JuegoScreen> with WidgetsBindingObserver {
  late final RitnovaGame _juego;
  bool _yaNavego = false; // evita abrir RESULTADO dos veces
  bool _esRecord = false; // se llena al terminar el nivel
  bool _pausa = false; // el menú de pausa está abierto
  int? _cuenta; // 3, 2, 1 mientras se reanuda
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MusicaMenu.pedirSilencio(); // la música del menú se calla mientras juegas
    // Busca la canción del nivel y le pasa su patrón y su audio al juego
    final cancion = canciones[widget.nivel.cancionId];
    _juego = RitnovaGame(
      patron: cancion?.patron ?? patronPrueba,
      archivoAudio: cancion?.archivo,
    );
    // Se entera cada vez que la partida cambia (para saber cuándo termina)
    _juego.partida.addListener(_alCambiarPartida);
  }

  // Si la app pasa a segundo plano (otra app, llamada, notificación), se pausa sola
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado != AppLifecycleState.resumed) _pausar();
  }

  void _pausar() {
    if (_pausa || _juego.partida.terminada) return;
    _reloj?.cancel();
    _juego.pausar();
    setState(() {
      _pausa = true;
      _cuenta = null;
    });
  }

  // Cuenta regresiva 3, 2, 1 y luego sigue el juego
  void _continuar() {
    if (_cuenta != null) return;
    setState(() => _cuenta = 3);
    _reloj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cuenta! > 1) {
        setState(() => _cuenta = _cuenta! - 1);
      } else {
        timer.cancel();
        _juego.reanudar();
        setState(() {
          _cuenta = null;
          _pausa = false;
        });
      }
    });
  }

  void _reiniciar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => JuegoScreen(nivel: widget.nivel)),
    );
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
      // Si completaste, se deja más tiempo para disfrutar la animación
      final espera = _juego.partida.vida > 0 ? 3200 : 1800;
      Future.delayed(Duration(milliseconds: espera), _irAResultado);
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
    WidgetsBinding.instance.removeObserver(this);
    _reloj?.cancel();
    _juego.partida.removeListener(_alCambiarPartida);
    _juego.detener(); // por si sales con la música sonando
    MusicaMenu.liberarSilencio(); // vuelve la música del menú
    super.dispose();
  }

  // Mensaje del final según cómo te fue: título, subtítulo y color
  (String, String, Color) _mensajeFin(Partida p) {
    if (p.vida <= 0) {
      return ('NIVEL FALLIDO', 'Inténtalo de nuevo', AppColors.error);
    }
    if (p.perfects > 0 && p.greats == 0 && p.bads == 0 && p.misses == 0) {
      return ('ALL PERFECT', '¡Ni un solo fallo!', AppColors.secondary);
    }
    if (p.bads == 0 && p.misses == 0) {
      return ('FULL COMBO', 'Sin fallos', AppColors.secondary);
    }
    return ('NIVEL COMPLETADO', '¡Buen trabajo!', AppColors.primary);
  }

  String _texto(Juicio? j) {
    if (j == Juicio.perfect) return 'PERFECT';
    if (j == Juicio.great) return 'GREAT';
    if (j == Juicio.bad) return 'BAD';
    if (j == Juicio.miss) return 'MISS';
    if (j == Juicio.hold) return 'HOLD!';
    return '';
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
    // PopScope intercepta el botón "atrás": durante la partida pausa en lugar de salir
    return PopScope(
      canPop: _pausa,
      onPopInvokedWithResult: (didPop, resultado) {
        if (didPop) return;
        if (_juego.partida.terminada) {
          Navigator.pop(context);
        } else {
          _pausar();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: GameWidget(
                game: _juego,
                // Si algo falla al cargar el nivel, se muestra un mensaje claro
                errorBuilder: (context, error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No se pudo cargar este nivel.\n'
                      'Revisa que el audio y el archivo .json existan y se llamen igual.\n\n'
                      '$error',
                      textAlign: TextAlign.center,
                      style: AppText.etiqueta.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ),
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
                              onPressed: _pausar,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0, 0.3),
                            child: Text(_texto(p.ultimoJuicio),
                                style: AppText.titulo
                                    .copyWith(color: _color(p.ultimoJuicio))),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            // Animación al terminar el nivel (cubre toda la pantalla)
            Positioned.fill(
              child: IgnorePointer(
                child: ListenableBuilder(
                  listenable: _juego.partida,
                  builder: (context, _) {
                    final p = _juego.partida;
                    if (!p.terminada) return const SizedBox.shrink();
                    final m = _mensajeFin(p);
                    return CelebracionFin(
                        titulo: m.$1, subtitulo: m.$2, color: m.$3);
                  },
                ),
              ),
            ),
            // Menú de pausa (tapa todo el juego, así los toques no llegan a las teclas)
            if (_pausa)
              Positioned.fill(
                child: Container(
                  color: const Color(0xE6171717),
                  child: Center(
                    child: _cuenta != null
                        ? Text('$_cuenta',
                            style: AppText.titulo
                                .copyWith(fontSize: 80, color: AppColors.primary))
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('PAUSA', style: AppText.titulo),
                                const SizedBox(height: 16),
                                BotonPildora(
                                    texto: 'CONTINUAR', onTap: _continuar),
                                const SizedBox(height: 10),
                                BotonPildora(
                                    texto: 'REINICIAR', onTap: _reiniciar),
                                const SizedBox(height: 10),
                                BotonPildora(
                                  texto: 'SALIR',
                                  onTap: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}