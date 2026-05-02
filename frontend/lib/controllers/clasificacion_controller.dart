import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/resultado_model.dart';
import '../services/api_service.dart';

/// Controlador que separa la lógica de negocio de la UI.
/// La vista solo llama métodos de este controlador y escucha
/// los ChangeNotifier para reconstruirse.
class ClasificacionController extends ChangeNotifier {
  // ── Estado ──────────────────────────────────────────────────────────────────
  Uint8List? imagenBytes;   // bytes de la imagen seleccionada (web-safe)
  String? nombreArchivo;    // nombre original del archivo
  ResultadoModel? resultado;
  bool cargando = false;
  String? error;

  bool get tieneImagen => imagenBytes != null;
  bool get tieneResultado => resultado != null;

  // ── Seleccionar imagen ───────────────────────────────────────────────────────
  Future<void> seleccionarImagen() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,   // ← clave: carga bytes en memoria (funciona en Web)
      );

      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.first;
      if (file.bytes == null) return;

      imagenBytes = file.bytes;
      nombreArchivo = file.name;
      resultado = null;
      error = null;
      notifyListeners();
    } catch (e) {
      error = 'No se pudo abrir el archivo: $e';
      notifyListeners();
    }
  }

  // ── Clasificar ───────────────────────────────────────────────────────────────
  Future<void> clasificar() async {
    if (imagenBytes == null || nombreArchivo == null) return;

    cargando = true;
    error = null;
    resultado = null;
    notifyListeners();

    try {
      resultado = await ApiService.clasificar(
        bytes: imagenBytes!,
        nombreArchivo: nombreArchivo!,
      );
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // ── Reset ────────────────────────────────────────────────────────────────────
  void limpiar() {
    imagenBytes = null;
    nombreArchivo = null;
    resultado = null;
    error = null;
    cargando = false;
    notifyListeners();
  }
}
