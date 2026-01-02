# 🚀 Cómo Ejecutar la App Flutter AhaTok

## 📋 Requisitos Previos

1. **Instalar Flutter SDK**
   - Descarga desde: https://flutter.dev/docs/get-started/install/windows
   - Agrega Flutter al PATH de Windows
   - Verifica la instalación: `flutter doctor`

2. **Instalar Android Studio** (para Android)
   - O **Xcode** (para iOS en Mac)
   - O configurar para **Web**

## 🔧 Pasos para Ejecutar

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Verificar Dispositivos Disponibles

```bash
flutter devices
```

### 3. Ejecutar la Aplicación

**Para Android:**
```bash
flutter run
```

**Para Web:**
```bash
flutter run -d chrome
```

**Para iOS (solo Mac):**
```bash
flutter run -d ios
```

## ⚙️ Configuración Importante

### Conectar con el Backend Local

Si ejecutas en un **emulador Android**, actualiza la URL en `lib/core/services/api_service.dart`:

```dart
static const String BASE_URL = "http://10.0.2.2:3000/api/v1";
```

Si ejecutas en un **dispositivo físico** o **web**, usa:

```dart
static const String BASE_URL = "http://TU_IP_LOCAL:3000/api/v1";
// Ejemplo: "http://192.168.1.100:3000/api/v1"
```

Para encontrar tu IP local en Windows:
```powershell
ipconfig
# Busca "IPv4 Address" en tu adaptador de red
```

## 🎨 Vista Previa HTML

He creado un archivo `preview.html` que muestra cómo se ve la UI. Puedes abrirlo directamente en tu navegador para ver el diseño.

## 📱 Características de la App

- ✅ Diseño Clean White minimalista
- ✅ Input de descarga con botón integrado
- ✅ Historial de descargas
- ✅ Menú lateral (Drawer)
- ✅ Integración con anuncios (Google Mobile Ads)
- ✅ Flujo Premium/Free
- ✅ Conexión con backend API

## 🐛 Solución de Problemas

### Error: "Flutter no se reconoce"
- Agrega Flutter al PATH de Windows
- Reinicia la terminal/PowerShell

### Error de conexión con backend
- Verifica que el servidor backend esté corriendo
- Revisa la URL en `api_service.dart`
- Para emulador Android, usa `10.0.2.2` en lugar de `localhost`

### Error al instalar dependencias
```bash
flutter clean
flutter pub get
```

## 📝 Notas

- El proyecto usa **Provider** para gestión de estado
- Los anuncios usan IDs de prueba por defecto
- El estado Premium está simulado en `false` por ahora

