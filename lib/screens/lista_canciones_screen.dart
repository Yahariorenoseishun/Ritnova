import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/fila_cancion.dart';
import 'juego_screen.dart';

// Sirve para NIVELES y para FAVORITOS: solo cambia el título y el filtro
class ListaCancionesScreen extends StatefulWidget {
  final String titulo;
  final bool soloFavoritos;

  const ListaCancionesScreen({
    super.key,
    required this.titulo,
    this.soloFavoritos = false,
  });

  @override
  State<ListaCancionesScreen> createState() => _ListaCancionesScreenState();
}

class _ListaCancionesScreenState extends State<ListaCancionesScreen> {
  // Controla el desplazamiento de la lista y de su barra
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarraTitulo(titulo: widget.titulo),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                // Se redibuja sola cuando Progreso avisa un cambio
                child: ListenableBuilder(
                  listenable: Progreso.instancia,
                  builder: (context, _) {
                    final items = widget.soloFavoritos
                        ? niveles
                            .where((n) => Progreso.instancia.esFavorito(n.id))
                            .toList()
                        : niveles;

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          widget.soloFavoritos
                              ? 'Aún no tienes favoritos.\nToca el corazón de un nivel para agregarlo.'
                              : 'No hay niveles cargados.\nRevisa la carpeta assets/niveles y reinicia la app.',
                          textAlign: TextAlign.center,
                          style: AppText.contenido
                              .copyWith(color: AppColors.textMuted),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 14, bottom: 6),
                          child: Text(
                            '${items.length} ${items.length == 1 ? 'nivel' : 'niveles'}  ·  DIFICULTAD',
                            textAlign: TextAlign.right,
                            style: AppText.etiqueta.copyWith(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                        Expanded(
                          // La barra siempre visible avisa que hay más niveles abajo
                          child: Scrollbar(
                            controller: _scroll,
                            thumbVisibility: true,
                            child: GridView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.only(right: 14, bottom: 8),
                              // 2 columnas; cada fila mide 68 de alto
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 68,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, i) => FilaCancion(
                                nivel: items[i],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JuegoScreen(nivel: items[i]),
                                  ),
                                ),
                                onFavorito: () => Progreso.instancia
                                    .alternarFavorito(items[i].id),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}