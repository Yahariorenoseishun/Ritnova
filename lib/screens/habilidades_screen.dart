import 'package:material_ui/material_ui.dart';
import '../models/habilidades.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';

class HabilidadesScreen extends StatefulWidget {
  const HabilidadesScreen({super.key});

  @override
  State<HabilidadesScreen> createState() => _HabilidadesScreenState();
}

class _HabilidadesScreenState extends State<HabilidadesScreen> {
  // Aplica el cambio, redibuja y guarda las habilidades en el teléfono
  void _cambiar(VoidCallback cambio) {
    setState(cambio);
    Progreso.instancia.guardarHabilidades();
  }

  // Una habilidad: nombre, multiplicador, descripción e interruptor
  Widget _tarjeta(String nombre, String mult, String descripcion, bool activo,
      VoidCallback alternar) {
    return GestureDetector(
      onTap: alternar,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activo ? AppColors.primary : const Color(0x00000000),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(nombre, style: AppText.etiqueta),
                      const SizedBox(width: 8),
                      Text(mult,
                          style: AppText.etiqueta.copyWith(
                              fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                  Text(descripcion,
                      style: AppText.etiqueta.copyWith(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _Interruptor(activo: activo),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String titulo, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppText.subtitulo.copyWith(fontSize: 18)),
          Text(sub,
              style: AppText.etiqueta
                  .copyWith(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BarraTitulo(titulo: 'HABILIDADES'),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ayudas: más fácil, menos puntos. Cada una apaga a su contraria.
                    Expanded(
                      child: Column(
                        children: [
                          _titulo('AYUDAS', 'Más fácil, pero menos puntos'),
                          _tarjeta(
                            'Concentración',
                            '×0.90',
                            'Los fallos quitan la mitad de vida.',
                            Habilidades.concentracion,
                            () => _cambiar(() {
                              Habilidades.concentracion =
                                  !Habilidades.concentracion;
                              if (Habilidades.concentracion) {
                                Habilidades.nerviosismo = false;
                              }
                            }),
                          ),
                          _tarjeta(
                            'Combo experto',
                            '×0.90',
                            'Cada 10 de combo recuperas 5 de vida.',
                            Habilidades.comboExperto,
                            () => _cambiar(() => Habilidades.comboExperto =
                                !Habilidades.comboExperto),
                          ),
                          _tarjeta(
                            'Margen amplio',
                            '×0.85',
                            'Más tiempo para acertar (25% más amplio).',
                            Habilidades.margenAmplio,
                            () => _cambiar(() {
                              Habilidades.margenAmplio =
                                  !Habilidades.margenAmplio;
                              if (Habilidades.margenAmplio) {
                                Habilidades.precision = false;
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Retos: más difícil, más puntos
                    Expanded(
                      child: Column(
                        children: [
                          _titulo('RETOS', 'Más difícil, pero más puntos'),
                          _tarjeta(
                            'Nerviosismo',
                            '×1.10',
                            'Los fallos quitan 50% más de vida.',
                            Habilidades.nerviosismo,
                            () => _cambiar(() {
                              Habilidades.nerviosismo =
                                  !Habilidades.nerviosismo;
                              if (Habilidades.nerviosismo) {
                                Habilidades.concentracion = false;
                              }
                            }),
                          ),
                          _tarjeta(
                            'Precisión',
                            '×1.15',
                            'Menos tiempo para acertar (25% más estricto).',
                            Habilidades.precision,
                            () => _cambiar(() {
                              Habilidades.precision = !Habilidades.precision;
                              if (Habilidades.precision) {
                                Habilidades.margenAmplio = false;
                              }
                            }),
                          ),
                          _tarjeta(
                            'Rompedor de combos',
                            '×1.20',
                            'Las teclas caen 25% más rápido.',
                            Habilidades.rompeCombos,
                            () => _cambiar(() => Habilidades.rompeCombos =
                                !Habilidades.rompeCombos),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Center(
                child: Text(
                  'Multiplicador de puntos: ×${Habilidades.multiplicador.toStringAsFixed(2)}',
                  style: AppText.etiqueta.copyWith(color: AppColors.secondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Interruptor de encendido y apagado, dibujado a mano
class _Interruptor extends StatelessWidget {
  final bool activo;

  const _Interruptor({required this.activo});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 52,
      height: 28,
      padding: const EdgeInsets.all(3),
      alignment: activo ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: activo ? AppColors.primary : const Color(0xFF444444),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.text,
        ),
      ),
    );
  }
}