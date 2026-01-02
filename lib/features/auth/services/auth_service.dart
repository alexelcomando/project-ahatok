import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Servicio para manejar la autenticación y operaciones de Firestore
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Obtiene el usuario actual
  User? get currentUser => _auth.currentUser;

  /// Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inicia sesión con Google
  /// Retorna el UserCredential si es exitoso
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el login
        throw Exception('El inicio de sesión fue cancelado');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Guardar o actualizar el usuario en Firestore
      await saveUserToFirestore(userCredential.user!);

      return userCredential;
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Guarda o actualiza el usuario en Firestore
  /// Si el documento no existe, lo crea con todos los campos
  /// Si existe, solo actualiza lastLogin
  Future<void> saveUserToFirestore(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      };

      if (!userDoc.exists) {
        // Crear nuevo documento con todos los campos
        await userRef.set({
          ...userData,
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Actualizar solo lastLogin
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
          // Actualizar también datos que puedan haber cambiado
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'email': user.email,
        });
      }
    } catch (e) {
      throw Exception('Error al guardar usuario en Firestore: ${e.toString()}');
    }
  }

  /// Guarda un video descargado en el historial del usuario
  /// Guarda en la sub-colección: users/{uid}/history
  Future<void> saveDownloadToHistory(
    String uid,
    Map<String, dynamic> videoData,
  ) async {
    try {
      final historyRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc();

      await historyRef.set({
        'videoUrl': videoData['videoUrl'] ?? '',
        'coverUrl': videoData['coverUrl'] ?? '',
        'description': videoData['description'] ?? '',
        'originalUrl': videoData['originalUrl'] ?? '',
        'author': videoData['author'] ?? '',
        'duration': videoData['duration'] ?? 0,
        'downloadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
          'Error al guardar descarga en historial: ${e.toString()}');
    }
  }

  /// Obtiene el historial de descargas del usuario como Stream
  /// Retorna un Stream de QuerySnapshot para usar con StreamBuilder
  Stream<QuerySnapshot> getUserHistoryStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('downloadedAt', descending: true)
        .snapshots();
  }

  /// Obtiene los datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: ${e.toString()}');
    }
  }

  /// Actualiza el estado Premium del usuario
  Future<void> updatePremiumStatus(String uid, bool isPremium) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isPremium': isPremium,
      });
    } catch (e) {
      throw Exception(
          'Error al actualizar estado Premium: ${e.toString()}');
    }
  }
}

