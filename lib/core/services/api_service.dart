import 'package:dio/dio.dart';

/// Servicio para manejar todas las comunicaciones con el backend
class ApiService {
  // TODO: Actualizar con tu URL de producción real de Render
  // Para producción: "https://ahatok-backend.onrender.com/api/v1"
  static const String BASE_URL = "https://ahatok-backend.onrender.com/api/v1";
  
  // TODO: Configurar tu API Secret Key (debería venir de SharedPreferences o variables de entorno)
  static const String API_SECRET_KEY = "ahatok-secret-key-2024-change-in-production";
  
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': API_SECRET_KEY, // Header de autenticación
        },
      ),
    );
  }

  /// Limpia y procesa el video de TikTok
  /// Retorna la URL del video limpio o los datos del video
  Future<Map<String, dynamic>> cleanVideo(String url) async {
    try {
      // Realizar petición POST al endpoint /clean
      final response = await _dio.post(
        '/clean',
        data: {
          'url': url,
        },
      );

      // Verificar que la respuesta sea exitosa
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        
        // Normalizar la respuesta para compatibilidad con el código existente
        return {
          'success': true,
          'data': {
            'videoUrl': data['video_url'],
            'thumbnail': data['cover_url'],
            'title': data['description'],
            'duration': data['duration'],
            'author': data['author'],
            'originalUrl': data['original_url'],
          },
          'message': response.data['message'] ?? 'Video procesado exitosamente',
        };
      } else {
        throw Exception(response.data['message'] ?? 'Error desconocido del servidor');
      }
    } on DioException catch (e) {
      // Manejo de errores de Dio
      if (e.response != null) {
        // El servidor respondió con un código de error
        final statusCode = e.response!.statusCode;
        final errorMessage = e.response!.data['message'] ?? 'Error del servidor';
        
        if (statusCode == 403) {
          throw Exception('API Key inválida. Acceso denegado.');
        } else if (statusCode == 400) {
          throw Exception(errorMessage);
        } else if (statusCode == 404) {
          throw Exception('Video no encontrado. Verifica la URL.');
        } else if (statusCode == 503) {
          throw Exception('Servicio no disponible. Intenta más tarde.');
        } else {
          throw Exception('Error del servidor: $errorMessage');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Error de conexión. Verifica que el servidor esté funcionando.');
      } else {
        throw Exception('Error al procesar el video: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }

  /// Método para hacer POST requests genéricos
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      throw Exception('Error en la petición POST: ${e.toString()}');
    }
  }
}

