import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/fila_cancion.dart';
import 'juego_screen.dart';

// Sirve para NIVELES y para FAVORITOS: solo cambia el título y el filtro
class ListaCancionesScreen extends StatelessWidget {
  final String titulo;
  final bool soloFavoritos;

  const ListaCancionesScreen({
    super.key,
    required this.titulo,
    this.soloFavoritos = false,
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
                  constraints: const BoxConstraints(maxWidth: 560),
                  // Se redibuja sola cuando Progreso avisa un cambio
                  child: ListenableBuilder(
                    listenable: Progreso.instancia,
                    builder: (context, _) {
                      final items = soloFavoritos
                          ? niveles
                              .where((n) => Progreso.instancia.esFavorito(n.id))
                              .toList()
                          : niveles;

                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'Aún no tienes favoritos.\n'
                            'Toca el corazón de un nivel para agregarlo.',
                            textAlign: TextAlign.center,
                            style: AppText.contenido
                                .copyWith(color: AppColors.textMuted),
                          ),
                        );
                      }

                      return Column(
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
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        JuegoScreen(nivel: items[i]),
                                  ),
                                ),
                                onFavorito: () => Progreso.instancia
                                    .alternarFavorito(items[i].id),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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