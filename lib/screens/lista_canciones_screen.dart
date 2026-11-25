import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/fila_cancion.dart';
import '../widgets/linea_borde.dart';
import 'pre_nivel_screen.dart';

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
          children: [
            BarraTitulo(titulo: titulo, compacta: true),
            const LineaBorde(), // borde de arriba
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          soloFavoritos
                              ? 'Aún no tienes favoritos.\nToca el corazón de un nivel para agregarlo.'
                              : 'No hay niveles cargados.\nRevisa la carpeta assets/niveles y reinicia la app.',
                          textAlign: TextAlign.center,
                          style: AppText.contenido
                              .copyWith(color: AppColors.textMuted),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, medidas) {
                        // Largo del desvanecido (18 px) como fracción de la altura
                        final f = medidas.maxHeight > 0
                            ? 18 / medidas.maxHeight
                            : 0.05;
                        // ShaderMask pone una máscara: transparente en los bordes
                        // y opaca en el centro, así las tarjetas se desvanecen
                        // al acercarse a las líneas en lugar de cortarse
                        return ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (rect) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: const [
                              Color(0x00FFFFFF),
                              Color(0xFFFFFFFF),
                              Color(0xFFFFFFFF),
                              Color(0x00FFFFFF),
                            ],
                            stops: [0.0, f, 1.0 - f, 1.0],
                          ).createShader(rect),
                          // Sin barra de desplazamiento ni efecto de estirado
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false, overscroll: false),
                            child: GridView.builder(
                              physics: const ClampingScrollPhysics(),
                              // Margen arriba y abajo: las tarjetas en reposo
                              // quedan en medio, sin tocar las líneas
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 76, // alto de cada tarjeta
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, i) => FilaCancion(
                                nivel: items[i],
                                // Al tocar un nivel se abre la pantalla previa
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PreNivelScreen(nivel: items[i]),
                                  ),
                                ),
                                onFavorito: () => Progreso.instancia
                                    .alternarFavorito(items[i].id),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const LineaBorde(), // borde de abajo
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}