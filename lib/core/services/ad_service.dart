import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Servicio para gestionar los anuncios de Google Mobile Ads
class AdService {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;
  static Completer<void>? _adDismissedCompleter;

  /// Inicializa Google Mobile Ads
  /// Debe llamarse al inicio de la aplicación
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Carga un anuncio intersticial
  static Future<void> loadInterstitial() async {
    // TODO: Reemplazar con tu Ad Unit ID real
    const adUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test Ad Unit ID

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setFullScreenContentCallback(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          print('Error al cargar el anuncio: ${error.message}');
        },
      ),
    );
  }

  /// Configura los callbacks del anuncio
  static void _setFullScreenContentCallback(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        
        // Completar el completer si existe
        if (_adDismissedCompleter != null && !_adDismissedCompleter!.isCompleted) {
          _adDismissedCompleter!.complete();
          _adDismissedCompleter = null;
        }
        
        // Recargar un nuevo anuncio para la próxima vez
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        print('Error al mostrar el anuncio: ${error.message}');
        
        // Completar el completer incluso si falla
        if (_adDismissedCompleter != null && !_adDismissedCompleter!.isCompleted) {
          _adDismissedCompleter!.complete();
          _adDismissedCompleter = null;
        }
      },
    );
  }

  /// Muestra el anuncio intersticial
  /// Retorna un Future que se completa cuando el usuario cierra el anuncio
  static Future<void> showInterstitial({
    VoidCallback? onAdDismissed,
  }) async {
    if (_interstitialAd != null && _isAdLoaded) {
      // Crear un completer para esperar a que el usuario cierre el anuncio
      _adDismissedCompleter = Completer<void>();
      
      // Mostrar el anuncio
      await _interstitialAd!.show();
      
      // Esperar a que el usuario cierre el anuncio
      await _adDismissedCompleter!.future;
      
      // Ejecutar el callback si se proporcionó
      if (onAdDismissed != null) {
        onAdDismissed();
      }
    } else {
      // Si no hay anuncio cargado, intentamos cargarlo primero
      await loadInterstitial();
      
      // Esperar un momento para que el anuncio se cargue
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Si ahora hay anuncio, mostrarlo
      if (_interstitialAd != null && _isAdLoaded) {
        _adDismissedCompleter = Completer<void>();
        await _interstitialAd!.show();
        await _adDismissedCompleter!.future;
      }
      
      // Ejecutar el callback (incluso si no se mostró anuncio)
      if (onAdDismissed != null) {
        onAdDismissed();
      }
    }
  }

  /// Verifica si hay un anuncio listo para mostrar
  static bool isAdReady() {
    return _isAdLoaded && _interstitialAd != null;
  }

  /// Pre-carga un anuncio (útil para tenerlo listo antes de que el usuario lo necesite)
  static void preloadAd() {
    if (!_isAdLoaded) {
      loadInterstitial();
    }
  }
}

