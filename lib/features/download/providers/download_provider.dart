import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/ad_service.dart';
import '../../auth/services/auth_service.dart';

/// Provider que gestiona el estado y la lógica de descarga de videos
class DownloadProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  bool _isPremium = false; // Se actualizará desde Firestore si hay usuario logueado
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _downloadHistory = [];

  // Getters
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get downloadHistory => _downloadHistory;

  /// Inicia el proceso de descarga
  /// [url] es la URL del video de TikTok
  /// [context] es necesario para mostrar diálogos o snackbars
  Future<void> startDownloadProcess(String url, BuildContext context) async {
    // Validación: verificar que el input no esté vacío
    if (url.trim().isEmpty) {
      _showError(context, 'Por favor, ingresa una URL válida');
      return;
    }

    if (!_isValidUrl(url)) {
      _showError(context, 'La URL ingresada no es válida');
      return;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      // Obtener estado Premium desde Firestore si hay usuario logueado
      await _updatePremiumStatus();

      // FLUJO CRÍTICO: Verificación Premium
      if (_isPremium) {
        // Usuario Premium: Llamar directamente a la API
        await _processVideo(url, context);
      } else {
        // Usuario Free: Mostrar anuncio primero
        await _showAdAndProcessVideo(url, context);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _showError(context, 'Error al procesar el video: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Valida si la URL es válida
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Muestra el anuncio y luego procesa el video
  Future<void> _showAdAndProcessVideo(String url, BuildContext context) async {
    // Mostrar el anuncio intersticial y esperar a que el usuario lo cierre
    await AdService.showInterstitial(
      onAdDismissed: () {
        // Callback opcional - el anuncio ya se cerró en este punto
      },
    );
    
    // SOLO después de que el usuario cierra el anuncio, procesamos el video
    await _processVideo(url, context);
  }

  /// Procesa el video llamando a la API
  Future<void> _processVideo(String url, BuildContext context) async {
    try {
      final response = await _apiService.cleanVideo(url);
      
      if (response['success'] == true) {
        final videoData = response['data'];
        
        // Agregar a la lista de historial local
        _downloadHistory.insert(0, {
          'url': url,
          'data': videoData,
          'timestamp': DateTime.now(),
        });
        notifyListeners();

        // INTEGRACIÓN CRÍTICA: Guardar en Firestore si hay usuario logueado
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            await _authService.saveDownloadToHistory(
              currentUser.uid,
              {
                'videoUrl': videoData['videoUrl'] ?? '',
                'coverUrl': videoData['thumbnail'] ?? videoData['coverUrl'] ?? '',
                'description': videoData['title'] ?? videoData['description'] ?? '',
                'originalUrl': url,
                'author': videoData['author'] ?? '',
                'duration': videoData['duration'] ?? 0,
              },
            );
          } catch (e) {
            // No fallar si hay error al guardar en Firestore
            print('Error al guardar en Firestore: ${e.toString()}');
          }
        }
      } else {
        throw Exception(response['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      throw Exception('Error al procesar el video: ${e.toString()}');
    }
  }

  /// Actualiza el estado Premium desde Firestore
  Future<void> _updatePremiumStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userData = await _authService.getUserData(currentUser.uid);
        if (userData != null) {
          _isPremium = userData['isPremium'] ?? false;
          notifyListeners();
        }
      } catch (e) {
        print('Error al obtener estado Premium: ${e.toString()}');
      }
    } else {
      _isPremium = false;
    }
  }

  /// Muestra un mensaje de error
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Actualiza el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Cambia el estado Premium (para testing)
  void setPremium(bool premium) {
    _isPremium = premium;
    notifyListeners();
  }

  /// Limpia el historial de descargas
  void clearHistory() {
    _downloadHistory.clear();
    notifyListeners();
  }

  /// Elimina un elemento del historial
  void removeFromHistory(int index) {
    if (index >= 0 && index < _downloadHistory.length) {
      _downloadHistory.removeAt(index);
      notifyListeners();
    }
  }
}

