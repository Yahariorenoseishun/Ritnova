import 'package:material_ui/material_ui.dart';
import '../models/cancion.dart';
import '../models/habilidades.dart';
import '../models/nivel.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/linea_borde.dart';
import '../widgets/panel_ajustes.dart';
import 'juego_screen.dart';

// Pantalla previa a cada nivel: habilidades y ajustes antes de jugar
class PreNivelScreen extends StatefulWidget {
  final Nivel nivel;

  const PreNivelScreen({super.key, required this.nivel});

  @override
  State<PreNivelScreen> createState() => _PreNivelScreenState();
}

class _PreNivelScreenState extends State<PreNivelScreen> {
  void _jugar() {
    Progreso.instancia.guardarAjustes();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JuegoScreen(nivel: widget.nivel)),
    );
  }

  // Barra de arriba: flecha, nombre del nivel, estrellas y mejor puntaje
  Widget _cabecera() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 24, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 26),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.nivel.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.subtitulo.copyWith(fontSize: 20),
            ),
          ),
          for (int i = 0; i < 5; i++)
            Icon(
              Icons.star,
              size: 20,
              color: i < widget.nivel.dificultad
                  ? AppColors.secondary
                  : AppColors.textMuted,
            ),
          const SizedBox(width: 16),
          ListenableBuilder(
            listenable: Progreso.instancia,
            builder: (context, _) {
              final mejor = Progreso.instancia.mejorPuntaje(widget.nivel.id);
              return Text(
                mejor > 0 ? 'MEJOR: $mejor' : 'SIN JUGAR',
                style: AppText.etiqueta
                    .copyWith(fontSize: 13, color: AppColors.secondary),
              );
            },
          ),
        ],
      ),
    );
  }

  // Barra de abajo: multiplicador, datos del nivel y el botón JUGAR
  Widget _barraInferior() {
    final cancion = canciones[widget.nivel.cancionId];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Text('MULTIPLICADOR',
                    style: AppText.etiqueta
                        .copyWith(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(width: 12),
                Text(
                  '×${Habilidades.multiplicador.toStringAsFixed(2)}',
                  style: AppText.titulo
                      .copyWith(fontSize: 30, color: AppColors.secondary),
                ),
                const Spacer(),
                if (cancion != null)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${cancion.patron.length} teclas',
                          style: AppText.etiqueta.copyWith(
                              fontSize: 13, color: AppColors.textMuted)),
                      Text('${cancion.bpm.round()} BPM',
                          style: AppText.etiqueta.copyWith(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 250,
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: _jugar,
              borderRadius: BorderRadius.circular(100),
              child: Center(
                child: Text('JUGAR',
                    style: AppText.subtitulo
                        .copyWith(fontSize: 24, color: AppColors.base)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _cabecera(),
            const LineaBorde(), // borde de arriba
            Expanded(
              child: LayoutBuilder(
                builder: (context, medidas) {
                  final disponible = medidas.maxWidth - 48;
                  final ancho = disponible > 880 ? 880.0 : disponible;
                  return Center(
                    // FittedBox solo encoge si la pantalla es muy baja
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: ancho,
                        height: 306,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 232,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 13,
                                    child: TarjetaHabilidades(
                                      // al cambiar una habilidad se actualiza el multiplicador
                                      onCambio: () => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                      flex: 10, child: TarjetaAjustes()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(height: 64, child: _barraInferior()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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