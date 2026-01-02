import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/download_provider.dart';
import '../../auth/screens/profile_screen.dart';

/// Pantalla principal con diseño Clean White minimalista
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header Personalizado
            _buildHeader(),
            
            // Input de Descarga (Hero Section)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: _buildDownloadInput(),
            ),

            // Espacio negativo
            const SizedBox(height: 24),

            // Lista de Historial
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el header con botón de menú
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Botón de Menú
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 50,
              height: 50,
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
              child: const Icon(
                Icons.menu,
                color: Color(0xFF1A1A1A),
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          // Logo o título (opcional)
          Text(
            'AhaTok',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          // Espacio para balancear el diseño
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  /// Construye el input de descarga con botón integrado
  Widget _buildDownloadInput() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: [
              // TextField expandido
              Expanded(
                child: TextField(
                  controller: _urlController,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Pega el enlace de TikTok aquí...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF9E9E9E),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  enabled: !provider.isLoading,
                ),
              ),
              
              // Separador visual
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFE0E0E0),
              ),
              
              // Botón de Descarga
              GestureDetector(
                onTap: provider.isLoading
                    ? null
                    : () {
                        final url = _urlController.text.trim();
                        provider.startDownloadProcess(url, context);
                      },
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: provider.isLoading
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1A1A1A),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.download_rounded,
                          color: Color(0xFF1A1A1A),
                          size: 24,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la lista de historial
  Widget _buildHistoryList() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        if (provider.downloadHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Recientes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: provider.downloadHistory.length,
                itemBuilder: (context, index) {
                  final item = provider.downloadHistory[index];
                  return _buildHistoryCard(item, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye una tarjeta de historial
  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
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
          // Thumbnail placeholder
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
            child: const Icon(
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
                    item['data']?['title'] ?? 'Video de TikTok',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['data']?['size'] ?? 'Tamaño desconocido',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botón de acción
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF9E9E9E),
            ),
            onPressed: () {
              // TODO: Mostrar opciones (eliminar, compartir, etc.)
            },
          ),
        ],
      ),
    );
  }

  /// Construye el Drawer personalizado minimalista
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header del Drawer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Text(
                    'Menú',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Opciones del menú
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1A1A1A)),
              title: Text(
                'Perfil',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF1A1A1A)),
              title: Text(
                'Configuración',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navegar a pantalla de configuración
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.star, color: Color(0xFF1A1A1A)),
              title: Text(
                'Premium',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navegar a pantalla Premium
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF1A1A1A)),
              title: Text(
                'Acerca de',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Mostrar información de la app
              },
            ),
            
            const Spacer(),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'AhaTok v1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

