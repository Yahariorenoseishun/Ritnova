import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class FilaCancion extends StatelessWidget {
  final Nivel nivel;
  final VoidCallback onTap; // tocar la fila: jugar
  final VoidCallback onFavorito; // tocar el corazón

  const FilaCancion({
    super.key,
    required this.nivel,
    required this.onTap,
    required this.onFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final esFavorito = Progreso.instancia.esFavorito(nivel.id);
    final mejor = Progreso.instancia.mejorPuntaje(nivel.id);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
          child: Row(
            children: [
              // Corazón: lleno y naranja si es favorito, vacío y amarillo si no
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: esFavorito ? AppColors.primary : AppColors.secondary,
                  size: 26,
                ),
                onPressed: onFavorito,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nivel.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.etiqueta,
                    ),
                    // El mejor puntaje solo aparece si ya jugaste ese nivel
                    if (mejor > 0)
                      Text(
                        'MEJOR: $mejor',
                        style: AppText.etiqueta.copyWith(
                            fontSize: 11, color: AppColors.secondary),
                      ),
                  ],
                ),
              ),
              // 5 estrellas de dificultad: amarillas las primeras, grises el resto
              for (int i = 0; i < 5; i++)
                Icon(
                  Icons.star,
                  size: 24,
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