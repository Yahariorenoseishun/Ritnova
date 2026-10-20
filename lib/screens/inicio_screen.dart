import 'package:material_ui/material_ui.dart';
import '../models/nivel.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/boton_pildora.dart';
import 'lista_canciones_screen.dart';
import 'opciones_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  // Abre la pantalla que le pases encima de esta
  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/ritnova_logo.png', height: 120),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BotonPildora(
                  texto: 'FAVORITOS',
                  onTap: () => _abrir(
                    context,
                    const ListaCancionesScreen(
                        titulo: 'FAVORITOS', items: favoritosDemo),
                  ),
                ),
                Column(
                  children: [
                    Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _abrir(
                          context,
                          const ListaCancionesScreen(
                              titulo: 'NIVELES', items: niveles),
                        ),
                        child: const SizedBox(
                          width: 90,
                          height: 90,
                          child: Icon(Icons.play_arrow,
                              size: 60, color: AppColors.base),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('JUGAR', style: AppText.etiqueta),
                  ],
                ),
                BotonPildora(
                  texto: 'AJUSTES',
                  onTap: () => _abrir(context, const OpcionesScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}