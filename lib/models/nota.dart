// Una nota del patrón de una canción: cuándo se toca y en qué carril
class Nota {
  final double tiempo; // segundo en que debe tocarse
  final int carril; // de 0 a 3

  const Nota(this.tiempo, this.carril);
}

// Convierte un patrón escrito como texto en una lista de notas.
// - Cada carácter es media pulsación (una corchea).
// - 1, 2, 3, 4 = tecla en ese carril.   . = silencio.
// - La barra | y los espacios solo ordenan el texto (se ignoran).
List<Nota> patronDesdeTexto({
  required double bpm,
  required double inicio, // segundo en que empieza el patrón
  required String texto,
}) {
  final paso = 60 / bpm / 2; // duración de un carácter, en segundos
  final limpio = texto.replaceAll(RegExp(r'[\s|]'), '');
  final notas = <Nota>[];
  for (int i = 0; i < limpio.length; i++) {
    final c = limpio[i];
    if (c == '1' || c == '2' || c == '3' || c == '4') {
      notas.add(Nota(inicio + i * paso, int.parse(c) - 1));
    }
  }
  return notas;
}

// Patrón de prueba sin canción (por si un nivel no tiene audio)
final patronPrueba = [
  for (int i = 0; i < 24; i++)
    Nota(3.0 + i * 0.75, [0, 2, 1, 3, 1, 2][i % 6]),
];