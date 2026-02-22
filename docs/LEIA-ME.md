# Guia rápido – estrutura do projeto

Versão resumida. Quem quiser todos os detalhes vê [ESTRUTURA_PROJETO.md](ESTRUTURA_PROJETO.md) e [ARQUITETURA_E_DESENVOLVIMENTO.md](ARQUITETURA_E_DESENVOLVIMENTO.md).

---

## Em uma frase

O código é organizado **por funcionalidade** (auth, transação, extrato, home). Cada uma tem suas telas, estado, dados e modelos dentro da própria pasta. O que serve para várias funcionalidades fica em `core/` ou `shared/`.

---

## Onde fica cada coisa

| Se for… | Coloque em… |
|---------|--------------|
| Tela (página) | `features/<nome>/presentation/pages/` |
| Widget só daquela tela | `features/<nome>/presentation/widgets/` |
| Provider / estado da funcionalidade | `features/<nome>/state/` |
| Chamada a API, Firebase, repositório | `features/<nome>/data/` |
| Modelo (ex.: User, Transaction) | `features/<nome>/models/` |
| Botão, campo, loading usados em várias telas | `core/widgets/` |
| Validação, formatação, Result, Failure | `core/utils/` ou `core/errors/` |
| Cores, tema, design tokens | `shared/theme/` |

---

## Estrutura em uma olhada

```
lib/
├── main.dart, app.dart
├── core/          → coisas que várias partes do app usam
│   ├── utils/     → validadores, formatters, result
│   ├── errors/    → Failure
│   ├── widgets/   → AppButton, AppTextField, etc.
│   ├── services/  → Firebase genérico
│   └── di/        → registro de dependências (único que conhece as features)
├── shared/
│   └── theme/     → tema e cores
├── features/      → uma pasta por funcionalidade
│   ├── auth/      → login, cadastro, User, AuthProvider
│   ├── transaction/ → transações, Transaction, TransactionsProvider
│   ├── extrato/   → tela de extrato
│   └── home/      → tela principal (bottom nav)
└── database/      → mocks para testes
```

Dentro de uma feature (ex.: auth):

```
auth/
├── data/          → repositórios, datasources (API/Firebase)
├── models/        → User
├── state/         → AuthProvider
└── presentation/
    ├── pages/     → LoginPage, RegisterPage
    └── widgets/  → cabeçalho, estilos dos campos
```

---

## Regra importante

**`core/` não importa `features/`.**  
A única exceção é `core/di/injection.dart`, que precisa registrar as implementações das features. Todo o resto do core (utils, widgets, errors, services) não conhece auth, transaction, etc.

---

## Nomes

- Pastas: minúsculas (`auth`, `transaction`).
- Arquivos: snake_case (`login_page.dart`, `auth_provider.dart`).
- Classes: PascalCase (`LoginPage`, `AuthProvider`).

---

## “Preciso fazer X, onde vou?”

| Quero… | Onde |
|--------|------|
| Nova tela | `features/<nome>/presentation/pages/` + rota em `app.dart` |
| Novo método (ex.: buscar por ID) | Interface e impl em `data/repositories/`, método no provider em `state/`, chamada na tela |
| Nova funcionalidade inteira | Nova pasta em `features/<nome>/` com data, models, state, presentation. Registrar no `core/di` e no `main` (providers). |
| Cor, espaçamento, fonte | `shared/theme/` |
| Validador ou formatador genérico | `core/utils/` |

---

Para fluxo de dados, camadas e passo a passo de desenvolvimento, use o [ARQUITETURA_E_DESENVOLVIMENTO.md](ARQUITETURA_E_DESENVOLVIMENTO.md).
