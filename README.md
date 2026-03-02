# Cortex Bank Mobile

Desenvolver uma aplicação de gerenciamento financeiro, utilizando Flutter Mobile, com funcionalidades avançadas que foram ensinadas nas disciplinas. A aplicação deve ser capaz de gerenciar transações financeiras,
integrando recursos de navegação, segurança, autenticação e armazenamento
em cloud.

## Como rodar o projeto (instalação do zero)

Se você ainda não tem Flutter nem Android configurados, siga estes passos no **macOS**.

### 1. Instalar o Flutter

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

### 2. Instalar o ambiente Android

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

### 3. Configurar o projeto

1. Na pasta do projeto, instale as dependências:

   ```bash
   cd /caminho/para/cortex-bank-mobile
   flutter pub get
   ```

2. Configure o Firebase conforme a seção **Configuração Firebase (.env)** abaixo (copie `.env.example` para `.env` e preencha as variáveis para Android). Sem o `.env` correto, o app pode abrir mas exibir “Configuração incompleta”.

### 4. Rodar no Android

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

### 5. Rodar no iOS (simulador)

Para rodar no **simulador do iPhone** não é necessária conta paga da Apple; basta ter **Xcode** instalado no Mac.

1. **Instale o Xcode** (Mac App Store) e abra-o uma vez para instalar componentes e aceitar a licença.

2. **Instale o CocoaPods** (gerenciador de dependências iOS):

   ```bash
   sudo gem install cocoapods
   ```

3. **Variáveis de ambiente**: no `.env`, preencha as variáveis obrigatórias para iOS (veja a tabela em **Configuração Firebase (.env)**). O `FIREBASE_IOS_BUNDLE_ID` deve ser o mesmo do app iOS no Firebase; neste projeto o bundle ID é `com.example.cortexBankMobile`.

4. **GoogleService-Info.plist**: o app iOS precisa do arquivo de configuração do Firebase.
   - No [Firebase Console](https://console.firebase.google.com/) → seu projeto → **Configurações do projeto** → **Seus apps** → app **iOS** → baixe o `GoogleService-Info.plist`.
   - Coloque o arquivo em: `ios/Runner/GoogleService-Info.plist`.
   - Se você usa [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/), pode rodar `dart run flutterfire configure` e escolher iOS para gerar o arquivo.

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

---

## Configuração Firebase (.env)

Copie `.env.example` para `.env` e preencha com os valores do seu projeto no [Firebase Console](https://console.firebase.google.com/). As variáveis necessárias dependem da plataforma em que você roda o app:

| Plataforma | Variáveis obrigatórias |
| ---------- | ---------------------- |
| **Web** | `FIREBASE_API_KEY_WEB`, `FIREBASE_APP_ID_WEB`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MEASUREMENT_ID` |
| **Android** | `FIREBASE_API_KEY_ANDROID`, `FIREBASE_APP_ID_ANDROID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET` |
| **iOS** | `FIREBASE_API_KEY_IOS`, `FIREBASE_APP_ID_IOS`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_IOS_BUNDLE_ID` |

Se alguma variável obrigatória para a plataforma atual estiver ausente, o app exibirá uma tela de "Configuração incompleta" em vez de inicializar o Firebase.

## Licença

Este projeto foi desenvolvido como parte do trabalho de pós-graduação em Engenharia de Front End.

## Autores

- [Gabrielle Martins](https://github.com/Gabrielle-96)
- [Helen Cris](https://github.com/HelenCrisM)

**Desenvolvido para fins acadêmicos.**
