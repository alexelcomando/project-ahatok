import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

/// Pantalla de perfil con diseño Clean White minimalista
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
              ),
            );
          }

          if (!authProvider.isAuthenticated) {
            return _buildGuestState(context, authProvider);
          }

          return _buildAuthenticatedState(context, authProvider);
        },
      ),
    );
  }

  /// Construye el estado cuando el usuario NO está logueado (Guest)
  Widget _buildGuestState(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de usuario grande
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline,
                size: 64,
                color: Color(0xFF9E9E9E),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Texto descriptivo
            Text(
              'Guarda tus videos favoritos\ny no los pierdas nunca.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Botón "Continuar con Google"
            _buildGoogleSignInButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de Google Sign-In
  Widget _buildGoogleSignInButton(
      BuildContext context, AuthProvider authProvider) {
    return GestureDetector(
      onTap: authProvider.isLoading
          ? null
          : () async {
              try {
                await authProvider.signInWithGoogle(context);
              } catch (e) {
                // El error ya se muestra en el provider
              }
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de Google (simulado con icono)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Icon(
                Icons.g_mobiledata,
                size: 20,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continuar con Google',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el estado cuando el usuario SÍ está logueado
  Widget _buildAuthenticatedState(
      BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;
    final isPremium = authProvider.isPremium;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Header con foto de perfil y nombre
          _buildUserHeader(user, isPremium),
          
          const SizedBox(height: 32),
          
          // Lista de historial desde Firestore
          _buildHistorySection(user.uid),
          
          const SizedBox(height: 24),
          
          // Botón de cerrar sesión
          _buildSignOutButton(context, authProvider),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Construye el header del usuario con foto y nombre
  Widget _buildUserHeader(User user, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Foto de perfil circular
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFF7F7F7),
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF9E9E9E),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Nombre y badge Premium
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.displayName ?? 'Usuario',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 20,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9E9E9E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de historial desde Firestore
  Widget _buildHistorySection(String uid) {
    final authService = AuthService();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Historial',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: authService.getUserHistoryStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Error al cargar historial',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay descargas recientes',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildHistoryCard(data);
              },
            );
          },
        ),
      ],
    );
  }

  /// Construye una tarjeta de historial
  Widget _buildHistoryCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: data['coverUrl'] != null && data['coverUrl'].toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.network(
                      data['coverUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.play_circle_outline,
                          size: 32,
                          color: Color(0xFF9E9E9E),
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.play_circle_outline,
                    size: 32,
                    color: Color(0xFF9E9E9E),
                  ),
          ),
          
          // Información del video
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['description']?.toString() ?? 'Video de TikTok',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (data['author'] != null)
                    Text(
                      '@${data['author']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón de cerrar sesión
  Widget _buildSignOutButton(
      BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextButton(
        onPressed: authProvider.isLoading
            ? null
            : () async {
                await authProvider.signOut(context);
              },
        child: Text(
          'Cerrar Sesión',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF9E9E9E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

