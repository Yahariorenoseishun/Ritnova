// Clase "Nivel" de tu diagrama de clases
class Nivel {
  final String id; // no cambia nunca: así los favoritos no se rompen
  final String nombre;
  final int dificultad; // de 1 a 5 estrellas
  final String cancionId; // qué canción usa (ver cancion.dart)

  const Nivel(this.id, this.nombre, this.dificultad, this.cancionId);
}

// Lista de niveles. Se llena sola al abrir la app, leyendo los archivos
// de la carpeta assets/niveles (ver catalogo.dart).
final List<Nivel> niveles = [];