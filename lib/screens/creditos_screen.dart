import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/linea_borde.dart';

// Créditos. Las licencias de las canciones EXIGEN que aparezcan aquí.
// Si agregas otra canción con licencia, agrega su bloque abajo.
class CreditosScreen extends StatelessWidget {
  const CreditosScreen({super.key});

  Widget _bloque(String titulo, List<Widget> hijos) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: AppText.etiqueta
                  .copyWith(fontSize: 12, color: AppColors.secondary)),
          const SizedBox(height: 8),
          ...hijos,
        ],
      ),
    );
  }

  Widget _linea(String texto, {bool destacada = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        texto,
        style: AppText.contenido.copyWith(
            fontSize: 13,
            color: destacada ? AppColors.text : AppColors.textMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BarraTitulo(titulo: 'CRÉDITOS', compacta: true),
            const LineaBorde(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  // Sin barra de desplazamiento ni efecto de estirado
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false, overscroll: false),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                      child: Column(
                        children: [
                          _bloque('MÚSICA CON LICENCIA', [
                            _linea('Fly With Me', destacada: true),
                            _linea(
                                'Fly With Me by EuGenius & VikA | https://www.eugeniusmusic.com'),
                            _linea(
                                'Royalty Free Music by https://www.free-stock-music.com'),
                            _linea(
                                'Creative Commons / Attribution 4.0 International (CC BY 4.0)'),
                            _linea('https://creativecommons.org/licenses/by/4.0/'),
                            const SizedBox(height: 10),
                            _linea('let’s watch the stars', destacada: true),
                            _linea('Música, letra y producción: Alex Coldfire'),
                            _linea(
                                'Licencia Creative Commons Atribución-SinDerivadas 4.0 (CC BY-ND 4.0)'),
                            _linea('https://creativecommons.org/licenses/by-nd/4.0/'),
                          ]),
                          _bloque('ORIGINAL DE RITNOVA', [
                            _linea(
                                'Nova Sprint, la música del menú y el efecto nova fueron creados para este proyecto.'),
                          ]),
                          _bloque('TIPOGRAFÍA', [
                            _linea('Poppins · SIL Open Font License 1.1'),
                          ]),
                          _bloque('TECNOLOGÍA', [
                            _linea('Hecho con Flutter y el motor de juegos Flame.'),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const LineaBorde(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}