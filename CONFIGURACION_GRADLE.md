# ⚙️ Configuración de Google Services en Gradle

## ✅ Cambios Realizados

### 1. Archivo de Nivel de Proyecto: `android/build.gradle`

Se creó/actualizó el archivo con el plugin de Google Services:

```gradle
buildscript {
    dependencies {
        // ...
        // Add the dependency for the Google services Gradle plugin
        classpath 'com.google.gms:google-services:4.4.4'
    }
}
```

### 2. Archivo de Nivel de App: `android/app/build.gradle`

#### Plugin agregado:
```gradle
plugins {
    // ...
    // Add the Google services Gradle plugin
    id "com.google.gms.google-services"
}
```

#### Dependencias de Firebase agregadas:
```gradle
dependencies {
    // Import the Firebase BoM
    implementation platform('com.google.firebase:firebase-bom:34.7.0')
    
    // Firebase Authentication
    implementation 'com.google.firebase:firebase-auth'
    
    // Cloud Firestore
    implementation 'com.google.firebase:firebase-firestore'
    
    // Firebase Core
    implementation 'com.google.firebase:firebase-core'
}
```

### 3. Archivo `google-services.json`

✅ Movido a la ubicación correcta: `android/app/google-services.json`

## 📋 Estructura Final

```
android/
├── build.gradle                    ← Nivel de proyecto (con classpath)
├── google-services.json            ← (debe estar aquí temporalmente)
└── app/
    ├── build.gradle                ← Nivel de app (con plugin y dependencias)
    └── google-services.json        ← ✅ Ubicación correcta
```

## 🔍 Verificación

Para verificar que todo está correcto:

1. **Verifica el plugin en build.gradle de proyecto:**
   - Abre `android/build.gradle`
   - Busca: `classpath 'com.google.gms:google-services:4.4.4'`

2. **Verifica el plugin en build.gradle de app:**
   - Abre `android/app/build.gradle`
   - Busca: `id "com.google.gms.google-services"`

3. **Verifica las dependencias:**
   - En `android/app/build.gradle`
   - Debe tener `firebase-bom` y los SDKs de Firebase

4. **Verifica google-services.json:**
   - Debe estar en: `android/app/google-services.json`

## 🚀 Siguiente Paso

Después de esta configuración, sincroniza el proyecto:

```bash
# En Android Studio: File → Sync Project with Gradle Files
# O desde terminal:
cd android
./gradlew build
```

## ⚠️ Notas Importantes

- El plugin `com.google.gms.google-services` debe aplicarse **después** de los plugins de Android
- El archivo `google-services.json` debe estar en `android/app/` (no en `android/`)
- La versión del BoM (34.7.0) asegura compatibilidad entre todos los SDKs de Firebase
- No especifiques versiones individuales cuando uses el BoM

## 🐛 Solución de Problemas

### Error: "Plugin with id 'com.google.gms.google-services' not found"
→ Verifica que el `classpath` esté en `android/build.gradle`

### Error: "File google-services.json is missing"
→ Asegúrate de que el archivo esté en `android/app/google-services.json`

### Error: "Failed to apply plugin"
→ Verifica que el plugin esté después de los plugins de Android en `android/app/build.gradle`

