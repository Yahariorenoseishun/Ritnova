import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../models/partida.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/boton_pildora.dart';
import 'juego_screen.dart';

class ResultadoScreen extends StatelessWidget {
  final Partida partida; // los datos de la partida que acaba de terminar
  final Nivel nivel; // el nivel jugado (para poder reiniciarlo)
  final bool esRecord; // si se superó el mejor puntaje

  const ResultadoScreen({
    super.key,
    required this.partida,
    required this.nivel,
    required this.esRecord,
  });

  // Tarjeta con un número grande y su etiqueta (PTS, COMBO, FAILS)
  Widget _tarjeta(String valor, String etiqueta, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valor, style: AppText.subtitulo.copyWith(color: color)),
          Text(etiqueta, style: AppText.etiqueta),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completado = partida.vida > 0; // si te quedó vida, terminaste la canción
    final mejor = Progreso.instancia.mejorPuntaje(nivel.id);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(completado ? 'NIVEL COMPLETADO' : 'RESULTADO',
                    style: AppText.titulo),
                // Récord nuevo, o el mejor puntaje de este nivel
                Text(
                  esRecord ? '¡NUEVO RÉCORD!' : 'MEJOR: $mejor',
                  style: AppText.etiqueta.copyWith(
                    color: esRecord ? AppColors.secondary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                // Botón circular: vuelve a jugar el mismo nivel
                Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => JuegoScreen(nivel: nivel)),
                    ),
                    child: const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(Icons.refresh,
                          size: 52, color: AppColors.base),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('REINICIAR',
                    style:
                        AppText.etiqueta.copyWith(color: AppColors.primary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _tarjeta('${partida.puntaje}', 'PTS', AppColors.secondary),
                    const SizedBox(width: 16),
                    _tarjeta(
                        '${partida.comboMaximo}', 'COMBO', AppColors.primary),
                    const SizedBox(width: 16),
                    _tarjeta('${partida.fallos}', 'FAILS', AppColors.error),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Perfect ${partida.perfects}  ·  Great ${partida.greats}  ·  '
                  'Bad ${partida.bads}  ·  Miss ${partida.misses}\n'
                  'Promedio de tus toques: ${partida.promedioMs > 0 ? '+' : ''}${partida.promedioMs} ms',
                  textAlign: TextAlign.center,
                  style: AppText.etiqueta
                      .copyWith(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                BotonPildora(
                  texto: 'SALIR',
                  onTap: () => Navigator.pop(context), // vuelve a la lista de niveles
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}