import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class ControlVolumen extends StatelessWidget {
  final String titulo;
  final double valor; // de 0 a 100
  final ValueChanged<double> onChanged; // qué hacer cuando se mueve la barra

  const ControlVolumen({
    super.key,
    required this.titulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$titulo — ${valor.round()}%', style: AppText.etiqueta),
        SliderTheme(
          // Colores de tu Figma: amarillo, gris y círculo blanco
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: AppColors.secondary,
            inactiveTrackColor: AppColors.textMuted,
            thumbColor: AppColors.text,
          ),
          child: Slider(value: valor, min: 0, max: 100, onChanged: onChanged),
        ),
      ],
    );
  }
}