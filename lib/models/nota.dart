// Una nota del patrón de una canción
class Nota {
  final double tiempo; // segundo en que debe tocarse
  final int carril; // de 0 a 3
  final double duracion; // 0 = tecla normal; más de 0 = tecla larga (en segundos)

  const Nota(this.tiempo, this.carril, [this.duracion = 0]);
}

// Convierte un patrón escrito como texto en una lista de notas.
// - Cada carácter es media pulsación (una corchea).
// - 1, 2, 3, 4 = tecla normal en ese carril.   . = silencio.
// - a, b, c, d = tecla LARGA en el carril 1, 2, 3 o 4.
//   Cada "-" que la sigue la alarga una corchea.
// - La barra | y los espacios solo ordenan el texto (se ignoran).
List<Nota> patronDesdeTexto({
  required double bpm,
  required double inicio, // segundo en que empieza el patrón
  required String texto,
}) {
  final paso = 60 / bpm / 2; // duración de un carácter, en segundos
  final limpio = texto.replaceAll(RegExp(r'[\s|]'), '');
  final notas = <Nota>[];
  int i = 0;
  while (i < limpio.length) {
    final c = limpio[i];
    if ('1234'.contains(c)) {
      // tecla normal
      notas.add(Nota(inicio + i * paso, int.parse(c) - 1));
      i++;
    } else if ('abcd'.contains(c)) {
      // tecla larga: cuenta cuántos "-" la siguen
      int largo = 1;
      while (i + largo < limpio.length && limpio[i + largo] == '-') {
        largo++;
      }
      final carril = c.codeUnitAt(0) - 'a'.codeUnitAt(0);
      notas.add(Nota(inicio + i * paso, carril, largo * paso));
      i += largo; // salta los "-" que ya usó
    } else {
      i++; // silencio u otro carácter
    }
  }
  return notas;
}

// Patrón de prueba sin canción (por si un nivel no tiene audio)
final patronPrueba = [
  for (int i = 0; i < 24; i++)
    Nota(3.0 + i * 0.75, [0, 2, 1, 3, 1, 2][i % 6]),
];