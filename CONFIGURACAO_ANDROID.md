# Configuração Android

## AndroidManifest.xml

Adicione as seguintes permissões em `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissões necessárias -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" />
    
    <!-- Features de hardware -->
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
    
    <application
        android:label="Suinocultura IA"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## build.gradle

Em `android/app/build.gradle`, certifique-se de ter:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.exemplo.suinocultura_ia"
        minSdkVersion 21  // Mínimo para câmera
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

## Permissões em Tempo de Execução

O Flutter já lida com as permissões em tempo de execução através do plugin camera.
Quando o usuário acessar a câmera pela primeira vez, será solicitada a permissão automaticamente.
