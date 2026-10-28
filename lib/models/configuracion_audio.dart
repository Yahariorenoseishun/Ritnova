// Clase "ConfiguracionAudio" de tu diagrama.
// Es "static" para que el valor se conserve al cambiar de pantalla
// y el juego pueda leerlo después.
class ConfiguracionAudio {
  static double volumenMusica = 80;
  static double volumenEfectos = 50;
  static double velocidad = 10.0;

  // Compensación de sincronía en milisegundos (de -300 a 300).
  // Positivo = las teclas llegan más tarde (úsalo si oyes el sonido tarde).
  static double desfaseMs = 0;
}