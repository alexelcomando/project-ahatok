# AhaTok - TikTok Video Downloader

Aplicación Flutter para descargar videos de TikTok con una interfaz minimalista "Clean White" y arquitectura escalable.

## 🏗️ Arquitectura

El proyecto utiliza el patrón **Feature-First** con las siguientes características:

- **Core Services**: Servicios compartidos (API, Ads)
- **Features**: Módulos independientes por funcionalidad
- **Providers**: Gestión de estado con Provider pattern

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   └── services/
│       ├── api_service.dart      # Servicio de comunicación con backend
│       └── ad_service.dart        # Gestión de anuncios Google Mobile Ads
├── features/
│   └── download/
│       ├── providers/
│       │   └── download_provider.dart  # Lógica de negocio y estado
│       └── screens/
│           └── home_screen.dart         # UI principal Clean White
└── main.dart                      # Punto de entrada de la app
```

## 🚀 Características

- ✅ Arquitectura Feature-First escalable
- ✅ Gestión de estado con Provider
- ✅ Integración con Google Mobile Ads
- ✅ UI minimalista "Clean White" inspirada en diseño premium
- ✅ Flujo Premium/Free con anuncios intersticiales
- ✅ Validación de URLs
- ✅ Historial de descargas

## 📦 Dependencias Principales

- `provider`: Gestión de estado
- `dio`: Cliente HTTP
- `google_mobile_ads`: Monetización con anuncios
- `flutter_overlay_window`: Ventana flotante
- `shared_preferences`: Almacenamiento local
- `permission_handler`: Gestión de permisos
- `google_fonts`: Tipografía personalizada

## 🔧 Configuración

1. Instala las dependencias:
```bash
flutter pub get
```

2. Configura los Ad Unit IDs en `lib/core/services/ad_service.dart`:
   - Reemplaza el Ad Unit ID de prueba con tu ID real de Google AdMob

3. Configura la URL del backend en `lib/core/services/api_service.dart`:
   - Actualiza `BASE_URL` con la URL real de tu API

## 🎨 Diseño

El diseño sigue un estilo "Clean White" minimalista con:
- Fondo blanco puro (#FFFFFF)
- Sombras suaves para profundidad
- Tipografía Poppins/Inter
- Espaciado generoso
- Elementos flotantes con BoxShadow personalizado

## 📱 Flujo de Descarga

1. Usuario ingresa URL de TikTok
2. Validación de URL
3. **Si es Premium**: Procesa directamente
4. **Si es Free**: Muestra anuncio intersticial → Luego procesa
5. Muestra resultado y agrega al historial

## 🔐 Estado Premium

Actualmente simulado en `false` en `DownloadProvider`. Para cambiar:
```dart
provider.setPremium(true);
```

## 📝 Notas

- Los anuncios usan Ad Unit IDs de prueba por defecto
- El servicio API está mockeado con un delay de 2 segundos
- El historial se mantiene en memoria (no persistente aún)

## 🚧 Próximos Pasos

- [ ] Persistencia del historial con SharedPreferences
- [ ] Implementación real del backend
- [ ] Descarga real de videos
- [ ] Ventana flotante con flutter_overlay_window
- [ ] Gestión de permisos de Android
- [ ] Pantalla de configuración Premium

