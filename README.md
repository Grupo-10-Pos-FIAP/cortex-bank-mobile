# Cortex Bank Mobile

Desenvolver uma aplicação de gerenciamento financeiro, utilizando Flutter Mobile, com funcionalidades avançadas que foram ensinadas nas disciplinas. A aplicação deve ser capaz de gerenciar transações financeiras, integrando recursos de navegação, segurança, autenticação e armazenamento em cloud.

## Instruções para rodar localmente (resumo)

Este README reúne o necessário para executar o app na sua máquina:

| Tema | Seção |
| ---- | ----- |
| Ferramentas e SDKs instalados no sistema | **Dependências necessárias** |
| Projeto Firebase, `.env`, arquivos nativos e regras | **Configuração do Firebase** |
| `flutter pub get`, dispositivo/emulador e `flutter run` | **Executar o projeto** |

## Dependências necessárias

| Item | Detalhe |
| ---- | ------- |
| **Flutter** | Canal **stable**, com Dart compatível com o `pubspec.yaml` (atualmente `sdk: ^3.10.7`). Confira com `flutter --version`. |
| **Android** | Android Studio, SDK Android e **JDK 17** (o `android/app/build.gradle.kts` do projeto usa Java 17). |
| **iOS (somente macOS)** | Xcode atualizado (abra uma vez após instalar para concluir componentes). CocoaPods para dependências nativas. |
| **Conta** | Projeto no [Firebase Console](https://console.firebase.google.com/) com apps **Android** e **iOS** registrados (ou use o fluxo da FlutterFire CLI abaixo). |

**IDs usados neste repositório** (devem bater com os apps cadastrados no Firebase):

- **Android** — `applicationId`: `com.example.cortex_bank_mobile`
- **iOS** — Bundle ID: `com.example.cortexBankMobile`

**Pacotes Dart / Flutter:** as bibliotecas do app estão declaradas em `pubspec.yaml` (Firebase, Provider, etc.). Após clonar o projeto, instale-as com:

```bash
flutter pub get
```

## Configuração do Firebase

### Projeto novo no Firebase Console (checklist)

Em um projeto **novo** no [Firebase Console](https://console.firebase.google.com/), configure pelo menos:

1. **Apps**: registrar **Android** com o pacote `com.example.cortex_bank_mobile` e **iOS** com o bundle `com.example.cortexBankMobile` (valores usados neste repositório).
2. **Authentication** → habilitar **E-mail/senha** (o app usa login e cadastro com e-mail e senha).
3. **Firestore Database** → criar o banco (modo de sua escolha).
4. **Storage** → ativar o armazenamento (o app usa anexos/recibos).
5. **Regras de segurança**: publicar regras alinhadas aos arquivos **`firestore.rules`** e **`storage.rules`** na raiz do repositório (cole o conteúdo em Firestore → Regras e Storage → Regras no Console, ou use a [Firebase CLI](https://firebase.google.com/docs/cli) com deploy, se utilizar).

Sem esses serviços e regras compatíveis, o app pode até iniciar, mas falhará em autenticação, leitura/escrita ou upload.

### Integração no aplicativo (arquivos e validação)

#### Como o Firebase é usado no código

1. **`.env`** — Na inicialização, o app verifica se as variáveis obrigatórias para a plataforma atual estão preenchidas (`lib/core/utils/env_validator.dart`). Se faltar alguma, é exibida a tela **“Configuração incompleta”** e o Firebase não sobe.
2. **`lib/firebase_options.dart`** — O `Firebase.initializeApp` usa `DefaultFirebaseOptions.currentPlatform` (configuração gerada pela [FlutterFire](https://firebase.flutter.dev/)). Esse arquivo precisa corresponder ao **mesmo** projeto Firebase que os arquivos nativos abaixo.
3. **Arquivos nativos** — O Android aplica o plugin `com.google.gms.google-services` e espera `android/app/google-services.json` (arquivo **não** versionado; está no `.gitignore`). O iOS usa `ios/Runner/GoogleService-Info.plist` (obtenha do Firebase ou gere com a CLI).

Ou seja: **`.env` + `firebase_options.dart` + arquivos nativos** devem estar alinhados com **um** projeto Firebase. A forma mais simples de gerar tudo junto é a **FlutterFire CLI** (subseção abaixo).

#### FlutterFire CLI (recomendado)

No diretório do projeto:

1. Instale a CLI (uma vez na máquina):

   ```bash
   dart pub global activate flutterfire_cli
   ```

   Garanta que o diretório de pacotes globais do Pub está no `PATH` (a CLI costuma avisar o caminho ao final da instalação).

2. Faça login no Firebase e gere os arquivos para as plataformas desejadas:

   ```bash
   flutterfire configure
   ```

   Isso atualiza `lib/firebase_options.dart` e gera/atualiza `android/app/google-services.json` e `ios/Runner/GoogleService-Info.plist` conforme os apps que você selecionar.

3. Copie `.env.example` para `.env` e preencha com os mesmos valores do seu projeto (veja a tabela em **Variáveis de ambiente (`.env`)**). Os IDs e chaves devem ser os do **mesmo** projeto/apps usados no passo anterior.

Documentação da CLI: [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

#### Configuração manual (sem CLI)

- **Android**: Firebase Console → Configurações do projeto → app Android → baixe `google-services.json` → coloque em `android/app/google-services.json`.
- **iOS**: mesmo fluxo para o app iOS → baixe `GoogleService-Info.plist` → coloque em `ios/Runner/GoogleService-Info.plist`.
- Ajuste `lib/firebase_options.dart` para esse projeto (por exemplo rodando `flutterfire configure` depois, ou mantendo o arquivo gerado por quem configurou o repositório, se for o mesmo projeto).

#### Variáveis de ambiente (`.env`)

Copie `.env.example` para `.env` e preencha com os valores do seu projeto no [Firebase Console](https://console.firebase.google.com/). As variáveis necessárias dependem da plataforma em que você roda o app:

| Plataforma | Variáveis obrigatórias |
| ---------- | ---------------------- |
| **Web** | `FIREBASE_API_KEY_WEB`, `FIREBASE_APP_ID_WEB`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MEASUREMENT_ID` |
| **Android** | `FIREBASE_API_KEY_ANDROID`, `FIREBASE_APP_ID_ANDROID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET` |
| **iOS** | `FIREBASE_API_KEY_IOS`, `FIREBASE_APP_ID_IOS`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_IOS_BUNDLE_ID` |

`FIREBASE_IOS_BUNDLE_ID` deve ser o mesmo do app iOS no Firebase; neste projeto o bundle ID é `com.example.cortexBankMobile`.

Se alguma variável obrigatória para a plataforma atual estiver ausente, o app exibirá uma tela de **"Configuração incompleta"** em vez de inicializar o Firebase.

## Executar o projeto

Passos mínimos após ter as **dependências** e a **configuração do Firebase** prontas:

1. Entrar na pasta raiz do projeto (clone Git).
2. `flutter pub get`
3. Garantir `.env`, `lib/firebase_options.dart`, `android/app/google-services.json` (Android) e `ios/Runner/GoogleService-Info.plist` (iOS) coerentes com o **mesmo** projeto Firebase.
4. `flutter doctor` — corrigir o que estiver pendente (SDK Android, Xcode no Mac, licenças).
5. Ligar emulador ou conectar aparelho; opcionalmente `flutter devices`.
6. `flutter run` ou `flutter run -d <id_do_dispositivo>`.

A seguir: detalhes por sistema operacional se você ainda estiver **instalando o ambiente do zero**.

Se você ainda não tem Flutter nem Android configurados, siga os passos abaixo. Os comandos do projeto (`flutter pub get`, `flutter doctor`, `flutter run`) são os mesmos em qualquer sistema.

Além do Flutter, é preciso concluir a **Configuração do Firebase** (integração no app, FlutterFire CLI ou manual, e tabela de variáveis **`.env`**): `.env`, `firebase_options.dart` e arquivos nativos (`google-services.json` / `GoogleService-Info.plist`) alinhados ao mesmo projeto.

### Windows

1. Instale o Flutter SDK seguindo o guia oficial: [Instalação no Windows](https://docs.flutter.dev/get-started/install/windows) (inclui Git for Windows e verificação com `flutter doctor`).
2. Para desenvolvimento Android no Windows, use o **Android Studio** e o SDK Android como descrito na mesma documentação; aceite as licenças com `flutter doctor --android-licenses`.
3. Se o Gradle reclamar de versão do Java, configure **JDK 17** no Android Studio (**Settings → Build, Execution, Deployment → Build Tools → Gradle**).
4. Na pasta do projeto: `flutter pub get`, configure o Firebase (`.env` + arquivos nativos + `firebase_options.dart`, conforme as seções acima) e rode `flutter run` (ou escolha o dispositivo com `flutter devices`).

*Nota: desenvolvimento iOS nativo não roda no Windows; use macOS (ou CI) para build/execução em iPhone/Simulator.*

### Linux

1. Siga [Instalação no Linux](https://docs.flutter.dev/get-started/install/linux) (dependências do sistema, Flutter SDK, `flutter doctor`).
2. Para Android, use **Android Studio** (ou SDK + ferramentas), aceite licenças com `flutter doctor --android-licenses` e, se quiser emulador, crie um aparelho virtual como no passo a passo macOS abaixo.
3. No projeto: `flutter pub get`, configure Firebase como nas seções acima, depois `flutter run`.

### macOS (passo a passo detalhado)

Se você ainda não tem Flutter nem Android configurados, siga estes passos no **macOS**.

#### 1. Instalar o Flutter

1. Baixe o Flutter SDK: [https://docs.flutter.dev/get-started/install/macos](https://docs.flutter.dev/get-started/install/macos)  
   Ou via terminal (usando Git):

   ```bash
   cd ~
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. Adicione o Flutter ao seu `PATH`. No `~/.zshrc` adicione:

   ```bash
   export PATH="$HOME/flutter/bin:$PATH"
   ```

3. Feche e abra o terminal de novo e rode:

   ```bash
   flutter doctor
   ```

   Esse comando mostra o que ainda falta instalar.

#### 2. Instalar o ambiente Android

1. Instale o **Android Studio**: [https://developer.android.com/studio](https://developer.android.com/studio)

2. Abra o Android Studio e vá em **More Actions** → **SDK Manager** (ou **Settings** → **Languages & Frameworks** → **Android SDK**). Instale:

   - **Android SDK Platform** (ex.: API 34)
   - **Android SDK Command-line Tools**
   - **Android SDK Build-Tools**
   - **Android Emulator**
   - **Android SDK Platform-Tools**

3. Aceite as licenças do Android:

   ```bash
   flutter doctor --android-licenses
   ```

4. (Opcional) Crie um **emulador**: no Android Studio, **Device Manager** → **Create Device** → escolha um modelo (ex. Pixel) e uma imagem do sistema (ex. API 34) → **Finish**.

5. Rode de novo:

   ```bash
   flutter doctor
   ```

   Para Android, o ideal é aparecer algo como “Android toolchain - develop for Android devices” em verde.

#### 3. Configurar o projeto

1. Na pasta do projeto, instale as dependências:

   ```bash
   cd /caminho/para/cortex-bank-mobile
   flutter pub get
   ```

2. Configure o Firebase: copie `.env.example` para `.env`, preencha as variáveis para Android e/ou iOS (tabela em **Variáveis de ambiente (`.env`)**), e garanta `google-services.json`, `GoogleService-Info.plist` e `lib/firebase_options.dart` coerentes com o mesmo projeto (recomendado: **FlutterFire CLI** na seção **Configuração do Firebase**).

#### 4. Rodar no Android

- **Emulador**: inicie o emulador pelo Android Studio (Device Manager → Play no dispositivo). Depois:

  ```bash
  flutter run
  ```

  Se tiver mais de um dispositivo, escolha o Android:

  ```bash
  flutter devices
  flutter run -d <id_do_dispositivo_android>
  ```

- **Celular físico**: ative **Opções do desenvolvedor** e **Depuração USB**, conecte o cabo, autorize o computador no celular e rode:

  ```bash
  flutter run
  ```

#### 5. Rodar no iOS (simulador)

Para rodar no **simulador do iPhone** não é necessária conta paga da Apple; basta ter **Xcode** instalado no Mac.

1. **Instale o Xcode** (Mac App Store) e abra-o uma vez para instalar componentes e aceitar a licença (se precisar: `sudo xcodebuild -license`).

2. **Instale o CocoaPods** (gerenciador de dependências iOS):

   ```bash
   sudo gem install cocoapods
   ```

3. **Variáveis de ambiente**: no `.env`, preencha as variáveis obrigatórias para iOS (veja a tabela em **Variáveis de ambiente (`.env`)**). O `FIREBASE_IOS_BUNDLE_ID` deve ser o mesmo do app iOS no Firebase; neste projeto o bundle ID é `com.example.cortexBankMobile`.

4. **GoogleService-Info.plist**: o app iOS precisa do arquivo de configuração do Firebase.

   - No [Firebase Console](https://console.firebase.google.com/) → seu projeto → **Configurações do projeto** → **Seus apps** → app **iOS** → baixe o `GoogleService-Info.plist`.
   - Coloque o arquivo em: `ios/Runner/GoogleService-Info.plist`.
   - Com a [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/), após `dart pub global activate flutterfire_cli`, use `flutterfire configure` e selecione iOS para gerar/atualizar esse arquivo e o `firebase_options.dart`.

5. **Rode no simulador**: o Flutter instala os pods automaticamente. Se for a primeira vez, pode ser útil rodar antes:

   ```bash
   flutter precache --ios
   ```

   Depois:

   ```bash
   flutter run
   ```

   Para listar dispositivos e escolher um simulador iOS:

   ```bash
   flutter devices
   flutter run -d <id_do_simulador_ios>
   ```

   Para abrir o simulador antes: `open -a Simulator` e depois `flutter run`.

#### 6. Rodar no iPhone físico (opcional)

1. Conecte o aparelho. Abra `ios/Runner.xcworkspace` no Xcode (ou deixe o Flutter orientar na primeira execução).
2. Em **Signing & Capabilities**, escolha seu **Team** (Apple ID gratuito ou conta de desenvolvedor).
3. No iPhone, em **Ajustes → Geral → VPN e Gerenciamento de Dispositivo**, confie no certificado de desenvolvedor, se aparecer o aviso.
4. Rode:

   ```bash
   flutter devices
   flutter run -d <nome_do_iphone>
   ```

## Licença

Este projeto foi desenvolvido como parte do trabalho de pós-graduação em Engenharia de Front End.

## Autores

- [Gabrielle Martins](https://github.com/Gabrielle-96)
- [Helen Cris](https://github.com/HelenCrisM)

**Desenvolvido para fins acadêmicos.**
