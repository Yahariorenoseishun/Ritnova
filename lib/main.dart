import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'models/progreso.dart';
import 'screens/inicio_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bloquea la app en horizontal, como en tu diseño
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await Progreso.instancia.cargar(); // lee lo guardado antes de mostrar nada
  runApp(const RitnovaApp());
}

class RitnovaApp extends StatelessWidget {
  const RitnovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RITNOVA',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.base,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      home: const InicioScreen(),
    );
  }
}