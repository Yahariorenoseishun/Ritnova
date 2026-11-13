import 'package:flutter/foundation.dart';
import 'habilidades.dart';

// Los resultados posibles. "hold" = tecla larga mantenida hasta el final.
enum Juicio { perfect, great, bad, miss, hold }

// Clase "Partida" de tu diagrama. Es un ChangeNotifier: cada vez que algo
// cambia, avisa a la pantalla para que se actualice sola.
class Partida extends ChangeNotifier {
  static const int vidaMaxima = 100; // vida con la que empieza cada partida

  // Se fijan al empezar la partida, según las habilidades que estén activas
  final double multiplicador = Habilidades.multiplicador;
  final double _factorDano = Habilidades.factorDano;
  final bool _comboExperto = Habilidades.comboExperto;
  final List<String> habilidades = Habilidades.activas;

  int puntaje = 0;
  int combo = 0;
  int comboMaximo = 0;
  int vida = vidaMaxima;
  int perfects = 0;
  int greats = 0;
  int bads = 0;
  int misses = 0;
  int holds = 0;
  double _sumaDiferencias = 0; // suma de qué tan tarde (+) o temprano (-) tocaste
  int _cantidadDiferencias = 0;
  bool terminada = false;
  Juicio? ultimoJuicio; // el "?" significa que al inicio puede estar vacío

  int get fallos => bads + misses;

  // Puntos de un acierto, ya multiplicados por las habilidades
  int _puntos(int base) => (base * multiplicador).round();

  // Vida que se pierde por un fallo (nunca menos de 1)
  int _perdida(int base) {
    final v = (base * _factorDano).round();
    return v < 1 ? 1 : v;
  }

  void _curar(int cantidad) {
    vida += cantidad;
    if (vida > vidaMaxima) vida = vidaMaxima;
  }

  // Combo experto: cada 10 de combo devuelve 5 de vida
  void _premioCombo() {
    if (_comboExperto && combo % 10 == 0) _curar(5);
  }

  // Aplica tus reglas de juego según el juicio
  void registrar(Juicio juicio) {
    ultimoJuicio = juicio;
    switch (juicio) {
      case Juicio.perfect:
        puntaje += _puntos(100);
        perfects++;
        combo++;
        _curar(1); // un Perfect devuelve 1 de vida
        _premioCombo();
      case Juicio.great:
        puntaje += _puntos(50);
        greats++;
        combo++;
        _premioCombo();
      case Juicio.bad:
        vida -= _perdida(5);
        bads++;
        combo = 0;
      case Juicio.miss:
        vida -= _perdida(10);
        misses++;
        combo = 0;
      case Juicio.hold:
        puntaje += _puntos(100); // bonus por mantener la tecla larga hasta el final
        holds++;
    }
    if (combo > comboMaximo) comboMaximo = combo;
    if (vida <= 0) {
      vida = 0;
      terminada = true;
    }
    notifyListeners(); // avisa a la pantalla que hubo cambios
  }

  // Guarda qué tan lejos del momento exacto fue un toque (en segundos; + = tarde)
  void registrarDiferencia(double segundos) {
    _sumaDiferencias += segundos;
    _cantidadDiferencias++;
  }

  // Promedio de todos tus toques, en milisegundos (sirve para calibrar)
  int get promedioMs => _cantidadDiferencias == 0
      ? 0
      : (_sumaDiferencias / _cantidadDiferencias * 1000).round();

  // Se usa cuando se acaban las notas
  void terminar() {
    terminada = true;
    notifyListeners();
  }
}