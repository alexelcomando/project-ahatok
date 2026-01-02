import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/ad_service.dart';
import 'features/download/providers/download_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/download/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase con las opciones de la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar Google Mobile Ads
  await AdService.initialize();
  
  // Pre-cargar un anuncio para tenerlo listo
  AdService.preloadAd();
  
  runApp(const AhaTokApp());
}

class AhaTokApp extends StatelessWidget {
  const AhaTokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: MaterialApp(
        title: 'AhaTok',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

