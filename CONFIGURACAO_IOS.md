# Configuração iOS

## Info.plist

Adicione as seguintes chaves em `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Chaves existentes... -->
    
    <!-- Permissões de Câmera -->
    <key>NSCameraUsageDescription</key>
    <string>Precisamos acessar a câmera para medir o peso dos suínos através de análise de imagem</string>
    
    <!-- Permissões de Galeria/Fotos -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Precisamos acessar a galeria para salvar as fotos das medições</string>
    
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Precisamos salvar as fotos das medições na galeria</string>
    
    <!-- Outras configurações existentes... -->
</dict>
</plist>
```

## Podfile

Certifique-se de que `ios/Podfile` tem a plataforma mínima correta:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'
```

## Comandos de Instalação

Após configurar, execute:

```bash
cd ios
pod install
cd ..
```

## Permissões em Tempo de Execução

O iOS solicitará permissão automaticamente quando o app tentar acessar a câmera pela primeira vez.
As descrições que você colocou em Info.plist serão mostradas ao usuário.
