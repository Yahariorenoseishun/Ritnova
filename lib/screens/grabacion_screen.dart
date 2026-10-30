import 'dart:async';
import 'package:audioplayers/audioplayers.dart' show AudioPlayer;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../models/cancion.dart';
import '../models/configuracion_audio.dart';
import '../models/grabador.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/barra_titulo.dart';
import '../widgets/boton_pildora.dart';

// Herramienta para crear el patrón de una canción tocando mientras suena
class GrabacionScreen extends StatefulWidget {
  const GrabacionScreen({super.key});

  @override
  State<GrabacionScreen> createState() => _GrabacionScreenState();
}

class _GrabacionScreenState extends State<GrabacionScreen> {
  late Cancion _cancion;
  double _bpm = 120;
  double _inicio = 2.0; // segundo en que cae el primer tiempo de la canción
  double _retrasoMs = 40; // lo que tardas en reaccionar (se resta a cada toque)

  AudioPlayer? _reproductor;
  StreamSubscription<Duration>? _subPos;
  StreamSubscription<void>? _subFin;
  Timer? _reloj;
  double _posAudio = 0;
  DateTime _momentoPos = DateTime.now();
  bool _hayPos = false;
  bool _sonando = false;
  bool _grabando = false;
  String _mensaje = '';

  final List<Toque> _toques = [];
  final Map<int, Toque> _abajo = {}; // dedo -> toque que está presionado
  final Set<int> _carrilesActivos = {};

  @override
  void initState() {
    super.initState();
    _cancion = canciones.values.first;
    _bpm = _cancion.bpm;
  }

  // Segundo actual de la canción (usa la posición real del audio)
  double get _segundos {
    if (!_hayPos) return 0;
    final pasado = DateTime.now().difference(_momentoPos).inMicroseconds / 1000000;
    return _posAudio + pasado;
  }

  Future<void> _iniciar(bool grabar) async {
    if (_sonando) return;
    setState(() {
      _sonando = true;
      _grabando = grabar;
      _mensaje = '';
      _toques.clear();
      _abajo.clear();
      _hayPos = false;
    });
    final reproductor = await FlameAudio.playLongAudio(
      _cancion.archivo,
      volume: ConfiguracionAudio.volumenMusica / 100,
    );
    if (!mounted || !_sonando) {
      reproductor.dispose(); // pulsaste PARAR antes de que arrancara
      return;
    }
    _reproductor = reproductor;
    _subPos = reproductor.onPositionChanged.listen((p) {
      _posAudio = p.inMicroseconds / 1000000;
      _momentoPos = DateTime.now();
      _hayPos = true;
    });
    _subFin = reproductor.onPlayerComplete.listen((_) => _parar());
    // Redibuja la pantalla ~30 veces por segundo (para el pulso y el tiempo)
    _reloj = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _parar() async {
    if (!_sonando) return;
    final eraGrabacion = _grabando;
    _sonando = false;
    _grabando = false;
    _reloj?.cancel();
    await _subPos?.cancel();
    await _subFin?.cancel();
    _reproductor?.dispose();
    _reproductor = null;
    _abajo.clear();
    _carrilesActivos.clear();
    if (mounted) setState(() {});
    if (eraGrabacion && _toques.isNotEmpty && mounted) _mostrarResultado();
  }

  // Un dedo apoyó un carril
  void _abajoPad(int carril, int dedo) {
    setState(() => _carrilesActivos.add(carril));
    if (!_grabando) return;
    final toque = Toque(_segundos - _retrasoMs / 1000, carril);
    _toques.add(toque);
    _abajo[dedo] = toque;
  }

  // Un dedo se levantó: así se sabe cuánto duró (para teclas largas)
  void _arribaPad(int carril, int dedo) {
    setState(() => _carrilesActivos.remove(carril));
    final toque = _abajo.remove(dedo);
    if (toque != null) {
      toque.duracion = (_segundos - _retrasoMs / 1000) - toque.tiempo;
    }
  }

  void _mostrarResultado() {
    final texto = fragmentoDart(toques: _toques, bpm: _bpm, inicio: _inicio);
    debugPrint(texto); // también sale en la consola de VS Code
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('PATRÓN GRABADO', style: AppText.subtitulo),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: SelectableText(
              texto,
              style: const TextStyle(
                  fontFamily: 'monospace', fontSize: 12, color: AppColors.text),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CERRAR', style: AppText.etiqueta),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: texto));
              Navigator.pop(ctx);
              setState(() => _mensaje = 'Patrón copiado: pégalo en cancion.dart');
            },
            child: Text('COPIAR',
                style: AppText.etiqueta.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reloj?.cancel();
    _subPos?.cancel();
    _subFin?.cancel();
    _reproductor?.dispose();
    super.dispose();
  }

  // Un control con 4 botones: -- - valor + ++
  Widget _control(String titulo, String valor, double chico, double grande,
      void Function(double) cambiar) {
    Widget boton(String s, double delta) => Material(
          color: AppColors.text,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => setState(() => cambiar(delta)),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Text(s,
                    style: AppText.etiqueta
                        .copyWith(fontSize: 12, color: AppColors.base)),
              ),
            ),
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titulo,
            style: AppText.etiqueta
                .copyWith(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            boton('--', -grande),
            const SizedBox(width: 4),
            boton('-', -chico),
            SizedBox(
              width: 64,
              child: Text(valor,
                  textAlign: TextAlign.center,
                  style: AppText.etiqueta.copyWith(color: AppColors.primary)),
            ),
            boton('+', chico),
            const SizedBox(width: 4),
            boton('++', grande),
          ],
        ),
      ],
    );
  }

  // Círculo que parpadea en cada tiempo según el BPM y el INICIO elegidos
  Widget _metronomo() {
    final tiempo = 60 / _bpm;
    final t = _segundos - _inicio;
    bool pulso = false;
    bool acento = false;
    if (_sonando && _hayPos && t >= 0) {
      pulso = (t % tiempo) / tiempo < 0.18;
      acento = pulso && (t / tiempo).floor() % 4 == 0; // primer tiempo del compás
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pulso
            ? (acento ? AppColors.primary : AppColors.secondary)
            : AppColors.surface,
      ),
    );
  }

  // Un carril para tocar (Listener detecta cada dedo por separado)
  Widget _pad(int carril) {
    final activo = _carrilesActivos.contains(carril);
    final color = carril.isEven ? AppColors.secondary : AppColors.primary;
    return Expanded(
      child: Listener(
        onPointerDown: (e) => _abajoPad(carril, e.pointer),
        onPointerUp: (e) => _arribaPad(carril, e.pointer),
        onPointerCancel: (e) => _arribaPad(carril, e.pointer),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: activo ? color : color.withAlpha(70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text('${carril + 1}',
              style: AppText.subtitulo
                  .copyWith(color: activo ? AppColors.base : color)),
        ),
      ),
    );
  }

  String _estado() {
    if (_sonando) {
      final s = _segundos;
      final minutos = s ~/ 60;
      final segundos = (s % 60).floor().toString().padLeft(2, '0');
      final modo = _grabando ? 'GRABANDO' : 'PROBANDO';
      return '$modo  ·  $minutos:$segundos  ·  notas: ${_toques.length}';
    }
    if (_mensaje.isNotEmpty) return _mensaje;
    return 'PROBAR: ajusta BPM e INICIO hasta que el pulso coincida con la canción.\n'
        'GRABAR: toca los carriles al ritmo (mantén presionado para teclas largas).';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BarraTitulo(titulo: 'GRABAR PATRÓN'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: _cancion.id,
                          dropdownColor: AppColors.surface,
                          style: AppText.etiqueta,
                          items: [
                            for (final c in canciones.values)
                              DropdownMenuItem(value: c.id, child: Text(c.titulo)),
                          ],
                          onChanged: _sonando
                              ? null
                              : (id) => setState(() {
                                    _cancion = canciones[id]!;
                                    _bpm = _cancion.bpm;
                                  }),
                        ),
                        _control('BPM', _bpm.toStringAsFixed(1), 0.1, 1.0,
                            (d) => _bpm = (_bpm + d).clamp(40.0, 240.0)),
                        _control('INICIO (s)', _inicio.toStringAsFixed(2), 0.01, 0.1,
                            (d) => _inicio = (_inicio + d).clamp(0.0, 30.0)),
                        _control('RETRASO (ms)', _retrasoMs.toStringAsFixed(0), 5, 20,
                            (d) => _retrasoMs = (_retrasoMs + d).clamp(0.0, 200.0)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _metronomo(),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _estado(),
                  textAlign: TextAlign.center,
                  style: AppText.etiqueta
                      .copyWith(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ),
            SizedBox(
              height: 84,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [for (int i = 0; i < 4; i++) _pad(i)]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _sonando
                    ? [BotonPildora(texto: 'PARAR', onTap: _parar)]
                    : [
                        BotonPildora(texto: 'PROBAR', onTap: () => _iniciar(false)),
                        const SizedBox(width: 20),
                        BotonPildora(texto: 'GRABAR', onTap: () => _iniciar(true)),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}