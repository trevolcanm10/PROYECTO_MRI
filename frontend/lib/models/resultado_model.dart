import 'package:flutter/material.dart';

class ResultadoModel {
  final String prediccion;
  final String nombreImagen;
  final Map<String, double> probabilidades;

  ResultadoModel({
    required this.prediccion,
    required this.nombreImagen,
    required this.probabilidades,
  });

  factory ResultadoModel.fromJson(Map<String, dynamic> json) {
    final rawProbs = json['probs'] as Map<String, dynamic>;
    return ResultadoModel(
      prediccion: json['prediction'] as String,
      nombreImagen: json['image_name'] as String,
      probabilidades: rawProbs.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
    );
  }

  /// Extrae la clase: "Predicción: GLIOMA" → "GLIOMA"
  String get clase => prediccion.replaceAll('Predicción: ', '').trim();

  Color get color {
    switch (clase.toLowerCase()) {
      case 'notumor':   return const Color(0xFF27AE60);
      case 'glioma':    return const Color(0xFFE74C3C);
      case 'meningioma':return const Color(0xFFF39C12);
      case 'pituitary': return const Color(0xFF9B59B6);
      default:          return const Color(0xFF3498DB);
    }
  }

  String get descripcion {
    switch (clase.toLowerCase()) {
      case 'notumor':
        return 'No se detectó tumor en la imagen.';
      case 'glioma':
        return 'Se detectó Glioma — tumor originado en células gliales.';
      case 'meningioma':
        return 'Se detectó Meningioma — tumor en las membranas cerebrales.';
      case 'pituitary':
        return 'Se detectó Tumor Pituitario en la glándula pituitaria.';
      default:
        return prediccion;
    }
  }
}
