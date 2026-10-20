import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class FilaCancion extends StatelessWidget {
  final Nivel nivel;
  final VoidCallback onTap;

  const FilaCancion({super.key, required this.nivel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(child: Text(nivel.nombre, style: AppText.etiqueta)),
              // Dibuja 5 estrellas: las primeras "dificultad" en amarillo, el resto en gris
              for (int i = 0; i < 5; i++)
                Icon(
                  Icons.star,
                  size: 28,
                  color: i < nivel.dificultad
                      ? AppColors.secondary
                      : AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}