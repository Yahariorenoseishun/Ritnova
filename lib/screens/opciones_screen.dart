import 'package:material_ui/material_ui.dart';
import '../audio/musica_menu.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/linea_borde.dart';
import '../widgets/panel_ajustes.dart';
import 'como_jugar_screen.dart';
import 'creditos_screen.dart';
import 'habilidades_screen.dart';

class OpcionesScreen extends StatefulWidget {
  const OpcionesScreen({super.key});

  @override
  State<OpcionesScreen> createState() => _OpcionesScreenState();
}

class _OpcionesScreenState extends State<OpcionesScreen> {
  void _abrir(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  // Pregunta antes de borrar, porque no se puede deshacer
  Future<void> _borrarProgreso() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('¿Borrar todo el progreso?',
            style: AppText.subtitulo.copyWith(fontSize: 18)),
        content: Text(
          'Se borran tus récords, favoritos, ajustes y habilidades. No se puede deshacer.',
          style: AppText.contenido
              .copyWith(fontSize: 14, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCELAR', style: AppText.etiqueta),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('BORRAR',
                style: AppText.etiqueta.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await Progreso.instancia.borrarTodo();
      MusicaMenu.actualizarVolumen();
      if (mounted) setState(() {}); // los ajustes se redibujan con los valores de fábrica
    }
  }

  // Una opción de la tarjeta MÁS: icono, texto y flecha
  Widget _opcion(IconData icono, String texto, VoidCallback onTap,
      {bool peligro = false}) {
    return Material(
      color: AppColors.base,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icono,
                  size: 22,
                  color: peligro ? AppColors.error : AppColors.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  texto,
                  style: AppText.etiqueta.copyWith(
                      fontSize: 14,
                      color: peligro ? AppColors.error : AppColors.text),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opciones = [
      _opcion(Icons.bolt, 'HABILIDADES', () => _abrir(const HabilidadesScreen())),
      _opcion(
          Icons.help_outline, 'CÓMO JUGAR', () => _abrir(const ComoJugarScreen())),
      _opcion(Icons.info_outline, 'CRÉDITOS', () => _abrir(const CreditosScreen())),
      _opcion(Icons.delete_outline, 'BORRAR PROGRESO', _borrarProgreso,
          peligro: true),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BarraTitulo(titulo: 'OPCIONES', compacta: true),
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
                        height: 284,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(flex: 10, child: TarjetaAjustes()),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 11,
                              child: TarjetaPanel(
                                titulo: 'MÁS',
                                hijo: Column(
                                  children: [
                                    for (final o in opciones)
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: o,
                                        ),
                                      ),
                                    Text(
                                      'RITNOVA  ·  versión 1.0',
                                      style: AppText.etiqueta.copyWith(
                                          fontSize: 11,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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