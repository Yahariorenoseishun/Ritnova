import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart' show AudioPlayer;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import '../models/configuracion_audio.dart';
import '../models/nota.dart';
import '../models/partida.dart';
import '../theme/app_colors.dart';
import 'escenario.dart';
import 'nova_efecto.dart';
import 'tecla.dart';

// El "motor" del juego (el Controlador de tu MVC).
class RitnovaGame extends FlameGame with TapCallbacks {
  static const int carriles = 4;

  // Ventanas de tiempo (en segundos) de cada juicio
  static const double ventanaPerfect = 0.05;
  static const double ventanaGreat = 0.10;
  static const double ventanaBad = 0.16;
  static const double ventanaToque = 0.35;

  // Una tecla larga cuenta como completada si la sueltas
  // en este último margen antes de que termine (en segundos)
  static const double margenSoltar = 0.10;

  // Combos que disparan el efecto "nova"
  static const List<int> hitosCombo = [10, 25, 50, 75, 100];

  final List<Nota> patron; // las notas de la canción
  final String? archivoAudio; // null = sin música
  final Partida partida = Partida();
  double tiempo = 0; // reloj de la partida, en segundos
  int _siguiente = 0; // cuál es la próxima nota por mostrar
  bool _musicaIniciada = false;
  bool _detenido = false;
  AudioPlayer? _musica; // el reproductor de ESTA partida

  // Última posición que reportó la canción, y cuándo la reportó
  StreamSubscription<Duration>? _suscripcionPos;
  double _posAudio = 0;
  DateTime _momentoPos = DateTime.now();
  bool _hayPos = false;

  RitnovaGame({required this.patron, this.archivoAudio});

  @override
  Color backgroundColor() => AppColors.base;

  @override
  Future<void> onLoad() async {
    add(Escenario());
    // Carga los sonidos antes de empezar para que no haya retraso
    await FlameAudio.audioCache.loadAll([
      'nova.wav',
      if (archivoAudio != null) archivoAudio!,
    ]);
    // Arranca el reloj antes de 0 para dar tiempo a que caigan las primeras teclas
    final primera = patron.first.tiempo - tiempoCaida;
    tiempo = (primera < 0 ? primera : 0) - 1;
  }

  // Segundos que tarda una tecla en caer (depende de la velocidad de OPCIONES)
  double get tiempoCaida => 25 / ConfiguracionAudio.velocidad;

  // Compensación de sincronía de OPCIONES, convertida a segundos
  double get desfase => ConfiguracionAudio.desfaseMs / 1000;

  double get yZona => size.y * 0.80;

  // x del borde de un carril. t = 0 arriba, t = 1 en la zona de toque.
  double xBorde(int borde, double t) {
    final anchoArriba = size.x * 0.22;
    final anchoAbajo = size.x * 0.70;
    final ancho = anchoArriba + (anchoAbajo - anchoArriba) * t;
    final izquierda = (size.x - ancho) / 2;
    return izquierda + ancho * borde / carriles;
  }

  // Arranca la canción con un reproductor propio de esta partida
  Future<void> _iniciarMusica() async {
    final reproductor = await FlameAudio.playLongAudio(
      archivoAudio!,
      volume: ConfiguracionAudio.volumenMusica / 100,
    );
    _musica = reproductor;
    if (_detenido) {
      reproductor.dispose(); // saliste antes de que arrancara
      return;
    }
    // La canción avisa varias veces por segundo en qué posición va
    _suscripcionPos = reproductor.onPositionChanged.listen((posicion) {
      _posAudio = posicion.inMicroseconds / 1000000;
      _momentoPos = DateTime.now();
      _hayPos = true;
    });
  }

  // Corta la música (al perder o al salir de la pantalla)
  void detener() {
    if (_detenido) return;
    _detenido = true;
    _suscripcionPos?.cancel();
    _musica?.dispose(); // detiene y libera el reproductor
  }

  // Efecto nova: sonido más anillos de luz
  void _nova() {
    add(NovaEfecto());
    FlameAudio.play('nova.wav', volume: ConfiguracionAudio.volumenEfectos / 100);
  }

  @override
  void update(double dt) {
    if (partida.terminada) {
      if (partida.vida <= 0) detener(); // si perdiste, la música se corta
      pauseEngine();
      return;
    }
    tiempo += dt;

    // Mantiene el reloj del juego pegado a la posición real de la canción
    if (_hayPos) {
      final transcurrido =
          DateTime.now().difference(_momentoPos).inMicroseconds / 1000000;
      final posicion = _posAudio + transcurrido; // dónde va la canción ahora
      final error = (posicion - desfase) - tiempo;
      // Si se separan más de 80 ms, el reloj copia la posición de la canción
      if (error.abs() > 0.08) tiempo += error;
    }

    super.update(dt);

    // Cuando el reloj llega a 0, empieza la canción
    if (!_musicaIniciada && archivoAudio != null && tiempo >= 0) {
      _musicaIniciada = true;
      _iniciarMusica();
    }

    // Crea las teclas que ya toca mostrar (con su duración si son largas)
    while (_siguiente < patron.length &&
        tiempo >= patron[_siguiente].tiempo - tiempoCaida) {
      final nota = patron[_siguiente];
      add(Tecla(
        carril: nota.carril,
        tiempoObjetivo: nota.tiempo,
        duracion: nota.duracion,
      ));
      _siguiente++;
    }

    // Si ya no quedan notas ni teclas en pantalla, se acabó
    if (_siguiente >= patron.length && children.whereType<Tecla>().isEmpty) {
      partida.terminar();
    }
  }

  // Se ejecuta cada vez que el jugador apoya un dedo en la pantalla
  @override
  void onTapDown(TapDownEvent event) {
    if (partida.terminada) return;
    final x = event.localPosition.x;
    final t = event.localPosition.y / yZona;

    // ¿En qué carril tocó?
    int carril = -1;
    for (int i = 0; i < carriles; i++) {
      if (x >= xBorde(i, t) && x < xBorde(i + 1, t)) carril = i;
    }
    if (carril == -1) return;

    // Busca la tecla de ese carril más cercana en el tiempo
    Tecla? elegida;
    double mejor = ventanaToque;
    for (final tecla in children.whereType<Tecla>()) {
      if (tecla.carril != carril || tecla.resuelta) continue;
      final diferencia = (tiempo - tecla.tiempoObjetivo).abs();
      if (diferencia <= mejor) {
        mejor = diferencia;
        elegida = tecla;
      }
    }
    if (elegida == null) return;

    elegida.resuelta = true;
    final juicio = _juzgar(mejor);
    // Guarda si tocaste tarde (+) o temprano (-), para el promedio de RESULTADO
    if (juicio != Juicio.miss) {
      partida.registrarDiferencia(tiempo - elegida.tiempoObjetivo);
    }
    partida.registrar(juicio);

    if (elegida.esLarga) {
      if (juicio == Juicio.perfect || juicio == Juicio.great) {
        // Cabeza bien tocada: ahora hay que mantenerla presionada
        elegida.sosteniendo = true;
        elegida.dedo = event.pointerId; // recuerda cuál dedo la sostiene
      } else {
        elegida.fallida = true; // Bad o Miss: ya no se puede sostener
      }
    } else {
      elegida.removeFromParent(); // tecla normal: desaparece al tocarla
    }

    // Si el combo llegó a un hito, ¡nova!
    if (hitosCombo.contains(partida.combo)) _nova();
  }

  // El jugador levantó el dedo
  @override
  void onTapUp(TapUpEvent event) => _soltarDedo(event.pointerId);

  // El toque se canceló (se trata igual que levantar el dedo)
  @override
  void onTapCancel(TapCancelEvent event) => _soltarDedo(event.pointerId);

  // Avisa a la tecla larga que ese dedo ya no la está sosteniendo
  void _soltarDedo(int dedo) {
    for (final tecla in children.whereType<Tecla>().toList()) {
      if (tecla.sosteniendo && tecla.dedo == dedo) tecla.soltar();
    }
  }

  Juicio _juzgar(double diferencia) {
    if (diferencia <= ventanaPerfect) return Juicio.perfect;
    if (diferencia <= ventanaGreat) return Juicio.great;
    if (diferencia <= ventanaBad) return Juicio.bad;
    return Juicio.miss;
  }
}