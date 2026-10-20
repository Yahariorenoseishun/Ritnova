import 'package:flutter/foundation.dart';

// Los 4 resultados posibles de un toque
enum Juicio { perfect, great, bad, miss }

// Clase "Partida" de tu diagrama. Es un ChangeNotifier: cada vez que algo
// cambia, avisa a la pantalla para que se actualice sola.
class Partida extends ChangeNotifier {
  int puntaje = 0;
  int combo = 0;
  int comboMaximo = 0;
  int vida = 100;
  int perfects = 0;
  int greats = 0;
  int bads = 0;
  int misses = 0;
  bool terminada = false;
  Juicio? ultimoJuicio; // el "?" significa que al inicio puede estar vacío

  int get fallos => bads + misses;

  // Aplica tus reglas de juego según el juicio
  void registrar(Juicio juicio) {
    ultimoJuicio = juicio;
    switch (juicio) {
      case Juicio.perfect:
        puntaje += 100;
        perfects++;
        combo++;
      case Juicio.great:
        puntaje += 50;
        greats++;
        combo++;
      case Juicio.bad:
        vida -= 5;
        bads++;
        combo = 0;
      case Juicio.miss:
        vida -= 10;
        misses++;
        combo = 0;
    }
    if (combo > comboMaximo) comboMaximo = combo;
    if (vida <= 0) {
      vida = 0;
      terminada = true;
    }
    notifyListeners(); // avisa a la pantalla que hubo cambios
  }

  // Se usa cuando se acaban las notas
  void terminar() {
    terminada = true;
    notifyListeners();
  }
}