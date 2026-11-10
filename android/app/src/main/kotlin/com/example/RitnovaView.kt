package com.example.ritnova

import android.content.Context
import android.view.View
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable // 👈 IMPORT AGREGADO
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.launch

// ============================================================
// PUENTE PARA FLUTTER
// ============================================================
class RitnovaNativeView(context: Context, id: Int, args: Any?) : PlatformView {
    private val composeView = ComposeView(context).apply {
        setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
        setContent {
            MaterialTheme {
                RitnovaApp()
            }
        }
    }
    override fun getView(): View = composeView
    override fun dispose() {}
}

class RitnovaViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return RitnovaNativeView(context, viewId, args)
    }
}

// ============================================================
// COLORES
// ============================================================
val BgColor = Color(0xFF1A1B1F)
val SurfaceColor = Color(0xFF2C2D31)
val YellowColor = Color(0xFFFACC15)
val OrangeColor = Color(0xFFFF9800)
val TextColor = Color(0xFFFFFFFF)

// ============================================================
// APP PRINCIPAL CON MENÚ LATERAL
// ============================================================
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RitnovaApp() {
    var pantallaActual by remember { mutableStateOf("Inicio") }
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                drawerContainerColor = BgColor,
                drawerContentColor = TextColor
            ) {
                Spacer(Modifier.height(30.dp))
                Text(
                    "RITNOVA", 
                    color = OrangeColor, 
                    fontSize = 24.sp, 
                    fontWeight = FontWeight.Black,
                    modifier = Modifier.padding(16.dp)
                )
                HorizontalDivider(color = SurfaceColor, thickness = 1.dp)
                
                // Botones del menú
                DrawerItem("Inicio", pantallaActual == "Inicio") { 
                    pantallaActual = "Inicio"; scope.launch { drawerState.close() } 
                }
                DrawerItem("Niveles", pantallaActual == "Niveles") { 
                    pantallaActual = "Niveles"; scope.launch { drawerState.close() } 
                }
                DrawerItem("Opciones", pantallaActual == "Opciones") { 
                    pantallaActual = "Opciones"; scope.launch { drawerState.close() } 
                }
                DrawerItem("Favoritos", pantallaActual == "Favoritos") { 
                    pantallaActual = "Favoritos"; scope.launch { drawerState.close() } 
                }
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text(pantallaActual, color = TextColor) },
                    navigationIcon = {
                        IconButton(onClick = { scope.launch { drawerState.open() } }) {
                            Text("☰", color = YellowColor, fontSize = 28.sp) 
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = BgColor)
                )
            },
            containerColor = BgColor
        ) { padding ->
            Box(Modifier.padding(padding).fillMaxSize()) {
                when (pantallaActual) {
                    "Inicio" -> PantallaSimuladaInicio()
                    "Niveles" -> PantallaSimuladaNiveles()
                    "Opciones" -> PantallaSimuladaOpciones()
                    "Favoritos" -> PantallaSimuladaFavoritos()
                }
            }
        }
    }
}

@Composable
fun DrawerItem(texto: String, seleccionado: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(if (seleccionado) SurfaceColor else Color.Transparent)
            .clickable { onClick() } // 👈 ARREGLADO AQUÍ
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = texto, 
            color = if (seleccionado) YellowColor else TextColor,
            fontSize = 18.sp,
            fontWeight = if (seleccionado) FontWeight.Bold else FontWeight.Normal,
            modifier = Modifier.weight(1f)
        )
    }
}

// ============================================================
// PANTALLAS SIMULADAS
// ============================================================
@Composable
fun PantallaSimuladaInicio() {
    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("RITNOVA", color = OrangeColor, fontSize = 40.sp, fontWeight = FontWeight.Black)
        Spacer(Modifier.height(40.dp))
        Box(
            modifier = Modifier.size(100.dp).clip(CircleShape).background(OrangeColor),
            contentAlignment = Alignment.Center
        ) {
            Text("▶", color = TextColor, fontSize = 50.sp)
        }
        Spacer(Modifier.height(10.dp))
        Text("JUGAR", color = TextColor, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun PantallaSimuladaNiveles() {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("Selecciona un Nivel", color = YellowColor, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(16.dp))
        NivelBoton("MUSIC - 1", "⭐⭐⭐☆☆")
        NivelBoton("MUSIC - 2", "⭐⭐⭐⭐☆")
        NivelBoton("MUSIC - 3", "⭐⭐⭐⭐⭐")
    }
}

@Composable
fun NivelBoton(titulo: String, estrellas: String) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceColor)
    ) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(titulo, color = TextColor, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
            Text(estrellas, color = YellowColor)
        }
    }
}

@Composable
fun PantallaSimuladaOpciones() {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp).verticalScroll(rememberScrollState())) {
        Text("Opciones", color = YellowColor, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(24.dp))
        
        Text("Volumen Música - 80%", color = TextColor)
        Slider(value = 0.8f, onValueChange = {}, colors = SliderDefaults.colors(thumbColor = YellowColor, activeTrackColor = YellowColor))
        
        Spacer(Modifier.height(16.dp))
        
        Text("Volumen Efectos - 50%", color = TextColor)
        Slider(value = 0.5f, onValueChange = {}, colors = SliderDefaults.colors(thumbColor = YellowColor, activeTrackColor = YellowColor))
    }
}

@Composable
fun PantallaSimuladaFavoritos() {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("Tus Favoritos", color = YellowColor, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(16.dp))
        NivelBoton("FAV - 1", "⭐⭐⭐⭐⭐")
        NivelBoton("FAV - 2", "⭐⭐⭐☆☆")
    }
}