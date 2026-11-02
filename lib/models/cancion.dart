import 'nota.dart';

// Clase "Cancion" de tu diagrama: el audio y su patrón de notas
class Cancion {
  final String id;
  final String titulo;
  final String archivo; // nombre del audio dentro de assets/audio
  final double bpm;
  final List<Nota> patron;

  Cancion({
    required this.id,
    required this.titulo,
    required this.archivo,
    required this.bpm,
    required this.patron,
  });
}

// Catálogo de canciones. También se llena solo al abrir la app
// (ver catalogo.dart).
final Map<String, Cancion> canciones = {};