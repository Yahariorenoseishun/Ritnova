import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'cancion.dart';
import 'nivel.dart';
import 'nota.dart';

// Lee los niveles de la carpeta assets/niveles.
// Cada nivel es un archivo .json creado con el editor de niveles.
class Catalogo {
  // Una nota del archivo: [tiempo, carril, duración, tipo, ancho, texto]
  // Solo los tres primeros datos son obligatorios.
  static Nota _leerNota(List n) {
    final ancho = n.length > 4 ? (n[4] as num).toInt().clamp(1, 4).toInt() : 1;
    final carril = (n[1] as num).toInt().clamp(0, 4 - ancho).toInt();
    return Nota(
      (n[0] as num).toDouble(),
      carril,
      (n[2] as num).toDouble(),
      n.length > 3 ? (n[3] as num).toInt() : 0,
      ancho,
      n.length > 5 ? (n[5] as String) : '',
    );
  }

  static Future<void> cargar() async {
    niveles.clear();
    canciones.clear();

    // Lista de todos los archivos que trae la app
    final manifiesto = await AssetManifest.loadFromAssetBundle(rootBundle);
    final archivos = manifiesto.listAssets();
    final rutas = archivos
        .where((r) => r.startsWith('assets/niveles/') && r.endsWith('.json'))
        .toList()
      ..sort(); // orden alfabético
    debugPrint('JSON encontrados: ${rutas.length}');

    for (final ruta in rutas) {
      try {
        final datos =
            jsonDecode(await rootBundle.loadString(ruta)) as Map<String, dynamic>;
        final id = datos['id'] as String;
        final audio = datos['audio'] as String;

        final notas = <Nota>[
          for (final n in datos['notas'] as List) _leerNota(n as List),
        ]..sort((a, b) => a.tiempo.compareTo(b.tiempo));

        if (notas.isEmpty) {
          debugPrint('Nivel $ruta ignorado: no tiene notas');
          continue;
        }
        if (!archivos.contains('assets/audio/$audio')) {
          debugPrint('Nivel $ruta ignorado: falta assets/audio/$audio');
          continue;
        }

        final nombre = (datos['nombre'] as String?) ?? id;
        canciones[id] = Cancion(
          id: id,
          titulo: nombre,
          archivo: audio,
          bpm: (datos['bpm'] as num?)?.toDouble() ?? 120,
          patron: notas,
        );
        niveles.add(Nivel(id, nombre.toUpperCase(),
            (datos['dificultad'] as num?)?.toInt() ?? 1, id));
      } catch (e) {
        debugPrint('No se pudo leer $ruta: $e');
      }
    }
    // Orden: primero los más fáciles; si empatan, por nombre
    niveles.sort((a, b) => a.dificultad != b.dificultad
        ? a.dificultad.compareTo(b.dificultad)
        : a.nombre.compareTo(b.nombre));
    debugPrint('Niveles cargados: ${niveles.length}');
  }
}