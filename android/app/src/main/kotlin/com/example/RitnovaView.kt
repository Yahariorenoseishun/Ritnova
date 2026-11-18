package com.example.ritnova

import android.content.Context
import android.content.ContextWrapper
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.View
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
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
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlin.math.sqrt

// ============================================================
// 1. EL PUENTE PARA FLUTTER (Ciclo de vida correcto)
// ============================================================
class RitnovaNativeView(context: Context, id: Int, args: Any?) : PlatformView {
    private val composeView = ComposeView(context).apply {
        val activity = context.findActivity()
        if (activity != null) {
            val lifecycleOwner = activity as? LifecycleOwner
            val viewModelStoreOwner = activity as? ViewModelStoreOwner
            val savedStateRegistryOwner = activity as? SavedStateRegistryOwner

            if (lifecycleOwner != null) setViewTreeLifecycleOwner(lifecycleOwner)
            if (viewModelStoreOwner != null) setViewTreeViewModelStoreOwner(viewModelStoreOwner)
            if (savedStateRegistryOwner != null) setViewTreeSavedStateRegistryOwner(savedStateRegistryOwner)
        }

        setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
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
// 2. COLORES Y APP PRINCIPAL
// ============================================================
val BgColor = Color(0xFF1A1B1F)
val SurfaceColor = Color(0xFF2C2D31)
val YellowColor = Color(0xFFFACC15)
val OrangeColor = Color(0xFFFF9800)
val TextColor = Color(0xFFFFFFFF)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RitnovaApp() {
    var pantallaActual by remember { mutableStateOf("Inicio") }
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    var contador by remember { mutableStateOf(0) }
    var angulo by remember { mutableStateOf(0f) }

    LaunchedEffect(pantallaActual) {
        while (pantallaActual == "Ritmo") {
            delay(1000)
            contador++
            angulo = (angulo + 30f) % 360f
        }
    }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(drawerContainerColor = BgColor, drawerContentColor = TextColor) {
                Spacer(Modifier.height(30.dp))
                Text("RITNOVA", color = OrangeColor, fontSize = 24.sp, fontWeight = FontWeight.Black, modifier = Modifier.padding(16.dp))
                HorizontalDivider(color = SurfaceColor, thickness = 1.dp)

                DrawerItem("Inicio", pantallaActual == "Inicio") { pantallaActual = "Inicio"; scope.launch { drawerState.close() } }
                DrawerItem("Niveles", pantallaActual == "Niveles") { pantallaActual = "Niveles"; scope.launch { drawerState.close() } }
                DrawerItem("Ritmo", pantallaActual == "Ritmo") { pantallaActual = "Ritmo"; scope.launch { drawerState.close() } }
                DrawerItem("Opciones", pantallaActual == "Opciones") { pantallaActual = "Opciones"; scope.launch { drawerState.close() } }
                DrawerItem("Favoritos", pantallaActual == "Favoritos") { pantallaActual = "Favoritos"; scope.launch { drawerState.close() } }
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
                    "Ritmo" -> PantallaRitmo(contador, angulo)
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
        modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp).clip(RoundedCornerShape(8.dp))
            .background(if (seleccionado) SurfaceColor else Color.Transparent).clickable { onClick() }.padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = texto, color = if (seleccionado) YellowColor else TextColor, fontSize = 18.sp, fontWeight = if (seleccionado) FontWeight.Bold else FontWeight.Normal, modifier = Modifier.weight(1f))
    }
}

// ============================================================
// 3. PANTALLAS SIMULADAS
// ============================================================
@Composable
fun PantallaSimuladaInicio() {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
        Text("RITNOVA", color = OrangeColor, fontSize = 40.sp, fontWeight = FontWeight.Black)
        Spacer(Modifier.height(40.dp))
        Box(modifier = Modifier.size(100.dp).clip(CircleShape).background(OrangeColor), contentAlignment = Alignment.Center) { Text("▶", color = TextColor, fontSize = 50.sp) }
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
    Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), colors = CardDefaults.cardColors(containerColor = SurfaceColor)) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(titulo, color = TextColor, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
            Text(estrellas, color = YellowColor)
        }
    }
}

// ============================================================
// 4. PANTALLA RITMO (Física + Tap + Acelerómetro mejorado)
// ============================================================
@Composable
fun PantallaRitmo(contador: Int, angulo: Float) {
    val context = LocalContext.current
    val density = LocalDensity.current

    var posX by remember { mutableFloatStateOf(0f) }
    var posY by remember { mutableFloatStateOf(0f) }
    var velX by remember { mutableFloatStateOf(0f) }
    var velY by remember { mutableFloatStateOf(0f) }

    // 1. MOTOR DE FÍSICA (Gravedad un poco más suave)
    LaunchedEffect(Unit) {
        var lastTime = 0L
        val gravity = 1800f // Bajamos la gravedad para que flote más
        val friction = 0.98f

        while (isActive) {
            androidx.compose.runtime.withFrameNanos { time ->
                if (lastTime != 0L) {
                    val dt = (time - lastTime) / 1_000_000_000f
                    velY += gravity * dt
                    posX += velX * dt
                    posY += velY * dt
                    velX *= friction
                }
                lastTime = time
            }
        }
    }

    // 2. SENSOR ACELERÓMETRO (Agitar para que rebote en el techo)
    DisposableEffect(Unit) {
        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                event?.let {
                    val x = it.values[0]
                    val y = it.values[1]
                    val z = it.values[2]
                    
                    val force = sqrt(x * x + y * y + z * z)
                    
                    // Umbral más sensible
                    if (force > 11f) { 
                        // Mueve a los lados
                        velX += x * 150f 
                        
                        // Salto hacia arriba (rebote en el techo)
                        if (posY < -100f || velY > 0f) {
                            velY -= 600f 
                        }
                    }
                }
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        if (accelerometer != null) {
            sensorManager.registerListener(listener, accelerometer, SensorManager.SENSOR_DELAY_GAME)
        }
        onDispose { sensorManager.unregisterListener(listener) }
    }

    // 3. RENDERIZADO Y TOQUE
    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .pointerInput(Unit) {
                detectTapGestures(
                    onTap = {
                        velY = -1800f // El toque la hace saltar fuerte
                    }
                )
            }
    ) {
        val screenWidthPx = with(density) { maxWidth.toPx() }
        val screenHeightPx = with(density) { maxHeight.toPx() }
        val pillWidthPx = with(density) { 160.dp.toPx() }
        val pillHeightPx = with(density) { 80.dp.toPx() }

        val maxX = (screenWidthPx / 2) - (pillWidthPx / 2)
        val maxY = (screenHeightPx / 2) - (pillHeightPx / 2)

        // Límites y rebotes
        if (posY > maxY) { posY = maxY; velY = -velY * 0.6f; velX *= 0.9f }
        if (posY < -maxY) { posY = -maxY; velY = -velY * 0.6f }
        if (posX > maxX) { posX = maxX; velX = -velX * 0.6f }
        if (posX < -maxX) { posX = -maxX; velX = -velX * 0.6f }

        Text(text = "Contador: $contador", color = YellowColor, fontSize = 20.sp, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.TopEnd).padding(16.dp))
        Text(text = "¡Toca la pantalla o agita el celular!", color = Color.Gray, fontSize = 14.sp, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.TopCenter).padding(24.dp))

        Box(
            modifier = Modifier.align(Alignment.Center).graphicsLayer {
                translationX = posX
                translationY = posY
                rotationZ = angulo + (velX * 0.05f)
            }.size(width = 160.dp, height = 80.dp).clip(CircleShape).background(OrangeColor),
            contentAlignment = Alignment.Center
        ) { Text("♪", color = TextColor, fontSize = 40.sp, fontWeight = FontWeight.Black) }
    }
}

@Composable
fun PantallaSimuladaOpciones() {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp).verticalScroll(rememberScrollState())) {
        Text("Opciones", color = YellowColor, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(24.dp))
        Text("Volumen Música - 80%", color = TextColor)
        Slider(value = 0.8f, onValueChange = {}, colors = SliderDefaults.colors(thumbColor = YellowColor, activeTrackColor = YellowColor))
        Spacer(modifier = Modifier.height(16.dp))
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

// Extensión para encontrar la Activity de Flutter
fun Context.findActivity(): android.app.Activity? {
    var context = this
    while (context is ContextWrapper) {
        if (context is android.app.Activity) return context
        context = context.baseContext
    }
    return null
}