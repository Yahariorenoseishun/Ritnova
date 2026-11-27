import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/linea_borde.dart';

// Explicación visual de cómo se juega, en 6 tarjetas
class ComoJugarScreen extends StatelessWidget {
  const ComoJugarScreen({super.key});

  static const Color _rosa = Color(0xFFFF5FA2);
  static const Color _celeste = Color(0xFF4DD6FF);

  // Una tecla dibujada (barra delgada)
  Widget _tecla(double ancho, Color color) => Container(
        width: ancho,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      );

  // La barra naranja de la zona de toque
  Widget _barra(double ancho) => Container(
        width: ancho,
        height: 14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.primary, width: 3),
        ),
      );

  // Una tarjeta: dibujo arriba, título y explicación
  Widget _tarjeta(Widget visual, String titulo, String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            width: double.infinity,
            child: Center(child: visual),
          ),
          const SizedBox(height: 6),
          Text(titulo, style: AppText.etiqueta.copyWith(fontSize: 14)),
          const SizedBox(height: 3),
          Text(
            texto,
            style: AppText.contenido.copyWith(
                fontSize: 12, height: 1.3, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // Tres tarjetas en una fila, todas del mismo alto
  Widget _fila(List<Widget> tarjetas) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < tarjetas.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: tarjetas[i]),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texto11 = AppText.etiqueta.copyWith(fontSize: 11);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BarraTitulo(titulo: 'CÓMO JUGAR', compacta: true),
            const LineaBorde(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, medidas) {
                  final disponible = medidas.maxWidth - 48;
                  final ancho = disponible > 880 ? 880.0 : disponible;
                  return Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: ancho,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _fila([
                              _tarjeta(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _tecla(90, AppColors.secondary),
                                    const SizedBox(height: 18),
                                    _barra(110),
                                  ],
                                ),
                                'TOCA',
                                'Toca el carril justo cuando la tecla cruza la barra naranja.',
                              ),
                              _tarjeta(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: const Color(0x66FFD23F),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    _tecla(76, AppColors.secondary),
                                    const SizedBox(height: 6),
                                    _barra(90),
                                  ],
                                ),
                                'MANTÉN',
                                'En las teclas largas, apoya el dedo y no lo levantes hasta que terminen.',
                              ),
                              _tarjeta(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _tecla(150, _rosa),
                                    const SizedBox(height: 18),
                                    _barra(160),
                                  ],
                                ),
                                'ANCHAS',
                                'Una tecla ancha cubre varios carriles: tócala en cualquiera de ellos.',
                              ),
                            ]),
                            const SizedBox(height: 12),
                            _fila([
                              _tarjeta(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _tecla(60, _celeste),
                                        const SizedBox(width: 10),
                                        _tecla(60, _rosa),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    _barra(150),
                                  ],
                                ),
                                'DOBLES',
                                'Dos teclas a la vez: usa dos dedos. Nunca piden más de dos.',
                              ),
                              _tarjeta(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('PERFECT',
                                            style: texto11.copyWith(
                                                color: AppColors.secondary)),
                                        const SizedBox(width: 10),
                                        Text('GREAT',
                                            style: texto11.copyWith(
                                                color: AppColors.primary)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('BAD',
                                            style: texto11.copyWith(
                                                color: AppColors.textMuted)),
                                        const SizedBox(width: 10),
                                        Text('MISS',
                                            style: texto11.copyWith(
                                                color: AppColors.error)),
                                      ],
                                    ),
                                  ],
                                ),
                                'JUICIOS',
                                'Perfect da 100 puntos y Great 50. Bad y Miss quitan vida y cortan el combo.',
                              ),
                              _tarjeta(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.favorite,
                                            color: AppColors.error, size: 16),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 90,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('COMBO x25',
                                        style: texto11.copyWith(
                                            color: AppColors.secondary)),
                                  ],
                                ),
                                'VIDA Y COMBO',
                                'Si la vida llega a 0 pierdes. Los combos altos hacen salir anillos de luz.',
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const LineaBorde(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}