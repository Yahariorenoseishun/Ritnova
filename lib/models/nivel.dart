// Clase "Nivel" de tu diagrama de clases
class Nivel {
  final String nombre;
  final int dificultad; // de 1 a 5 estrellas
  final String cancionId; // qué canción usa (ver cancion.dart)

  const Nivel(this.nombre, this.dificultad, this.cancionId);
}

// Datos de prueba. Por ahora todos usan la canción demo.
const niveles = [
  Nivel('MUSIC-1', 2, 'demo'),
  Nivel('MUSIC-2', 4, 'demo'),
  Nivel('MUSIC-3', 3, 'demo'),
];

const favoritosDemo = [
  Nivel('FAV - 1', 4, 'demo'),
  Nivel('FAV - 2', 3, 'demo'),
];