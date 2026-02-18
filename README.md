# Cortex Bank Mobile

Desenvolver uma aplicação de gerenciamento financeiro, utilizando Flutter Mobile, com funcionalidades avançadas que foram ensinadas nas disciplinas. A aplicação deve ser capaz de gerenciar transações financeiras,
integrando recursos de navegação, segurança, autenticação e armazenamento
em cloud.

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

**Desenvolvido para fins acadêmicos e de demonstração de arquitetura de microfrontends.**
