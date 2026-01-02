# 🔥 Guía de Configuración de Firebase para AhaTok

Esta guía te ayudará a configurar Firebase Authentication (Google Sign-In) y Cloud Firestore en tu proyecto Flutter.

## 📋 Requisitos Previos

1. Cuenta de Google (para acceder a Firebase Console)
2. Proyecto Flutter configurado
3. Android Studio o VS Code con extensiones de Flutter

## 🚀 Paso 1: Crear Proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en **"Agregar proyecto"** o **"Add project"**
3. Ingresa el nombre del proyecto: `AhaTok` (o el que prefieras)
4. Sigue los pasos del asistente:
   - Desactiva Google Analytics (opcional, puedes activarlo después)
   - Haz clic en **"Crear proyecto"**

## 📱 Paso 2: Agregar App Android

1. En la página principal del proyecto Firebase, haz clic en el ícono de **Android**
2. Completa el formulario:
   - **Nombre del paquete Android**: Debe coincidir con el `applicationId` en `android/app/build.gradle`
     - **📍 Ubicación exacta**: Abre `android/app/build.gradle` y busca la línea 47:
       ```gradle
       applicationId "com.example.ahatok"
       ```
       Esta línea está dentro del bloque `android { defaultConfig { ... } }`
     - Por defecto en Flutter: `com.example.ahatok` (cámbialo si es necesario)
     - **💡 Tip**: El valor entre comillas es tu Application ID. Cópialo exactamente tal como aparece
   - **Apodo de la app**: `AhaTok` (opcional)
   - **Certificado de firma SHA-1**: **IMPORTANTE** - Ver sección siguiente
3. Haz clic en **"Registrar app"**
4. Descarga el archivo `google-services.json`
5. Coloca el archivo en: `android/app/google-services.json`

**✅ IMPORTANTE**: Los archivos `build.gradle` ya están configurados con el plugin de Google Services. Solo necesitas colocar el archivo `google-services.json` en la ubicación correcta.

## 🔐 Paso 3: Obtener SHA-1 (CRÍTICO para Google Sign-In)

El SHA-1 es necesario para que Google Sign-In funcione correctamente. Sin esto, el login fallará.

### Opción A: Usando Gradle (Recomendado)

```bash
cd android
./gradlew signingReport
```

En Windows PowerShell:
```powershell
cd android
.\gradlew signingReport
```

Busca en la salida la línea que dice:
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

Copia el valor de **SHA1**.

### Opción B: Usando keytool (Manual)

```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Busca la línea **SHA1** y copia el valor.

### Agregar SHA-1 a Firebase

1. Ve a Firebase Console → Tu Proyecto → Configuración del proyecto (⚙️)
2. Desplázate hasta **"Tus aplicaciones"**
3. Haz clic en tu app Android
4. En la sección **"Huellas digitales del certificado SHA"**, haz clic en **"Agregar huella digital"**
5. Pega el SHA-1 que copiaste
6. Haz clic en **"Guardar"**

## 🔧 Paso 4: Configurar Firebase en Flutter

### 4.1. Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 4.2. Configurar Firebase en el proyecto

```bash
flutterfire configure
```

Este comando:
- Te pedirá seleccionar tu proyecto Firebase
- Generará automáticamente los archivos de configuración
- Configurará `firebase_options.dart`

**Alternativa Manual:**

Si no puedes usar FlutterFire CLI, crea manualmente:

1. **android/app/build.gradle** - Agrega al final:
```gradle
apply plugin: 'com.google.gms.google-services'
```

2. **android/build.gradle** - En `dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

3. Crea `lib/firebase_options.dart` manualmente (ver ejemplo abajo)

## 🔑 Paso 5: Habilitar Google Sign-In en Firebase

1. Ve a Firebase Console → **Authentication**
2. Haz clic en **"Comenzar"** o **"Get started"**
3. En la pestaña **"Sign-in method"** (Métodos de inicio de sesión)
4. Haz clic en **"Google"**
5. Activa el **interruptor** para habilitar Google Sign-In
6. Selecciona un **correo de soporte del proyecto** (puede ser el tuyo)
7. Haz clic en **"Guardar"**

## 💾 Paso 6: Configurar Cloud Firestore

1. Ve a Firebase Console → **Firestore Database**
2. Haz clic en **"Crear base de datos"**
3. Selecciona **"Comenzar en modo de prueba"** (para desarrollo)
4. Elige una **ubicación** para tu base de datos (elige la más cercana)
5. Haz clic en **"Habilitar"**

### Reglas de Seguridad (Desarrollo)

Para desarrollo, puedes usar estas reglas temporales:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura/escritura solo a usuarios autenticados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /history/{historyId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**⚠️ IMPORTANTE:** Estas reglas son para desarrollo. En producción, refina las reglas según tus necesidades.

## 📄 Paso 7: Archivo firebase_options.dart

Si no usaste FlutterFire CLI, crea `lib/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
    iosBundleId: 'com.example.ahatok',
  );
}
```

Reemplaza los valores con los de tu proyecto Firebase (los encuentras en `google-services.json`).

## ✅ Paso 8: Verificar Instalación

1. Ejecuta `flutter pub get`
2. Verifica que no haya errores de compilación
3. Ejecuta la app: `flutter run`

## 🐛 Solución de Problemas Comunes

### Error: "SHA-1 not found"
- Asegúrate de haber agregado el SHA-1 en Firebase Console
- Verifica que el package name coincida exactamente

### Error: "Google Sign-In failed"
- Verifica que Google Sign-In esté habilitado en Firebase Console
- Revisa que el SHA-1 esté correctamente configurado
- Asegúrate de que `google-services.json` esté en `android/app/`

### Error: "Firebase not initialized"
- Verifica que `Firebase.initializeApp()` esté en `main.dart`
- Asegúrate de que `firebase_options.dart` existe y está configurado

### Error: "Permission denied" en Firestore
- Revisa las reglas de seguridad de Firestore
- Asegúrate de que el usuario esté autenticado

## 📚 Estructura de Datos en Firestore

Después de la configuración, tu base de datos tendrá esta estructura:

```
users/
  {uid}/
    - uid: string
    - email: string
    - displayName: string
    - photoUrl: string
    - isPremium: boolean
    - createdAt: timestamp
    - lastLogin: timestamp
    history/
      {historyId}/
        - videoUrl: string
        - coverUrl: string
        - description: string
        - originalUrl: string
        - author: string
        - duration: number
        - downloadedAt: timestamp
```

## 🎉 ¡Listo!

Una vez completados estos pasos, tu app debería poder:
- ✅ Iniciar sesión con Google
- ✅ Guardar usuarios en Firestore
- ✅ Guardar historial de descargas en la nube
- ✅ Sincronizar estado Premium

## 📝 Notas Adicionales

- **Modo de prueba de Firestore**: Tiene límites (50,000 lecturas/día). Para producción, configura reglas de seguridad apropiadas.
- **SHA-1 de producción**: Cuando generes un APK/AAB de producción, necesitarás agregar el SHA-1 de tu keystore de producción también.
- **iOS**: Si planeas publicar en iOS, necesitarás configurar también la app iOS en Firebase.

