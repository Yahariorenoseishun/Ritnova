import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/fila_cancion.dart';
import 'juego_screen.dart';
// Sirve para NIVELES y para FAVORITOS: solo cambia el título y la lista
class ListaCancionesScreen extends StatelessWidget {
  final String titulo;
  final List<Nivel> items;

  const ListaCancionesScreen({
    super.key,
    required this.titulo,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarraTitulo(titulo: titulo),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 24, bottom: 6),
                        child: Text(
                          'DIFICULTAD',
                          style: AppText.etiqueta.copyWith(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => FilaCancion(
                            nivel: items[i],
                            // Por ahora abre una pantalla provisional con el nombre
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                               builder: (_) => JuegoScreen(nivel: items[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}