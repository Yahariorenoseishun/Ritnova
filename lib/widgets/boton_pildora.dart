   import 'package:material_ui/material_ui.dart';
   import '../theme/app_colors.dart';
   import '../theme/app_text.dart';

   class BotonPildora extends StatelessWidget {
     final String texto;
     final VoidCallback onTap; // lo que pasa al tocar el botón

     const BotonPildora({super.key, required this.texto, required this.onTap});

     @override
     Widget build(BuildContext context) {
       return Material(
         color: Colors.transparent,
         child: InkWell(
           onTap: onTap,
           borderRadius: BorderRadius.circular(100),
           splashColor: AppColors.secondarySoft, // efecto al presionar
           child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(100), // píldora
               border: Border.all(color: AppColors.secondary, width: 2),
             ),
             child: Text(
               texto,
               style: AppText.etiqueta.copyWith(color: AppColors.secondary),
             ),
           ),
         ),
       );
     }
   }