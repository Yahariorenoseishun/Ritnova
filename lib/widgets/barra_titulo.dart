import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

// Flecha de regreso y título. Con compacta: true la barra es más baja
// y el título más chico.
class BarraTitulo extends StatelessWidget {
  final String titulo;
  final bool compacta;

  const BarraTitulo({super.key, required this.titulo, this.compacta = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compacta ? 6 : 16, 16, compacta ? 6 : 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: AppColors.text, size: compacta ? 26 : 32),
            onPressed: () => Navigator.pop(context), // regresar
            padding: compacta ? EdgeInsets.zero : const EdgeInsets.all(8),
            constraints: BoxConstraints(
              minWidth: compacta ? 40 : 48,
              minHeight: compacta ? 40 : 48,
            ),
          ),
          SizedBox(width: compacta ? 8 : 12),
          Expanded(
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: compacta
                  ? AppText.subtitulo.copyWith(fontSize: 18)
                  : AppText.subtitulo,
            ),
          ),
        ],
      ),
    );
  }
}