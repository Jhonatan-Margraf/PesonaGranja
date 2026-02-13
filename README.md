# Sistema de Suinocultura com IA

Aplicativo Flutter para monitoramento de peso de suínos utilizando Inteligência Artificial.

## 📱 Funcionalidades

### ✅ Implementadas

- **Gestão de Lotes**
  - Cadastro de lotes com informações completas
  - Data de alojamento e origem
  - Controle de machos e fêmeas
  - Estimativa de GPD (Ganho de Peso Diário)
  - Cálculo automático de peso estimado
  - Visualização de estatísticas

- **Gestão de Baias**
  - Cadastro de baias por lote
  - Separação por sexo (macho/fêmea)
  - Controle de quantidade de animais
  - Registro de mortalidade com atualização automática
  - Botões +/- para adicionar/reverter mortes

- **Medição de Peso com IA**
  - Acesso à câmera do dispositivo
  - Guias visuais para enquadramento correto
  - Captura de foto do animal
  - Análise via API (preparado para integração)
  - Modo simulado para desenvolvimento
  - Histórico de medições por baia
  - Cálculo de peso médio automático

- **Armazenamento Local**
  - Dados persistidos usando SharedPreferences
  - Todas as informações mantidas entre sessões

## 🚀 Instalação

### Pré-requisitos

- Flutter SDK (3.0.0 ou superior)
- Dart SDK
- Android Studio ou VS Code
- Dispositivo Android/iOS ou Emulador

### Passos

1. **Clone ou copie os arquivos do projeto**

2. **Instale as dependências**

```bash
flutter pub get
```

3. **Configure as permissões**

#### Android (android/app/src/main/AndroidManifest.xml)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
</manifest>
```

#### iOS (ios/Runner/Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos acessar a câmera para medir o peso dos suínos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar a galeria para salvar fotos</string>
```

4. **Execute o aplicativo**

```bash
flutter run
```

## 🔌 Integração com API de IA

### Configuração

Edite o arquivo `lib/services/api_service.dart`:

```dart
class ApiService {
  // Substitua pela URL real da sua API
  static const String baseUrl = 'https://sua-api.com/api';
  
  Future<double?> analisarPesoSuino(File imagemFile) async {
    // ... implementação
  }
}
```

### Formato Esperado da API

**Endpoint:** `POST /analisar-peso`

**Request:**
- Content-Type: `multipart/form-data`
- Campo: `imagem` (arquivo de imagem)

**Response (sucesso):**
```json
{
  "peso": 85.5,
  "confianca": 0.95
}
```

### Modo Simulado

Por padrão, o app usa um modo simulado que gera pesos aleatórios entre 60-120kg.

Para ativar a API real, edite `lib/screens/camera/camera_screen.dart`:

```dart
// Comente esta linha:
// final peso = await _apiService.simularAnalise();

// Descomente esta linha:
final peso = await _apiService.analisarPesoSuino(imageFile);
```

## 📊 Estrutura de Dados

### Lote
- ID único
- Data de alojamento
- Origem dos leitões
- Quantidade alojada
- Mortalidade (calculada automaticamente)
- Peso médio inicial
- Estimativa de GPD (padrão: 0.995 kg/dia)
- Machos alojados
- Fêmeas alojadas
- Linha genética

### Baia
- ID único
- ID do lote
- Número da baia
- Sexo (macho/fêmea)
- Quantidade de suínos
- Leitões mortos
- Lista de medições

### Medição
- ID único
- ID da baia
- Data e hora
- Peso medido
- Caminho da imagem

## 🎨 Fluxo de Uso

1. **Criar Lote**
   - Tela inicial → Gerenciar Lotes → Botão +
   - Preencher informações do lote
   - Salvar

2. **Criar Baias**
   - Selecionar lote → Ver Baias → Botão +
   - Escolher sexo e quantidade
   - Salvar

3. **Registrar Mortalidade**
   - Na lista de baias, use os botões +/- no card
   - A mortalidade do lote é atualizada automaticamente

4. **Medir Peso**
   - Entrar na baia → Botão "Medir Peso"
   - Enquadrar o porco nas guias
   - Tirar foto
   - Aguardar análise
   - Confirmar e salvar

5. **Visualizar Histórico**
   - Dentro da baia, veja o histórico de medições
   - Peso médio é calculado automaticamente

## 🔧 Personalização

### Alterar o GPD Padrão

Em `lib/models/lote.dart`:

```dart
Lote({
  // ...
  this.estimativaGPD = 0.995, // Altere aqui
  // ...
});
```

### Cores do Tema

Em `lib/main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.green, // Altere a cor primária
  // ...
);
```

## 📝 Notas Importantes

1. **Armazenamento**: Os dados são salvos localmente. Não há sincronização em nuvem.

2. **Imagens**: As fotos das medições são salvas no dispositivo.

3. **Backup**: Recomenda-se fazer backup dos dados periodicamente.

4. **Performance**: Com muitas medições, considere implementar paginação.

## 🐛 Problemas Conhecidos

- Em alguns dispositivos Android antigos, a câmera pode demorar a inicializar
- O modo simulado gera pesos aleatórios (apenas para desenvolvimento)

## 📈 Próximas Melhorias

- [ ] Sincronização em nuvem
- [ ] Exportação de relatórios (PDF/Excel)
- [ ] Gráficos de evolução de peso
- [ ] Alertas de baixo desempenho
- [ ] Modo offline completo
- [ ] Backup automático

## 📄 Licença

Este projeto é proprietário e desenvolvido para uso específico em suinocultura.

## 👥 Suporte

Para dúvidas ou problemas, entre em contato com o desenvolvedor.

---

Desenvolvido com ❤️ usando Flutter
