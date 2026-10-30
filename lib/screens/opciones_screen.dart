import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:material_ui/material_ui.dart';
import '../models/configuracion_audio.dart';
import '../models/progreso.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/boton_pildora.dart';
import '../widgets/control_volumen.dart';
import 'grabacion_screen.dart';

class OpcionesScreen extends StatefulWidget {
  const OpcionesScreen({super.key});

  @override
  State<OpcionesScreen> createState() => _OpcionesScreenState();
}

class _OpcionesScreenState extends State<OpcionesScreen> {
  // Al salir de OPCIONES se guardan los ajustes en el teléfono
  @override
  void dispose() {
    Progreso.instancia.guardarAjustes();
    super.dispose();
  }

  // Sube o baja la velocidad, siempre entre 1.0 y 20.0
  void _cambiarVelocidad(double cambio) {
    double nueva = ConfiguracionAudio.velocidad + cambio;
    if (nueva < 1.0) nueva = 1.0;
    if (nueva > 20.0) nueva = 20.0;
    setState(() {
      ConfiguracionAudio.velocidad = nueva;
    });
  }

  // Sube o baja la sincronía, siempre entre -300 y 300 ms
  void _cambiarDesfase(double cambio) {
    double nuevo = ConfiguracionAudio.desfaseMs + cambio;
    if (nuevo < -300) nuevo = -300;
    if (nuevo > 300) nuevo = 300;
    setState(() {
      ConfiguracionAudio.desfaseMs = nuevo;
    });
  }

  // Botón circular blanco con "-" o "+"
  Widget _botonCirculo(String simbolo, VoidCallback onTap) {
    return Material(
      color: AppColors.text,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              simbolo,
              style: AppText.subtitulo.copyWith(color: AppColors.base),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = ConfiguracionAudio.desfaseMs.round();
    final textoDesfase = d > 0 ? '+$d ms' : '$d ms';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BarraTitulo(titulo: 'OPCIONES'),
            Expanded(
              child: Center(
                // FittedBox encoge el contenido si no cabe: así no hace falta scroll
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 420,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ControlVolumen(
                          titulo: 'VOL. MÚSICA',
                          valor: ConfiguracionAudio.volumenMusica,
                          onChanged: (v) => setState(() {
                            ConfiguracionAudio.volumenMusica = v;
                          }),
                        ),
                        ControlVolumen(
                          titulo: 'VOL. EFECTOS',
                          valor: ConfiguracionAudio.volumenEfectos,
                          onChanged: (v) => setState(() {
                            ConfiguracionAudio.volumenEfectos = v;
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text('VELOCIDAD', style: AppText.etiqueta),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _botonCirculo('-', () => _cambiarVelocidad(-0.5)),
                            const SizedBox(width: 24),
                            Text(
                              ConfiguracionAudio.velocidad.toStringAsFixed(1),
                              style: AppText.subtitulo
                                  .copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(width: 24),
                            _botonCirculo('+', () => _cambiarVelocidad(0.5)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('SINCRONÍA', style: AppText.etiqueta),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _botonCirculo('-', () => _cambiarDesfase(-10)),
                            const SizedBox(width: 24),
                            SizedBox(
                              width: 100,
                              child: Text(
                                textoDesfase,
                                textAlign: TextAlign.center,
                                style: AppText.subtitulo
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 24),
                            _botonCirculo('+', () => _cambiarDesfase(10)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Si oyes el sonido tarde, súbelo.',
                          style: AppText.etiqueta.copyWith(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                        // Herramienta de desarrollo: no aparece en el APK de release
                        if (!kReleaseMode) ...[
                          const SizedBox(height: 14),
                          BotonPildora(
                            texto: 'GRABAR PATRÓN',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const GrabacionScreen()),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
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