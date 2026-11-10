import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

// Botón principal: píldora naranja rellena
class BotonLleno extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const BotonLleno({super.key, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          child: Text(texto,
              style: AppText.etiqueta.copyWith(color: AppColors.base)),
        ),
      ),
    );
  }
}