import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class FilaCancion extends StatelessWidget {
  final Nivel nivel;
  final VoidCallback onTap; // tocar la tarjeta: abrir el nivel
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
          padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
          child: Row(
            children: [
              // Corazón: lleno y naranja si es favorito, vacío y amarillo si no
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: esFavorito ? AppColors.primary : AppColors.secondary,
                  size: 28,
                ),
                onPressed: onFavorito,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // El nombre va en su propia línea: así cabe completo
                    Text(
                      nivel.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.etiqueta.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 5 estrellas de dificultad: amarillas las primeras, grises el resto
                        for (int i = 0; i < 5; i++)
                          Icon(
                            Icons.star,
                            size: 19,
                            color: i < nivel.dificultad
                                ? AppColors.secondary
                                : AppColors.textMuted,
                          ),
                        const Spacer(),
                        // El mejor puntaje solo aparece si ya jugaste ese nivel
                        if (mejor > 0)
                          Text(
                            'MEJOR: $mejor',
                            style: AppText.etiqueta.copyWith(
                                fontSize: 11, color: AppColors.secondary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}