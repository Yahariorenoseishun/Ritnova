import 'package:material_ui/material_ui.dart';
import '../audio/musica_menu.dart';
import '../models/configuracion_audio.dart';
import '../models/habilidades.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

// Tarjeta con fondo, título y un contenido que ocupa el espacio restante
class TarjetaPanel extends StatelessWidget {
  final String titulo;
  final Widget hijo;

  const TarjetaPanel({super.key, required this.titulo, required this.hijo});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 8),
          Expanded(child: hijo),
        ],
      ),
    );
  }
}

// Volúmenes, velocidad y sincronía. Se guardan solos al cerrar la pantalla.
class TarjetaAjustes extends StatefulWidget {
  const TarjetaAjustes({super.key});

  @override
  State<TarjetaAjustes> createState() => _TarjetaAjustesState();
}

class _TarjetaAjustesState extends State<TarjetaAjustes> {
  @override
  void dispose() {
    Progreso.instancia.guardarAjustes();
    super.dispose();
  }

  void _velocidad(double cambio) {
    double nueva = ConfiguracionAudio.velocidad + cambio;
    if (nueva < 1.0) nueva = 1.0;
    if (nueva > 30.0) nueva = 30.0;
    setState(() => ConfiguracionAudio.velocidad = nueva);
  }

  void _desfase(double cambio) {
    double nuevo = ConfiguracionAudio.desfaseMs + cambio;
    if (nuevo < -300) nuevo = -300;
    if (nuevo > 300) nuevo = 300;
    setState(() => ConfiguracionAudio.desfaseMs = nuevo);
  }

  @override
  Widget build(BuildContext context) {
    final d = ConfiguracionAudio.desfaseMs.round();
    return TarjetaPanel(
      titulo: 'AJUSTES',
      hijo: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FilaVolumen('MÚSICA', ConfiguracionAudio.volumenMusica, (v) {
            setState(() => ConfiguracionAudio.volumenMusica = v);
            MusicaMenu.actualizarVolumen(); // se oye el cambio al instante
          }),
          _FilaVolumen('EFECTOS', ConfiguracionAudio.volumenEfectos, (v) {
            setState(() => ConfiguracionAudio.volumenEfectos = v);
          }),
          _FilaAjuste(
            'VELOCIDAD',
            ConfiguracionAudio.velocidad.toStringAsFixed(1),
            () => _velocidad(-0.5),
            () => _velocidad(0.5),
          ),
          _FilaAjuste(
            'SINCRONÍA',
            d > 0 ? '+$d ms' : '$d ms',
            () => _desfase(-10),
            () => _desfase(10),
          ),
        ],
      ),
    );
  }
}

// Las seis habilidades. Se guardan en cada cambio y avisan a la pantalla.
class TarjetaHabilidades extends StatefulWidget {
  final VoidCallback? onCambio; // para que la pantalla actualice el multiplicador

  const TarjetaHabilidades({super.key, this.onCambio});

  @override
  State<TarjetaHabilidades> createState() => _TarjetaHabilidadesState();
}

class _TarjetaHabilidadesState extends State<TarjetaHabilidades> {
  void _cambiar(VoidCallback cambio) {
    setState(cambio);
    Progreso.instancia.guardarHabilidades();
    widget.onCambio?.call();
  }

  // Una columna (ayudas o retos): los botones se reparten el alto
  Widget _columna(String etiqueta, List<Widget> chips) {
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

  @override
  Widget build(BuildContext context) {
    return TarjetaPanel(
      titulo: 'HABILIDADES',
      hijo: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _columna('AYUDAS', [
              _ChipHab('Concentración', '×0.90', Habilidades.concentracion,
                  () => _cambiar(() {
                        Habilidades.concentracion = !Habilidades.concentracion;
                        if (Habilidades.concentracion) {
                          Habilidades.nerviosismo = false;
                        }
                      })),
              _ChipHab('Combo experto', '×0.90', Habilidades.comboExperto,
                  () => _cambiar(() => Habilidades.comboExperto =
                      !Habilidades.comboExperto)),
              _ChipHab('Margen amplio', '×0.85', Habilidades.margenAmplio,
                  () => _cambiar(() {
                        Habilidades.margenAmplio = !Habilidades.margenAmplio;
                        if (Habilidades.margenAmplio) {
                          Habilidades.precision = false;
                        }
                      })),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _columna('RETOS', [
              _ChipHab('Nerviosismo', '×1.10', Habilidades.nerviosismo,
                  () => _cambiar(() {
                        Habilidades.nerviosismo = !Habilidades.nerviosismo;
                        if (Habilidades.nerviosismo) {
                          Habilidades.concentracion = false;
                        }
                      })),
              _ChipHab('Precisión', '×1.15', Habilidades.precision,
                  () => _cambiar(() {
                        Habilidades.precision = !Habilidades.precision;
                        if (Habilidades.precision) {
                          Habilidades.margenAmplio = false;
                        }
                      })),
              _ChipHab('Rompedor de combos', '×1.20', Habilidades.rompeCombos,
                  () => _cambiar(() =>
                      Habilidades.rompeCombos = !Habilidades.rompeCombos)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ---------- Piezas pequeñas ----------

// Una barra de volumen en una sola línea
class _FilaVolumen extends StatelessWidget {
  final String titulo;
  final double valor;
  final ValueChanged<double> alCambiar;

  const _FilaVolumen(this.titulo, this.valor, this.alCambiar);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(titulo,
              maxLines: 1,
              softWrap: false,
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
          width: 44,
          child: Text('${valor.round()}%',
              textAlign: TextAlign.right,
              style: AppText.etiqueta.copyWith(fontSize: 13)),
        ),
      ],
    );
  }
}

// Un ajuste con "-", el valor y "+"
class _FilaAjuste extends StatelessWidget {
  final String titulo;
  final String valor;
  final VoidCallback menos;
  final VoidCallback mas;

  const _FilaAjuste(this.titulo, this.valor, this.menos, this.mas);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(titulo,
              maxLines: 1,
              softWrap: false,
              style: AppText.etiqueta
                  .copyWith(fontSize: 13, color: AppColors.textMuted)),
        ),
        _Mini('-', menos),
        SizedBox(
          width: 72,
          child: Text(valor,
              textAlign: TextAlign.center,
              style: AppText.etiqueta
                  .copyWith(fontSize: 16, color: AppColors.primary)),
        ),
        _Mini('+', mas),
      ],
    );
  }
}

// Botoncito circular con "-" o "+"
class _Mini extends StatelessWidget {
  final String simbolo;
  final VoidCallback onTap;

  const _Mini(this.simbolo, this.onTap);

  @override
  Widget build(BuildContext context) {
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
}

// Una habilidad: se enciende y se apaga al tocarla
class _ChipHab extends StatelessWidget {
  final String nombre;
  final String mult;
  final bool activo;
  final VoidCallback alternar;

  const _ChipHab(this.nombre, this.mult, this.activo, this.alternar);

  @override
  Widget build(BuildContext context) {
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
                  // FittedBox encoge un poco el nombre si no cabe, en vez de cortarlo
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(nombre,
                        maxLines: 1,
                        softWrap: false,
                        style: AppText.etiqueta.copyWith(fontSize: 13)),
                  ),
                  Text(mult,
                      style: AppText.etiqueta
                          .copyWith(fontSize: 11, color: AppColors.secondary)),
                ],
              ),
            ),
            const SizedBox(width: 6),
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
}