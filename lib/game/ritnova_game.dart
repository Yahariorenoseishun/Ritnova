import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import '../models/configuracion_audio.dart';
import '../models/nota.dart';
import '../models/partida.dart';
import '../theme/app_colors.dart';
import 'escenario.dart';
import 'tecla.dart';

// El "motor" del juego (el Controlador de tu MVC).
class RitnovaGame extends FlameGame with TapCallbacks {
  static const int carriles = 4;

  // Ventanas de tiempo (en segundos) de cada juicio
  static const double ventanaPerfect = 0.05;
  static const double ventanaGreat = 0.10;
  static const double ventanaBad = 0.16;
  static const double ventanaToque = 0.35;

  // Si sientes las teclas desfasadas de la música, ajusta este número
  // (en segundos). Positivo = la música arranca más temprano.
  static const double desfaseAudio = 0.0;

  final List<Nota> patron; // las notas de la canción
  final String? archivoAudio; // null = sin música
  final Partida partida = Partida();
  double tiempo = 0; // reloj de la partida, en segundos
  int _siguiente = 0; // cuál es la próxima nota por mostrar
  bool _musicaIniciada = false;
  bool _detenido = false;

  RitnovaGame({required this.patron, this.archivoAudio});

  @override
  Color backgroundColor() => AppColors.base;

  @override
  Future<void> onLoad() async {
    add(Escenario());
    // Carga los sonidos antes de empezar para que no haya retraso
    await FlameAudio.audioCache.loadAll([
      'tap.wav',
      if (archivoAudio != null) archivoAudio!,
    ]);
    // Arranca el reloj antes de 0 para dar tiempo a que caigan las primeras teclas
    final primera = patron.first.tiempo - tiempoCaida;
    tiempo = (primera < 0 ? primera : 0) - 1;
  }

  // Segundos que tarda una tecla en caer (depende de la velocidad de OPCIONES)
  double get tiempoCaida => 25 / ConfiguracionAudio.velocidad;

  double get yZona => size.y * 0.80;

  // x del borde de un carril. t = 0 arriba, t = 1 en la zona de toque.
  double xBorde(int borde, double t) {
    final anchoArriba = size.x * 0.22;
    final anchoAbajo = size.x * 0.70;
    final ancho = anchoArriba + (anchoAbajo - anchoArriba) * t;
    final izquierda = (size.x - ancho) / 2;
    return izquierda + ancho * borde / carriles;
  }

  // Detiene la música (al terminar o al salir de la pantalla)
  void detener() {
    if (_detenido) return;
    _detenido = true;
    if (_musicaIniciada) {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.dispose();
    }
  }

  @override
  void update(double dt) {
    if (partida.terminada) {
      detener();
      pauseEngine();
      return;
    }
    tiempo += dt;
    super.update(dt);

    // Cuando el reloj llega a 0, empieza la canción
    if (!_musicaIniciada && archivoAudio != null && tiempo >= -desfaseAudio) {
      _musicaIniciada = true;
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play(
        archivoAudio!,
        volume: ConfiguracionAudio.volumenMusica / 100,
      );
    }

    // Crea las teclas que ya toca mostrar
    while (_siguiente < patron.length &&
        tiempo >= patron[_siguiente].tiempo - tiempoCaida) {
      final nota = patron[_siguiente];
      add(Tecla(carril: nota.carril, tiempoObjetivo: nota.tiempo));
      _siguiente++;
    }

    // Si ya no quedan notas ni teclas en pantalla, se acabó
    if (_siguiente >= patron.length && children.whereType<Tecla>().isEmpty) {
      partida.terminar();
    }
  }

  // Se ejecuta cada vez que el jugador toca la pantalla
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
    partida.registrar(_juzgar(mejor));
    elegida.removeFromParent();
    // Sonido del toque, con el volumen de efectos de OPCIONES
    FlameAudio.play('tap.wav', volume: ConfiguracionAudio.volumenEfectos / 100);
  }

  Juicio _juzgar(double diferencia) {
    if (diferencia <= ventanaPerfect) return Juicio.perfect;
    if (diferencia <= ventanaGreat) return Juicio.great;
    if (diferencia <= ventanaBad) return Juicio.bad;
    return Juicio.miss;
  }
}