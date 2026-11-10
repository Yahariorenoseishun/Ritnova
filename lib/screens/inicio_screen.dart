import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/boton_pildora.dart';
import 'lista_canciones_screen.dart';
import 'opciones_screen.dart';
// 👇 1. IMPORTAMOS LA NUEVA PANTALLA
import 'ritnova_native_screen.dart'; 

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
                        titulo: 'FAVORITOS', soloFavoritos: true),
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
                          const ListaCancionesScreen(titulo: 'NIVELES'),
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
            
            // 👇 2. AQUÍ ESTÁ EL BOTÓN PARA ABRIR EL PROYECTO DE KOTLIN
            const SizedBox(height: 40), // Un espacio para que no quede pegado
            ElevatedButton.icon(
              onPressed: () => _abrir(context, const RitnovaScreen()), // Abre la pantalla
              icon: const Icon(Icons.phone_android),
              label: const Text("Ver Proyecto Kotlin"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87, // Color oscuro para que resalte
                foregroundColor: Colors.yellow,  // Letras amarillas
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // 👆 FIN DEL BOTÓN
          ],
        ),
      ),
    );
  }
}