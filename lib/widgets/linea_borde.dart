import 'package:material_ui/material_ui.dart';

// Línea fina que marca los bordes de una pantalla (arriba y abajo de una lista)
class LineaBorde extends StatelessWidget {
  const LineaBorde({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0x24FFFFFF),
    );
  }
}