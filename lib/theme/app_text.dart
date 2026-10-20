   import 'package:flutter/widgets.dart';
   import 'package:google_fonts/google_fonts.dart';
   import 'app_colors.dart';

   // Los 4 estilos de texto de tu Figma, todos con Poppins
   class AppText {
     static final titulo = GoogleFonts.poppins(
         fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.text);
     static final subtitulo = GoogleFonts.poppins(
         fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text);
     static final contenido =
         GoogleFonts.poppins(fontSize: 18, color: AppColors.text);
     static final etiqueta = GoogleFonts.poppins(
         fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text);
   }