// Clase "Nivel" de tu diagrama de clases
class Nivel {
  final String id; // no cambia nunca: así los favoritos no se rompen
  final String nombre;
  final int dificultad; // de 1 a 5 estrellas
  final String cancionId; // qué canción usa (ver cancion.dart)

  const Nivel(this.id, this.nombre, this.dificultad, this.cancionId);
}

// Catálogo de niveles. Por ahora todos usan la canción demo.
const niveles = [
  Nivel('music-1', 'MUSIC-1', 2, 'demo'),
  Nivel('music-2', 'MUSIC-2', 4, 'demo'),
  Nivel('music-3', 'MUSIC-3', 3, 'demo'),
];