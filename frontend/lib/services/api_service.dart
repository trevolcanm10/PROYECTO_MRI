import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/resultado_model.dart';

class ApiService {
  // ⚠️ Asegúrate de que Flask esté corriendo en este puerto
  static const String _baseUrl = 'http://localhost:5000';

  /// Envía la imagen como bytes (Uint8List) — compatible con Flutter Web.
  /// No usa dart:io ni File.
  static Future<ResultadoModel> clasificar({
    required Uint8List bytes,
    required String nombreArchivo,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/clasificar');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',          // nombre del campo — igual que en Flask
          bytes,
          filename: nombreArchivo,
        ),
      );

    final streamed = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception(
        'Sin respuesta del servidor. ¿Está Flask corriendo en el puerto 5000?',
      ),
    );

    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ResultadoModel.fromJson(json);
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    }
  }
}
