import 'package:material_ui/material_ui.dart';
import '../audio/musica_menu.dart';
import '../models/cancion.dart';
import '../models/configuracion_audio.dart';
import '../models/habilidades.dart';
import '../models/nivel.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/linea_borde.dart';
import 'juego_screen.dart';

// Pantalla previa a cada nivel: ajustes rápidos y habilidades antes de jugar
class PreNivelScreen extends StatefulWidget {
  final Nivel nivel;

  const PreNivelScreen({super.key, required this.nivel});

  @override
  State<PreNivelScreen> createState() => _PreNivelScreenState();
}

class _PreNivelScreenState extends State<PreNivelScreen> {
  // Al salir de esta pantalla se guardan los ajustes en el teléfono
  @override
  void dispose() {
    Progreso.instancia.guardarAjustes();
    super.dispose();
  }

  void _cambiarVelocidad(double cambio) {
    double nueva = ConfiguracionAudio.velocidad + cambio;
    if (nueva < 1.0) nueva = 1.0;
    if (nueva > 30.0) nueva = 30.0;
    setState(() => ConfiguracionAudio.velocidad = nueva);
  }

  void _cambiarDesfase(double cambio) {
    double nuevo = ConfiguracionAudio.desfaseMs + cambio;
    if (nuevo < -300) nuevo = -300;
    if (nuevo > 300) nuevo = 300;
    setState(() => ConfiguracionAudio.desfaseMs = nuevo);
  }

  // Aplica el cambio de una habilidad, redibuja y guarda
  void _cambiarHabilidad(VoidCallback cambio) {
    setState(cambio);
    Progreso.instancia.guardarHabilidades();
  }

  void _jugar() {
    Progreso.instancia.guardarAjustes();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JuegoScreen(nivel: widget.nivel)),
    );
  }

  // ---------- Piezas de la pantalla ----------

  // Barra de arriba: flecha, nombre del nivel, estrellas y mejor puntaje
  Widget _cabecera() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 24, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 26),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.nivel.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.subtitulo.copyWith(fontSize: 20),
            ),
          ),
          for (int i = 0; i < 5; i++)
            Icon(
              Icons.star,
              size: 20,
              color: i < widget.nivel.dificultad
                  ? AppColors.secondary
                  : AppColors.textMuted,
            ),
          const SizedBox(width: 16),
          ListenableBuilder(
            listenable: Progreso.instancia,
            builder: (context, _) {
              final mejor = Progreso.instancia.mejorPuntaje(widget.nivel.id);
              return Text(
                mejor > 0 ? 'MEJOR: $mejor' : 'SIN JUGAR',
                style: AppText.etiqueta
                    .copyWith(fontSize: 13, color: AppColors.secondary),
              );
            },
          ),
        ],
      ),
    );
  }

  // Tarjeta con fondo y título; el contenido ocupa el espacio que sobra
  Widget _tarjeta({required String titulo, required Widget hijo}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: AppText.etiqueta
                  .copyWith(fontSize: 13, color: AppColors.secondary)),
          const SizedBox(height: 6),
          Expanded(child: hijo),
        ],
      ),
    );
  }

  // Una barra de volumen en una sola línea
  Widget _filaVolumen(
      String titulo, double valor, ValueChanged<double> alCambiar) {
    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(titulo,
              style: AppText.etiqueta
                  .copyWith(fontSize: 13, color: AppColors.textMuted)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 5,
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.textMuted,
              thumbColor: AppColors.text,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(value: valor, min: 0, max: 100, onChanged: alCambiar),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text('${valor.round()}%',
              textAlign: TextAlign.right,
              style: AppText.etiqueta.copyWith(fontSize: 13)),
        ),
      ],
    );
  }

  // Botoncito circular con "-" o "+"
  Widget _mini(String simbolo, VoidCallback onTap) {
    return Material(
      color: AppColors.text,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: Text(simbolo,
                style: AppText.subtitulo
                    .copyWith(fontSize: 18, color: AppColors.base)),
          ),
        ),
      ),
    );
  }

  // Un ajuste con "-", el valor y "+"
  Widget _ajuste(
      String titulo, String valor, VoidCallback menos, VoidCallback mas) {
    return Row(
      children: [
        Expanded(
          child: Text(titulo,
              style: AppText.etiqueta
                  .copyWith(fontSize: 13, color: AppColors.textMuted)),
        ),
        _mini('-', menos),
        SizedBox(
          width: 66,
          child: Text(valor,
              textAlign: TextAlign.center,
              style: AppText.etiqueta
                  .copyWith(fontSize: 15, color: AppColors.primary)),
        ),
        _mini('+', mas),
      ],
    );
  }

  // Una habilidad: se enciende y se apaga al tocarla
  Widget _chip(String nombre, String mult, bool activo, VoidCallback alternar) {
    return GestureDetector(
      onTap: alternar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.base,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo ? AppColors.primary : const Color(0x33FFFFFF),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.etiqueta.copyWith(fontSize: 13)),
                  Text(mult,
                      style: AppText.etiqueta
                          .copyWith(fontSize: 11, color: AppColors.secondary)),
                ],
              ),
            ),
            Icon(
              activo ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: activo ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // Una columna de habilidades (ayudas o retos); los botones se reparten el alto
  Widget _columnaHab(String etiqueta, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta,
            style: AppText.etiqueta
                .copyWith(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        for (final c in chips)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: c,
            ),
          ),
      ],
    );
  }

  // Tarjeta izquierda: volúmenes, velocidad y sincronía
  Widget _tarjetaAjustes() {
    final d = ConfiguracionAudio.desfaseMs.round();
    return _tarjeta(
      titulo: 'AJUSTES',
      hijo: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _filaVolumen('MÚSICA', ConfiguracionAudio.volumenMusica, (v) {
            setState(() => ConfiguracionAudio.volumenMusica = v);
            MusicaMenu.actualizarVolumen();
          }),
          _filaVolumen('EFECTOS', ConfiguracionAudio.volumenEfectos, (v) {
            setState(() => ConfiguracionAudio.volumenEfectos = v);
          }),
          _ajuste(
            'VELOCIDAD',
            ConfiguracionAudio.velocidad.toStringAsFixed(1),
            () => _cambiarVelocidad(-0.5),
            () => _cambiarVelocidad(0.5),
          ),
          _ajuste(
            'SINCRONÍA',
            d > 0 ? '+$d ms' : '$d ms',
            () => _cambiarDesfase(-10),
            () => _cambiarDesfase(10),
          ),
        ],
      ),
    );
  }

  // Tarjeta central: habilidades (ayudas a la izquierda, retos a la derecha)
  Widget _tarjetaHabilidades() {
    return _tarjeta(
      titulo: 'HABILIDADES',
      hijo: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _columnaHab('AYUDAS', [
              _chip('Concentración', '×0.90', Habilidades.concentracion,
                  () => _cambiarHabilidad(() {
                        Habilidades.concentracion = !Habilidades.concentracion;
                        if (Habilidades.concentracion) {
                          Habilidades.nerviosismo = false;
                        }
                      })),
              _chip('Combo experto', '×0.90', Habilidades.comboExperto,
                  () => _cambiarHabilidad(() => Habilidades.comboExperto =
                      !Habilidades.comboExperto)),
              _chip('Margen amplio', '×0.85', Habilidades.margenAmplio,
                  () => _cambiarHabilidad(() {
                        Habilidades.margenAmplio = !Habilidades.margenAmplio;
                        if (Habilidades.margenAmplio) {
                          Habilidades.precision = false;
                        }
                      })),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _columnaHab('RETOS', [
              _chip('Nerviosismo', '×1.10', Habilidades.nerviosismo,
                  () => _cambiarHabilidad(() {
                        Habilidades.nerviosismo = !Habilidades.nerviosismo;
                        if (Habilidades.nerviosismo) {
                          Habilidades.concentracion = false;
                        }
                      })),
              _chip('Precisión', '×1.15', Habilidades.precision,
                  () => _cambiarHabilidad(() {
                        Habilidades.precision = !Habilidades.precision;
                        if (Habilidades.precision) {
                          Habilidades.margenAmplio = false;
                        }
                      })),
              _chip('Rompe-combos', '×1.20', Habilidades.rompeCombos,
                  () => _cambiarHabilidad(() =>
                      Habilidades.rompeCombos = !Habilidades.rompeCombos)),
            ]),
          ),
        ],
      ),
    );
  }

  // Botón JUGAR, grande y de ancho completo
  Widget _botonJugar() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: _jugar,
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 62,
          width: double.infinity,
          child: Center(
            child: Text('JUGAR',
                style: AppText.subtitulo
                    .copyWith(fontSize: 22, color: AppColors.base)),
          ),
        ),
      ),
    );
  }

  // Columna derecha: multiplicador, datos del nivel y botón JUGAR
  Widget _columnaJugar() {
    final cancion = canciones[widget.nivel.cancionId];
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('MULTIPLICADOR',
                    style: AppText.etiqueta
                        .copyWith(fontSize: 11, color: AppColors.textMuted)),
                Text(
                  '×${Habilidades.multiplicador.toStringAsFixed(2)}',
                  style: AppText.titulo
                      .copyWith(fontSize: 34, color: AppColors.secondary),
                ),
                const SizedBox(height: 10),
                if (cancion != null) ...[
                  Text('${cancion.patron.length} teclas',
                      style: AppText.etiqueta
                          .copyWith(fontSize: 13, color: AppColors.textMuted)),
                  Text('${cancion.bpm.round()} BPM',
                      style: AppText.etiqueta
                          .copyWith(fontSize: 13, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _botonJugar(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _cabecera(),
            const LineaBorde(), // borde de arriba
            Expanded(
              // LayoutBuilder mide el espacio; el contenido usa todo el ancho
              child: LayoutBuilder(
                builder: (context, medidas) {
                  const altoDiseno = 282.0;
                  return Center(
                    // FittedBox solo encoge si la pantalla es muy baja
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: medidas.maxWidth - 48,
                        height: altoDiseno,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 11, child: _tarjetaAjustes()),
                            const SizedBox(width: 14),
                            Expanded(flex: 14, child: _tarjetaHabilidades()),
                            const SizedBox(width: 14),
                            Expanded(flex: 8, child: _columnaJugar()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const LineaBorde(), // borde de abajo
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}