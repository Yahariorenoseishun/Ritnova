import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'configuracion_audio.dart';

// Guarda y lee lo que debe quedarse en el teléfono:
// ajustes, favoritos y mejores puntajes.
// Es un ChangeNotifier: cuando algo cambia, avisa a las pantallas.
class Progreso extends ChangeNotifier {
  static final Progreso instancia = Progreso(); // una sola copia para toda la app

  late SharedPreferences _prefs; // el "cuaderno" del teléfono
  Set<String> _favoritos = {}; // ids de los niveles favoritos

  // Se llama una vez, al abrir la app: lee todo lo guardado
  Future<void> cargar() async {
    _prefs = await SharedPreferences.getInstance();
    _favoritos = (_prefs.getStringList('favoritos') ?? []).toSet();
    // Si no hay nada guardado, usa los valores de siempre (el "??")
    ConfiguracionAudio.volumenMusica = _prefs.getDouble('volumenMusica') ?? 80;
    ConfiguracionAudio.volumenEfectos = _prefs.getDouble('volumenEfectos') ?? 50;
    ConfiguracionAudio.velocidad = _prefs.getDouble('velocidad') ?? 10.0;
    ConfiguracionAudio.desfaseMs = _prefs.getDouble('desfaseMs') ?? 0;
  }

  // ---------- Ajustes ----------
  void guardarAjustes() {
    _prefs.setDouble('volumenMusica', ConfiguracionAudio.volumenMusica);
    _prefs.setDouble('volumenEfectos', ConfiguracionAudio.volumenEfectos);
    _prefs.setDouble('velocidad', ConfiguracionAudio.velocidad);
    _prefs.setDouble('desfaseMs', ConfiguracionAudio.desfaseMs);
  }

  // ---------- Favoritos (por id del nivel) ----------
  bool esFavorito(String idNivel) => _favoritos.contains(idNivel);

  void alternarFavorito(String idNivel) {
    if (_favoritos.contains(idNivel)) {
      _favoritos.remove(idNivel);
    } else {
      _favoritos.add(idNivel);
    }
    _prefs.setStringList('favoritos', _favoritos.toList());
    notifyListeners(); // las listas se redibujan solas
  }

  // ---------- Mejor puntaje de cada nivel ----------
  int mejorPuntaje(String idNivel) => _prefs.getInt('mejor_$idNivel') ?? 0;

  // Guarda el puntaje si supera al anterior. Devuelve true si es récord.
  bool registrarPuntaje(String idNivel, int puntaje) {
    if (puntaje > mejorPuntaje(idNivel)) {
      _prefs.setInt('mejor_$idNivel', puntaje);
      notifyListeners();
      return true;
    }
    return false;
  }
}