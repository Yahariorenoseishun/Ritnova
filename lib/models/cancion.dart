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

// Catálogo de canciones (en tu diagrama de datos es el catálogo estático)
final Map<String, Cancion> canciones = {
  'demo': Cancion(
    id: 'demo',
    titulo: 'Demo RITNOVA',
    archivo: 'cancion_demo.wav',
    bpm: 120,
    patron: patronDesdeTexto(
      bpm: 120,
      inicio: 2.0, // el primer compás es solo de cuenta previa
      texto: '''
        1.2.3.2. | 1.2.3.4. | 4.3.2.1. | 1.3.2.4. |
        12.34.21 | 1.2.c--- | 43.21.34 | a---3.4. |
        1.2.3.4. | 2.3.4.3. | 12.34.43 | b---1.3. |
        1234.321 | d---2.1. | 1.2.3.4. | c-------
      ''',
    ),
  ),
};
