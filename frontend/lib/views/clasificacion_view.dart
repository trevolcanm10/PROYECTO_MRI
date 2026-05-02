import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../controllers/clasificacion_controller.dart';
import '../../models/resultado_model.dart';
import '../../widgets/probability_chart.dart';
import '../../widgets/result_card.dart';

// ✅ SIN dart:io  — funciona en Flutter Web
// ✅ SIN Image.file — usa Image.memory (Uint8List)
// ✅ SIN image_picker — usa file_picker con withData: true

class ClasificacionView extends StatefulWidget {
  const ClasificacionView({super.key});

  @override
  State<ClasificacionView> createState() => _ClasificacionViewState();
}

class _ClasificacionViewState extends State<ClasificacionView>
    with SingleTickerProviderStateMixin {

  final ClasificacionController _ctrl = ClasificacionController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _ctrl.addListener(() {
      setState(() {});
      if (_ctrl.tieneResultado) _fadeCtrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), Color(0xFF1E3C72), Color(0xFF2A5298)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar()),
              SliverToBoxAdapter(child: _buildZonaImagen()),
              SliverToBoxAdapter(child: _buildBotones()),
              if (_ctrl.error != null)
                SliverToBoxAdapter(child: _buildError()),
              if (_ctrl.cargando)
                SliverToBoxAdapter(child: _buildCargando()),
              if (_ctrl.tieneResultado)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildResultados(_ctrl.resultado!),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BrainScan CNN',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Clasificador de tumores cerebrales',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12)),
            ],
          ),
          const Spacer(),
          // Botón limpiar
          if (_ctrl.tieneImagen)
            IconButton(
              onPressed: _ctrl.limpiar,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
              tooltip: 'Limpiar',
            ),
        ],
      ),
    );
  }

  // ── Zona imagen ───────────────────────────────────────────────────────────

  Widget _buildZonaImagen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _ImagenZona(
        // ✅ Pasa bytes (Uint8List) — NO File, NO dart:io
        imageBytes: _ctrl.imagenBytes,
        onTap: _ctrl.cargando ? null : _ctrl.seleccionarImagen,
      ),
    );
  }

  // ── Botones ───────────────────────────────────────────────────────────────

  Widget _buildBotones() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _Boton(
              label: 'Seleccionar imagen',
              icon: Icons.folder_open_rounded,
              outlined: true,
              onTap: _ctrl.cargando ? null : _ctrl.seleccionarImagen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Boton(
              label: 'Clasificar imagen',
              icon: Icons.manage_search_rounded,
              outlined: false,
              onTap: (_ctrl.tieneImagen && !_ctrl.cargando)
                  ? _ctrl.clasificar
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cargando ──────────────────────────────────────────────────────────────

  Widget _buildCargando() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircularProgressIndicator(
              strokeWidth: 2.5, color: Color(0xFF3498DB)),
          SizedBox(height: 14),
          Text('Analizando con el modelo CNN...',
              style: TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C).withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFE74C3C).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFE74C3C), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_ctrl.error!,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Resultados ────────────────────────────────────────────────────────────

  Widget _buildResultados(ResultadoModel res) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titulo('Resultado'),
          const SizedBox(height: 10),
          ResultCard(resultado: res),

          const SizedBox(height: 22),
          _Titulo('Probabilidades por clase'),
          const SizedBox(height: 10),
          _Tarjeta(child: ProbabilityChart(probabilidades: res.probabilidades)),

          const SizedBox(height: 22),
          _Titulo('Detalles'),
          const SizedBox(height: 10),
          _TablaProbabilidades(probabilidades: res.probabilidades),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sub-widgets
// ══════════════════════════════════════════════════════════════════════════════

/// Zona de previsualización de imagen.
/// ✅ Usa Image.memory (Uint8List) — NUNCA Image.file
class _ImagenZona extends StatelessWidget {
  final Uint8List? imageBytes; // ← Uint8List, NOT File
  final VoidCallback? onTap;

  const _ImagenZona({required this.imageBytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: imageBytes != null
                ? const Color(0xFF3498DB)
                : Colors.white70,
            width: imageBytes != null ? 2 : 1,
          ),
        ),
        child: imageBytes != null
            // ✅ Image.memory — funciona en Flutter Web
            ? ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.contain,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 56,
                      color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text(
                    'Selecciona una imagen MRI',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text('Galería o cámara',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 11)),
                ],
              ),
      ),
    );
  }
}

class _Boton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback? onTap;

  const _Boton({
    required this.label,
    required this.icon,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: habilitado ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : const Color(0xFF3498DB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: outlined ? Colors.white30 : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 7),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Text(texto,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4));
}

class _Tarjeta extends StatelessWidget {
  final Widget child;
  const _Tarjeta({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: child,
      );
}

class _TablaProbabilidades extends StatelessWidget {
  final Map<String, double> probabilidades;
  const _TablaProbabilidades({required this.probabilidades});

  static const Map<String, Color> _colores = {
    'glioma':     Color(0xFFE74C3C),
    'meningioma': Color(0xFFF39C12),
    'notumor':    Color(0xFF27AE60),
    'pituitary':  Color(0xFF9B59B6),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // Encabezado
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: const BoxDecoration(
              color: Color(0xFF3498DB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(
                    child: Text('Clase',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13))),
                Expanded(
                    child: Text('Probabilidad',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13))),
              ],
            ),
          ),
          // Filas
          ...probabilidades.entries.map((e) {
            final color = _colores[e.key] ?? const Color(0xFF3498DB);
            final pct = (e.value * 100).toStringAsFixed(2);
            final esMayor = e.value > 0.5;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(right: 7),
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle)),
                        Text(e.key,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text('$pct%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: esMayor ? color : Colors.white60,
                            fontWeight: esMayor
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
