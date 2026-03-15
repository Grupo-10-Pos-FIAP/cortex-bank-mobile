# Estrutura de pastas – Cortex Bank Mobile

**Quer uma versão curta?** Veja [LEIA-ME.md](LEIA-ME.md).

Este documento define a estrutura de pastas e convenções do projeto para manter o código **simples** e **robusto**. Para visão da arquitetura e guia de como desenvolver (novas features, telas, repositórios), veja [ARQUITETURA_E_DESENVOLVIMENTO.md](ARQUITETURA_E_DESENVOLVIMENTO.md).

---

## Princípios

1. **Feature-first** – O que pertence a uma funcionalidade fica dentro da feature.
2. **Core enxuto** – Só o que é usado por várias features ou pela app fica em `core/`.
3. **Poucos níveis** – Evitar muitas subpastas; preferir nomes claros.
4. **Consistência** – Todas as features seguem o mesmo padrão.

---

## Diagrama da árvore de pastas

### Visão hierárquica (Mermaid)

```mermaid
flowchart TB
  subgraph lib [lib]
    main[main.dart]
    app[app.dart]
    firebase[firebase_options.dart]
    subgraph core [core]
      constants[constants/]
      di[di/]
      errors[errors/]
      utils[utils/]
      widgets[widgets/]
      services[services/]
    end
    subgraph shared [shared]
      theme[theme/]
    end
    subgraph features [features]
      subgraph auth [auth]
        auth_data[data/]
        auth_models[models/]
        auth_state[state/]
        auth_presentation[presentation/]
      end
      subgraph transaction [transaction]
        tx_data[data/]
        tx_models[models/]
        tx_state[state/]
        tx_presentation[presentation/]
      end
      subgraph extrato [extrato]
        ext_presentation[presentation/]
      end
      subgraph home [home]
        home_presentation[presentation/]
      end
    end
    database[database/]
  end
```

### Árvore completa (pastas e arquivos .dart)

```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
│
├── core/
│   ├── constants/
|   |   |── app_routes.dart
│   │   └── .gitkeep
│   ├── di/
│   │   └── injection.dart
│   ├── errors/
│   │   └── failure.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── safe_log.dart
│   │   ├── env_validator.dart
│   │   ├── firebase_error_translator.dart
│   │   ├── currency_formatter.dart
│   │   ├── result.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card_container.dart
│       ├── app_connectivity.dart
│       ├── app_dropdown_field.dart
│       ├── app_error_message.dart
│       ├── app_loading.dart
│       ├── app_snackbar.dart
│       ├── app_tabs.dart
│       ├── app_text_field.dart
│       └── bottom_navigation.dart
│
├── shared/
│   └── theme/
│       ├── app_design_tokens.dart
│       └── app_theme.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_datasource_firebase.dart
│   │   │   │   ├── auth_datasource.dart
│   │   │   │   ├── user_datasource_firebase.dart
|   |   |   |   └── user_datasource.dart
│   │   │   ├── mappers/
│   │   │   │   └── auth_error_mapper.dart
│   │   │   └── repositories/
│   │   │       ├── i_auth_repository.dart
│   │   │       └── auth_repository_impl.dart
│   │   ├── models/
│   │   │   └── user.dart
│   │   ├── state/
│   │   │   └── auth_provider.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── profile_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           ├── auth_page_header.dart
│   │           └── auth_field_styles.dart
│   │
│   ├── contacts/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── contacts_datasource.dart
│   │   │   │   └── contacts_datasource_firebase.dart
│   │   │   └── repositories/
│   │   │       ├── i_contacts_repository.dart
│   │   │       └── contacts_repository_impl.dart
│   │   ├── models/
│   │   │   └──  contact.dart
│   │   ├── state/
│   │   │   └── contacts_provider.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           ├── add_contact_dialog_widget.dart
│   │           └── contact_list_item.dart
│   
│   ├── extrato/
│   │   └── presentation/
│   │       └── pages/
│   │           └── extrato_page.dart
│   │
│   └── home/
│       └── presentation/
│           └── pages/
|               ├── dashboard_page.dart
│               └── home_page.dart
|           └── widgets/
|               ├── dbalance_evolution_chart.dart
│               └── entry_exit_chart.dart
|
│   ├── transaction/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── transactions_datasource.dart
│   │   │   │   └── transactions_datasource_firestore.dart
│   │   │   └── repositories/
│   │   │       ├── i_transactions_repository.dart
│   │   │       └── transactions_repository_impl.dart
│   │   ├── models/
│   │   │   ├── transaction.dart
│   │   │   └── balance_summary.dart
│   │   ├── state/
│   │   │   └── transactions_provider.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── transaction_form_page.dart
│   │           └── transaction_new_form_page.dart
│   │       └── widgets/
│   │           ├── app_balance_card.dart
│   │           └── app_new_transaction_card.dart
```

---

## Estrutura atual (resumo por pasta)

```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart          # gerado (não editar)
│
├── core/                          # Compartilhado por todo o app (não depende de features)
│   ├── constants/                 # Constantes globais
│   ├── di/                        # Injeção de dependências (GetIt) – exceção: registra features
│   ├── errors/                    # Failure, tipos de erro
│   ├── utils/                     # Validadores, formatters, result, log, env
│   ├── widgets/                   # Componentes reutilizáveis (botões, campos, loading)
│
├── shared/                        # Compartilhado, fora do core
│   └── theme/                     # AppTheme, design tokens
│
├── features/                      # Uma pasta por funcionalidade
│   ├── auth/
│   │   ├── data/                  # Datasources, repositórios, mappers
│   │   ├── models/                # User
│   │   ├── state/                 # AuthProvider
│   │   └── presentation/
│   │       ├── pages/             # Login, Register
│   │       └── widgets/           # AuthPageHeader, AuthFieldStyles
│   ├── transaction/
│   │   ├── data/
│   │   ├── models/                # Transaction, BalanceSummary
│   │   ├── state/                 # TransactionsProvider
│   │   └── presentation/
│   │       └── pages/             # TransactionFormPage
│   ├── extrato/
│   │   └── presentation/
│   │       └── pages/             # ExtratoPage
│   └── home/
│       └── presentation/
│           └── pages/             # HomePage (shell com bottom nav)
```

---

## O que vai em cada pasta

| Pasta | Uso |
|-------|-----|
| **core/constants** | Constantes globais (chaves, valores compartilhados). |
| **core/di** | Registro de dependências (`injection.dart`). Único lugar em core que importa features. |
| **core/errors** | `Failure`, tipos de erro reutilizáveis. |
| **core/utils** | Funções puras: validadores, formatters, `Result`, log, env. |
| **core/widgets** | Widgets reutilizados em várias telas (ex.: `AppButton`, `AppTextField`). |
| **core/services** | Serviços de infraestrutura genéricos (ex.: FirestoreService). |
| **shared/theme** | `AppTheme`, design tokens, cores, tipografia. |
| **features/<nome>/data** | Contratos (interfaces), implementações, datasources, mappers. |
| **features/<nome>/models** | Modelos de domínio da feature. |
| **features/<nome>/state** | Providers/estado da feature (ex.: AuthProvider, TransactionsProvider). |
| **features/<nome>/presentation/pages** | Telas da feature. |
| **features/<nome>/presentation/widgets** | Widgets usados apenas nas páginas dessa feature. |

---

## Regras de nomenclatura

- **Pastas**: minúsculas, singular quando fizer sentido (`auth`, `transaction`, `extrato`).
- **Arquivos Dart**: snake_case (`auth_provider.dart`, `transaction_form_page.dart`).
- **Classes**: PascalCase (`AuthProvider`, `TransactionFormPage`).
- **Features**: um conceito por pasta (`auth`, `transaction`, `extrato`, `home`).

---

## Regras de dependência

- **core/** (exceto `core/di`) não deve importar nada de **features/**.
- **core/di** é a raiz de composição e registra implementações das features.
- Features podem importar **core/** e **shared/**.
- Uma feature pode importar outra quando fizer sentido (ex.: extrato usa `transaction/models`).

---

## Resumo

- **Simples**: poucos níveis, nomes óbvios, uma ideia por pasta.
- **Robusto**: feature-first, core só para compartilhado, presentation/state/data/models por feature.
- **Coeso**: cada feature contém apenas código do seu domínio; tema em shared, erros e utils em core.
