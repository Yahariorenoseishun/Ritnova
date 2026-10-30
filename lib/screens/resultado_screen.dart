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

  // Tarjeta horizontal: etiqueta a la izquierda y valor a la derecha
  Widget _fila(String etiqueta, String valor, Color color) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: AppText.etiqueta),
          Text(valor,
              style: AppText.etiqueta.copyWith(fontSize: 20, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completado = partida.vida > 0; // si te quedó vida, terminaste la canción
    final mejor = Progreso.instancia.mejorPuntaje(nivel.id);
    final prom = partida.promedioMs;
    final textoProm = prom > 0 ? '+$prom' : '$prom';

    return Scaffold(
      body: SafeArea(
        child: Center(
          // FittedBox encoge el contenido si no cabe, así no hace falta scroll
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(completado ? 'NIVEL COMPLETADO' : 'RESULTADO',
                      style: AppText.titulo),
                  Text(
                    esRecord ? '¡NUEVO RÉCORD!' : 'MEJOR: $mejor',
                    style: AppText.etiqueta.copyWith(
                      color:
                          esRecord ? AppColors.secondary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Izquierda: reiniciar el mismo nivel
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                width: 100,
                                height: 100,
                                child: Icon(Icons.refresh,
                                    size: 64, color: AppColors.base),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('REINICIAR',
                              style: AppText.etiqueta
                                  .copyWith(color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(width: 48),
                      // Derecha: datos de la partida y salir
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _fila('PTS', '${partida.puntaje}', AppColors.secondary),
                          _fila('COMBO', '${partida.comboMaximo}',
                              AppColors.primary),
                          _fila('FAILS', '${partida.fallos}', AppColors.error),
                          SizedBox(
                            width: 240,
                            child: Text(
                              'Perfect ${partida.perfects} · Great ${partida.greats}\n'
                              'Bad ${partida.bads} · Miss ${partida.misses}\n'
                              'Promedio de tus toques: $textoProm ms',
                              textAlign: TextAlign.center,
                              style: AppText.etiqueta.copyWith(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 8),
                          BotonPildora(
                            texto: 'SALIR',
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


