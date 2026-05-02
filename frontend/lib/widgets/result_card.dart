import 'package:flutter/material.dart';
import '../../models/resultado_model.dart';

class ResultCard extends StatelessWidget {
  final ResultadoModel resultado;
  const ResultCard({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            resultado.color.withOpacity(0.22),
            resultado.color.withOpacity(0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: resultado.color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(
            resultado.clase.toLowerCase() == 'notumor'
                ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            color: resultado.color,
            size: 44,
          ),
          const SizedBox(height: 10),
          Text(
            resultado.clase,
            style: TextStyle(
              color: resultado.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultado.descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
