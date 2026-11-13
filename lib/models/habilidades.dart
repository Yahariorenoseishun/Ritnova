class Habilidades {
  // Ayudas
  static bool concentracion = false; // los fallos quitan la mitad de vida
  static bool comboExperto = false; // cada 10 de combo devuelve 5 de vida
  static bool margenAmplio = false; // ventanas de tiempo 25% más amplias
  // Retos
  static bool nerviosismo = false; // los fallos quitan 50% más de vida
  static bool precision = false; // ventanas de tiempo 25% más estrictas
  static bool rompeCombos = false; // las teclas caen 25% más rápido

  // Cuánto se multiplican los puntos con todas las habilidades activas
  static double get multiplicador {
    double m = 1.0;
    if (concentracion) m *= 0.90;
    if (comboExperto) m *= 0.90;
    if (margenAmplio) m *= 0.85;
    if (nerviosismo) m *= 1.10;
    if (precision) m *= 1.15;
    if (rompeCombos) m *= 1.20;
    return m;
  }

  // Cuánta vida se pierde por un fallo (1.0 = normal)
  static double get factorDano =>
      (concentracion ? 0.5 : 1.0) * (nerviosismo ? 1.5 : 1.0);

  // Qué tan anchas son las ventanas de Perfect, Great y Bad (1.0 = normal)
  static double get factorVentana =>
      (margenAmplio ? 1.25 : 1.0) * (precision ? 0.75 : 1.0);

  // Qué tan rápido caen las teclas (1.0 = normal)
  static double get factorVelocidad => rompeCombos ? 1.25 : 1.0;

  // Nombres de las habilidades activas (para mostrarlas en RESULTADO)
  static List<String> get activas {
    final lista = <String>[];
    if (concentracion) lista.add('Concentración');
    if (comboExperto) lista.add('Combo experto');
    if (margenAmplio) lista.add('Margen amplio');
    if (nerviosismo) lista.add('Nerviosismo');
    if (precision) lista.add('Precisión');
    if (rompeCombos) lista.add('Rompedor de combos');
    return lista;
  }
}