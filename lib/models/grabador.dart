import 'dart:math';

// Un toque grabado: cuándo, en qué carril y cuánto duró presionado
class Toque {
  final double tiempo; // segundos desde el inicio de la canción
  final int carril; // de 0 a 3
  double duracion; // segundos que el dedo estuvo presionado

  Toque(this.tiempo, this.carril, [this.duracion = 0]);
}

// Convierte los toques grabados en un patrón de texto (el mismo formato
// que usa patronDesdeTexto): cada carácter es una corchea.
String patronATexto({
  required List<Toque> toques,
  required double bpm,
  required double inicio,
}) {
  final paso = 60 / bpm / 2; // duración de una corchea
  final celdas = <int, String>{}; // número de corchea -> carácter
  int ultimo = 0;

  final orden = [...toques]..sort((a, b) => a.tiempo.compareTo(b.tiempo));
  for (final t in orden) {
    final i = ((t.tiempo - inicio) / paso).round(); // en qué corchea cae
    if (i < 0 || celdas.containsKey(i)) continue; // antes del inicio o casilla ocupada

    if (t.duracion >= 0.4) {
      // Mantuvo el dedo: tecla larga (letra a-d y guiones)
      int largo = (t.duracion / paso).round();
      if (largo < 2) largo = 2;
      int usado = 1;
      while (usado < largo && !celdas.containsKey(i + usado)) {
        usado++;
      }
      celdas[i] = String.fromCharCode('a'.codeUnitAt(0) + t.carril);
      for (int k = 1; k < usado; k++) {
        celdas[i + k] = '-';
      }
      ultimo = max(ultimo, i + usado - 1);
    } else {
      celdas[i] = '${t.carril + 1}'; // tecla normal: 1 a 4
      ultimo = max(ultimo, i);
    }
  }
  if (celdas.isEmpty) return '';

  // Completa el último compás (8 corcheas) y arma los compases
  final total = ((ultimo + 1 + 7) ~/ 8) * 8;
  final compases = <String>[];
  for (int b = 0; b < total; b += 8) {
    final sb = StringBuffer();
    for (int k = b; k < b + 8; k++) {
      sb.write(celdas[k] ?? '.');
    }
    compases.add(sb.toString());
  }

  // 4 compases por línea
  final lineas = <String>[];
  for (int i = 0; i < compases.length; i += 4) {
    lineas.add(compases.skip(i).take(4).join(' | '));
  }
  return lineas.join(' |\n');
}

// El texto completo listo para pegar dentro de cancion.dart
String fragmentoDart({
  required List<Toque> toques,
  required double bpm,
  required double inicio,
}) {
  final texto = patronATexto(toques: toques, bpm: bpm, inicio: inicio);
  final lineas = texto.split('\n').map((l) => '        $l').join('\n');
  const comillas = "'''";
  return 'patron: patronDesdeTexto(\n'
      '  bpm: ${bpm.toStringAsFixed(1)},\n'
      '  inicio: ${inicio.toStringAsFixed(2)},\n'
      '  texto: $comillas\n'
      '$lineas\n'
      '  $comillas,\n'
      '),';
}