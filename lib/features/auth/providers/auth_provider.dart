import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Provider para gestionar el estado de autenticación
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _user != null;
  
  /// Obtiene el estado Premium del usuario
  bool get isPremium {
    if (_userData != null) {
      return _userData!['isPremium'] ?? false;
    }
    return false;
  }

  AuthProvider() {
    // Escuchar cambios en el estado de autenticación
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  /// Inicia sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final userCredential = await _authService.signInWithGoogle();
      _user = userCredential.user;
      
      if (_user != null) {
        await _loadUserData(_user!.uid);
      }

      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      _showError(context, 'Error al iniciar sesión: ${e.toString()}');
      rethrow;
    }
  }

  /// Cierra sesión
  Future<void> signOut(BuildContext context) async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _userData = null;
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      _showError(context, 'Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Carga los datos del usuario desde Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _userData = await _authService.getUserData(uid);
      notifyListeners();
    } catch (e) {
      print('Error al cargar datos del usuario: ${e.toString()}');
    }
  }

  /// Actualiza el estado Premium
  Future<void> updatePremiumStatus(bool isPremium) async {
    if (_user == null) return;
    
    try {
      await _authService.updatePremiumStatus(_user!.uid, isPremium);
      if (_userData != null) {
        _userData!['isPremium'] = isPremium;
      }
      notifyListeners();
    } catch (e) {
      print('Error al actualizar estado Premium: ${e.toString()}');
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
}

