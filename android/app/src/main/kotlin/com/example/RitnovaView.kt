package com.example.ritnova

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.View
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity // 👈 IMPORT AGREGADO
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlin.math.sqrt

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
// APP PRINCIPAL
// ============================================================
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

                DrawerItem("Inicio", pantallaActual == "Inicio") {
                    pantallaActual = "Inicio"; scope.launch { drawerState.close() }
                }
                DrawerItem("Niveles", pantallaActual == "Niveles") {
                    pantallaActual = "Niveles"; scope.launch { drawerState.close() }
                }
                DrawerItem("Ritmo", pantallaActual == "Ritmo") {
                    pantallaActual = "Ritmo"; scope.launch { drawerState.close() }
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
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(if (seleccionado) SurfaceColor else Color.Transparent)
            .clickable { onClick() }
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
} // 👈 ESTA ES LA LLAVE QUE FALTABA

// ============================================================
// PANTALLA RITMO CON FÍSICA REAL
// ============================================================
@Composable
fun PantallaRitmo(contador: Int, angulo: Float) {
    val context = LocalContext.current
    val density = LocalDensity.current

    // Variables de física (ahora todo se calcula en Píxeles reales)
    var posX by remember { mutableFloatStateOf(0f) }
    var posY by remember { mutableFloatStateOf(0f) }
    var velX by remember { mutableFloatStateOf(0f) }
    var velY by remember { mutableFloatStateOf(0f) }

    // 1. MOTOR DE FÍSICA
    LaunchedEffect(Unit) {
        var lastTime = 0L
        val gravity = 2500f // Gravedad en píxeles por segundo
        val friction = 0.98f // Resistencia del aire

        while (isActive) {
            androidx.compose.runtime.withFrameNanos { time ->
                if (lastTime != 0L) {
                    val dt = (time - lastTime) / 1_000_000_000f
                    
                    // Aplicar gravedad hacia abajo
                    velY += gravity * dt

                    // Actualizar posición
                    posX += velX * dt
                    posY += velY * dt

                    // Fricción del aire (solo en X para que la gravedad siga funcionando en Y)
                    velX *= friction
                }
                lastTime = time
            }
        }
    }

    // 2. SENSOR ACELERÓMETRO
    DisposableEffect(Unit) {
        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        var lastTapTime = 0L

        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                event?.let {
                    val x = it.values[0]
                    val y = it.values[1]
                    val z = it.values[2]
                    
                    val force = sqrt(x * x + y * y + z * z)
                    
                    // a) AGITAR (Fuerza moderada): Mueve la píldora de lado
                    if (force > 9f && force < 15f) {
                        // Multiplicamos por 60 para que el movimiento sea notorio en píxeles
                        velX += x * 60f 
                    }
                    
                    // b) GOLPE SECO (Fuerza alta): Salto hacia arriba
                    if (force > 18f) {
                        val currentTime = System.currentTimeMillis()
                        if (currentTime - lastTapTime > 300) {
                            velY = -1800f // Salto fuerte
                            lastTapTime = currentTime
                        }
                    }
                }
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        if (accelerometer != null) {
            sensorManager.registerListener(listener, accelerometer, SensorManager.SENSOR_DELAY_GAME)
        }

        onDispose {
            sensorManager.unregisterListener(listener)
        }
    }

    // 3. RENDERIZADO Y LÍMITES
    BoxWithConstraints(modifier = Modifier.fillMaxSize()) {
        // Convertimos el tamaño de la pantalla y la píldora a PÍXELES reales
        val screenWidthPx = with(density) { maxWidth.toPx() }
        val screenHeightPx = with(density) { maxHeight.toPx() }
        
        val pillWidthPx = with(density) { 160.dp.toPx() }
        val pillHeightPx = with(density) { 80.dp.toPx() }

        // Límites reales restando la mitad de la píldora
        val maxX = (screenWidthPx / 2) - (pillWidthPx / 2)
        val maxY = (screenHeightPx / 2) - (pillHeightPx / 2)

        // Lógica de rebote y límites
        // Piso
        if (posY > maxY) {
            posY = maxY
            velY = -velY * 0.6f // Rebote perdiendo energía
            velX *= 0.9f // Fricción con el suelo
        }
        // Techo
        if (posY < -maxY) {
            posY = -maxY
            velY = -velY * 0.6f
        }
        // Pared Derecha
        if (posX > maxX) {
            posX = maxX
            velX = -velX * 0.6f
        }
        // Pared Izquierda
        if (posX < -maxX) {
            posX = -maxX
            velX = -velX * 0.6f
        }

        // Contador e instrucciones
        Text(
            text = "Contador: $contador",
            color = YellowColor,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.align(Alignment.TopEnd).padding(16.dp)
        )

        Text(
            text = "Agita el teléfono o dale un golpecito para saltar",
            color = Color.Gray,
            fontSize = 12.sp,
            modifier = Modifier.align(Alignment.TopCenter).padding(16.dp)
        )

        // Píldora
        Box(
            modifier = Modifier
                .align(Alignment.Center)
                .graphicsLayer {
                    translationX = posX
                    translationY = posY
                    rotationZ = angulo + (velX * 0.05f) // Rotación sutil basada en la velocidad X
                }
                .size(width = 160.dp, height = 80.dp)
                .clip(CircleShape)
                .background(OrangeColor),
            contentAlignment = Alignment.Center
        ) {
            Text("♪", color = TextColor, fontSize = 40.sp, fontWeight = FontWeight.Black)
        }
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