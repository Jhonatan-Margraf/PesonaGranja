# Estrutura do Projeto Flutter - Suinocultura IA

## 📁 Estrutura de Diretórios

```
lib/
├── main.dart                          # Ponto de entrada do app
│
├── models/                            # Modelos de dados
│   ├── lote.dart                     # Modelo de Lote
│   ├── baia.dart                     # Modelo de Baia
│   └── medicao.dart                  # Modelo de Medição
│
├── providers/                         # Gerenciamento de estado (Provider)
│   ├── lote_provider.dart            # Provider de Lotes
│   └── baia_provider.dart            # Provider de Baias
│
├── services/                          # Serviços
│   ├── database_service.dart         # Serviço de armazenamento local
│   └── api_service.dart              # Serviço de comunicação com API
│
└── screens/                           # Telas do aplicativo
    ├── home_screen.dart              # Tela inicial
    │
    ├── lotes/                        # Telas relacionadas a Lotes
    │   ├── lotes_list_screen.dart   # Lista de lotes
    │   ├── lote_form_screen.dart    # Formulário de lote
    │   └── lote_detail_screen.dart  # Detalhes do lote
    │
    ├── baias/                        # Telas relacionadas a Baias
    │   ├── baias_list_screen.dart   # Lista de baias
    │   ├── baia_form_screen.dart    # Formulário de baia
    │   └── baia_detail_screen.dart  # Detalhes da baia
    │
    └── camera/                       # Tela de câmera
        └── camera_screen.dart        # Captura e análise de imagem
```

## 📄 Descrição dos Arquivos

### Modelos (models/)

#### lote.dart
- Modelo de dados para Lote
- Campos: id, dataAlojamento, origem, quantidade, mortalidade, peso, GPD, etc.
- Métodos: cálculo de peso atual, conversão JSON

#### baia.dart
- Modelo de dados para Baia
- Campos: id, número, sexo, quantidade de suínos, mortos
- Métodos: adicionar/reverter morte, cálculo de peso médio

#### medicao.dart
- Modelo de dados para Medição de Peso
- Campos: id, data/hora, peso, caminho da imagem

### Providers (providers/)

#### lote_provider.dart
- Gerencia estado dos lotes
- Operações CRUD (criar, ler, atualizar, deletar)
- Atualização de mortalidade

#### baia_provider.dart
- Gerencia estado das baias
- Operações CRUD
- Gestão de medições e mortalidade

### Serviços (services/)

#### database_service.dart
- Persistência local usando SharedPreferences
- Salva/carrega lotes e baias em JSON
- Operações de busca e filtragem

#### api_service.dart
- Comunicação com API de IA
- Envio de imagens para análise
- Modo simulado para desenvolvimento

### Telas (screens/)

#### home_screen.dart
- Tela inicial do app
- Menu principal com navegação

#### Lotes
- **lotes_list_screen.dart**: Lista todos os lotes cadastrados
- **lote_form_screen.dart**: Formulário para criar/editar lotes
- **lote_detail_screen.dart**: Detalhes e estatísticas do lote

#### Baias
- **baias_list_screen.dart**: Grid de baias do lote
- **baia_form_screen.dart**: Formulário para criar/editar baias
- **baia_detail_screen.dart**: Detalhes, peso e histórico da baia

#### Câmera
- **camera_screen.dart**: Captura foto, análise de IA, salvamento

## 🔄 Fluxo de Dados

```
Interface (Screens)
    ↕️
Providers (State Management)
    ↕️
Services (Database/API)
    ↕️
Models (Data Structures)
```

## 🎯 Funcionalidades por Arquivo

### database_service.dart
- ✅ Salvar/carregar lotes
- ✅ Salvar/carregar baias
- ✅ Calcular mortalidade total
- ✅ Buscar por ID

### api_service.dart
- ✅ Enviar imagem para análise
- ✅ Receber peso da IA
- ✅ Modo simulado
- ⏳ Tratamento de erros

### camera_screen.dart
- ✅ Acesso à câmera
- ✅ Guias de enquadramento
- ✅ Captura de foto
- ✅ Análise de peso
- ✅ Salvamento de medição

## 📦 Dependências Principais

```yaml
provider: ^6.1.1          # State management
shared_preferences: ^2.2.2 # Armazenamento local
camera: ^0.10.5+5         # Acesso à câmera
http: ^1.1.0              # Requisições HTTP
uuid: ^4.2.1              # Geração de IDs únicos
intl: ^0.18.1             # Formatação de datas
```

## 🚀 Como Executar

1. Copie todos os arquivos para a pasta `lib/` do seu projeto Flutter
2. Copie o `pubspec.yaml` para a raiz do projeto
3. Execute: `flutter pub get`
4. Configure permissões (veja CONFIGURACAO_ANDROID.md e CONFIGURACAO_IOS.md)
5. Execute: `flutter run`

## 🔧 Configurações Necessárias

1. **Android**: Adicionar permissões no AndroidManifest.xml
2. **iOS**: Adicionar descrições no Info.plist
3. **API**: Configurar URL da API em api_service.dart

## 💡 Dicas de Desenvolvimento

- Use o modo simulado inicialmente (não precisa da API)
- Teste em dispositivo real (câmera não funciona em emuladores antigos)
- Os dados são salvos localmente e persistem entre execuções
- Para limpar dados: desinstale e reinstale o app

## 🎨 Personalização

- Cores: `lib/main.dart` (theme)
- GPD padrão: `lib/models/lote.dart`
- Textos: Procure por strings nas telas
- Ícones: Use ícones do Material Icons

## 📝 Próximos Passos

1. Testar em dispositivo real
2. Integrar API de IA real
3. Adicionar exportação de relatórios
4. Implementar gráficos de evolução
5. Adicionar backup em nuvem
