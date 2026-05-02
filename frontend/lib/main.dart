import 'package:flutter/material.dart';
import 'views/clasificacion_view.dart';

void main() {
  runApp(const BrainScanApp());
}

class BrainScanApp extends StatelessWidget {
  const BrainScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainScan CNN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ClasificacionView(),
    );
  }
}
