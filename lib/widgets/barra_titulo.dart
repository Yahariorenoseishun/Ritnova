import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class BarraTitulo extends StatelessWidget {
  final String titulo;

  const BarraTitulo({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 32),
            onPressed: () => Navigator.pop(context), // regresar
          ),
          const SizedBox(width: 12),
          Text(titulo, style: AppText.subtitulo),
        ],
      ),
    );
  }
}