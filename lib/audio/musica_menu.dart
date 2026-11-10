import 'dart:ui' show AppLifecycleState;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/configuracion_audio.dart';

// Música de fondo de los menús. Se detiene mientras juegas
// y vuelve al salir del nivel.
class MusicaMenu with WidgetsBindingObserver {
  static final MusicaMenu _unica = MusicaMenu._();
  MusicaMenu._();

  final AudioPlayer _reproductor = AudioPlayer();
  bool _iniciada = false; // ya se pidió cargar la canción
  bool _lista = false; // la canción ya está cargada
  bool _enSegundoPlano = false;
  int _silencios = 0; // cuántas pantallas piden silencio (el juego)

  double get _volumen => ConfiguracionAudio.volumenMusica / 100 * 0.7;

  // Se llama una vez al abrir la app
  static Future<void> iniciar() => _unica._iniciar();

  // El juego pide silencio al abrirse y lo libera al cerrarse
  static void pedirSilencio() {
    _unica._silencios++;
    _unica._actualizar();
  }

  static void liberarSilencio() {
    if (_unica._silencios > 0) _unica._silencios--;
    _unica._actualizar();
  }

  // Aplica el volumen de OPCIONES al instante
  static void actualizarVolumen() {
    if (_unica._lista) _unica._reproductor.setVolume(_unica._volumen);
  }

  Future<void> _iniciar() async {
    if (_iniciada) return;
    _iniciada = true;
    try {
      WidgetsBinding.instance.addObserver(this);
      await _reproductor.setReleaseMode(ReleaseMode.loop); // se repite sin parar
      await _reproductor.setVolume(_volumen);
      await _reproductor.setSource(AssetSource('audio/menu.wav'));
      _lista = true;
      _actualizar();
    } catch (e) {
      debugPrint('No se pudo cargar la música del menú: $e');
    }
  }

  // Suena solo si nadie pidió silencio y la app está a la vista
  void _actualizar() {
    if (!_lista) return;
    if (_silencios == 0 && !_enSegundoPlano) {
      _reproductor.resume();
    } else {
      _reproductor.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    _enSegundoPlano = estado != AppLifecycleState.resumed;
    _actualizar();
  }
}