# Arquitetura, estrutura e guia de desenvolvimento

**Quer só o essencial?** Veja [LEIA-ME.md](LEIA-ME.md).

Este documento explica a arquitetura do Cortex Bank Mobile, como o código está organizado e **como desenvolver** mantendo a mesma base. Para detalhes da árvore de pastas, veja [ESTRUTURA_PROJETO.md](ESTRUTURA_PROJETO.md).

---

## 1. Visão geral da arquitetura

O projeto segue um **modelo feature-based** com separação clara em camadas dentro de cada feature. O fluxo de dados é unidirecional: a UI reage ao estado gerenciado por providers, que usam repositórios (abstrações); a implementação dos repositórios acessa APIs ou banco.

```
┌─────────────────────────────────────────────────────────────────┐
│  Presentation (pages, widgets)                                  │
│  → Lê estado e dispara ações via Provider                        │
└────────────────────────────┬────────────────────────────────────┘
                              │
┌─────────────────────────────▼──────────────────────────────────┐
│  State (providers)                                               │
│  → Mantém estado da feature, chama Repository                    │
└─────────────────────────────┬────────────────────────────────────┘
                              │
┌─────────────────────────────▼──────────────────────────────────┐
│  Data (repositories, datasources)                                │
│  → Repository: orquestra; Datasource: API/Firebase/local        │
└─────────────────────────────┬────────────────────────────────────┘
                              │
┌─────────────────────────────▼──────────────────────────────────┐
│  Models                                                          │
│  → Entidades de domínio (User, Transaction, etc.)                │
└─────────────────────────────────────────────────────────────────┘
```

**Princípios:**

- **Feature-first:** cada funcionalidade (auth, transaction, extrato, home) tem seu próprio “pedaço” de código (data, models, state, presentation).
- **Inversão de dependência:** a UI e o state dependem de **interfaces** (ex.: `IAuthRepository`), não de implementações. As implementações são injetadas em `main` via GetIt.
- **Core compartilhado:** lógica e widgets usados em várias features ficam em `core/` e `shared/`. Nada em `core/` (exceto `di`) importa `features/`.
- **Result para erros:** operações que podem falhar retornam `Result<T>` (sucesso ou `Failure`), em vez de exceções ou `null` para erros de regra de negócio.

---

## 2. Camadas em detalhe

### 2.1 Presentation

- **Onde:** `features/<nome>/presentation/pages/` e `presentation/widgets/`.
- **Responsabilidade:** exibir dados e capturar ações do usuário. Não deve conter regra de negócio nem chamar API/Firebase diretamente.
- **Como usa o estado:** `context.read<MeuProvider>()` para disparar ações; `Consumer<MeuProvider>` ou `context.watch<MeuProvider>()` para reagir a mudanças.
- **Exemplo:** `LoginPage` valida o formulário, chama `auth.signIn(...)` no provider e navega conforme o resultado.

### 2.2 State

- **Onde:** `features/<nome>/state/`.
- **Responsabilidade:** manter o estado da feature (loading, dados, mensagens de erro) e expor métodos que a UI chama. O state chama o **repositório** (interface), nunca o datasource direto.
- **Padrão:** classes que estendem `ChangeNotifier`, registradas como `ChangeNotifierProvider` no `main.dart`.
- **Exemplo:** `AuthProvider` guarda `user`, `loading`, `errorMessage` e chama `_authRepository.signIn(...)`.

### 2.3 Data

- **Onde:** `features/<nome>/data/` (repositórios e, quando existir, datasources/mappers).
- **Responsabilidade:**
  - **Repository (implementação):** orquestrar um ou mais datasources (remote/local), converter erros em `Failure` e retornar `Result<T>`.
  - **Datasource:** falar com API, Firebase ou armazenamento local; retornar `Result<T>` ou dados que o repository converte em `Result`.
- **Interfaces:** ficam em `data/repositories/` (ex.: `i_auth_repository.dart`). A UI e o state dependem só da interface; a implementação é registrada no `core/di/injection.dart`.

### 2.4 Models

- **Onde:** `features/<nome>/models/`.
- **Responsabilidade:** representar entidades de domínio (imutáveis, com `final` e `const` quando possível).
- **Exemplo:** `User`, `Transaction`, `BalanceSummary`. Usados pelo state, pelos repositórios e pelas páginas (para exibição).

### 2.5 Core e shared

- **core/:** erros (`Failure`), utils (validators, formatters, `Result`), widgets reutilizáveis, serviços genéricos (ex.: Firestore), DI. Não deve depender de features (exceto o registro em `core/di`).
- **shared/theme/:** tema, design tokens, cores. Usado por várias features e por widgets do core.

---

## 3. Fluxo de dados (exemplo: login)

1. Usuário preenche email/senha e toca em “Entrar”.
2. **LoginPage** valida (usando `core/utils/validators`) e chama `context.read<AuthProvider>().signIn(email, password)`.
3. **AuthProvider** atualiza `loading`, chama `_authRepository.signIn(email, password)` e, com o `Result`, atualiza `_user` e `_errorMessage` e chama `notifyListeners()`.
4. **AuthRepositoryImpl** chama o **AuthRemoteDataSource** (ex.: Firebase), em caso de sucesso persiste no **AuthLocalDataSource**, e retorna `Success(user)` ou `FailureResult(failure)`.
5. A **LoginPage** está dentro de um `Consumer<AuthProvider>`: quando o provider notifica, a tela reage (loading, erro ou navegação para extrato).

Nenhuma camada “pula” a anterior: a página não fala com o repositório nem com o Firebase; tudo passa pelo provider e pelo repositório.

---

## 4. Como desenvolver seguindo essa base

### 4.1 Adicionar uma nova feature

1. Criar a pasta da feature: `lib/features/<nome_feature>/`.
2. Definir o que a feature precisa:
   - **Models:** criar em `models/` (ex.: `meu_model.dart`).
   - **Data:** se houver acesso a API/banco, criar interface do repositório em `data/repositories/` (ex.: `i_meu_repository.dart`) e a implementação em `data/repositories/meu_repository_impl.dart`; se houver chamada a serviço externo, criar datasource em `data/datasources/`.
   - **State:** criar o provider em `state/` (ex.: `meu_provider.dart`) que usa a interface do repositório.
   - **Presentation:** criar páginas em `presentation/pages/` e, se precisar, widgets em `presentation/widgets/`.
3. Registrar no DI: em `core/di/injection.dart`, registrar a implementação do repositório (e datasources, se existirem).
4. No `main.dart`, criar o provider e adicionar ao `MultiProvider` (ex.: `ChangeNotifierProvider(create: (_) => MeuProvider(getIt<IMeuRepository>()))`).
5. Em `app.dart`, registrar rotas e/ou incluir a tela no `home` ou em outra navegação.

Mantenha a mesma convenção de nomes (snake_case para arquivos, PascalCase para classes) e imports com `package:cortex_bank_mobile/...`.

### 4.2 Adicionar uma nova tela em uma feature existente

1. Criar o arquivo da página em `features/<nome>/presentation/pages/` (ex.: `minha_nova_page.dart`).
2. Usar o provider da feature: `context.read<MeuProvider>()` para ações e `Consumer<MeuProvider>` ou `context.watch<MeuProvider>()` para reagir ao estado.
3. Reaproveitar widgets de `core/widgets` e, se fizer sentido, de `features/<nome>/presentation/widgets/`.
4. Registrar a rota em `app.dart` em `routes` e navegar com `Navigator.pushNamed(context, '/minha-rota')` (ou equivalente).

Não coloque lógica de negócio na página; mantenha no provider e no repositório.

### 4.3 Adicionar um novo método no repositório (ex.: “buscar por ID”)

1. Incluir a assinatura na **interface** em `data/repositories/i_meu_repository.dart` (ex.: `Future<Result<MeuModel?>> getById(String id);`).
2. Implementar em `data/repositories/meu_repository_impl.dart` (chamar datasource, tratar erro com `Failure`, retornar `Result`).
3. No **provider** da feature, criar um método que chame o repositório, atualize o estado e chame `notifyListeners()`.
4. Na **tela**, chamar o método do provider (ex.: `context.read<MeuProvider>().loadById(id)`).

Assim a cadeia Presentation → State → Data continua consistente.

### 4.4 Usar algo compartilhado (validação, formato, widget)

- **Validação / formatação / helpers:** colocar em `core/utils/` (ex.: `validators.dart`, `currency_formatter.dart`). São funções ou classes que não dependem de Flutter nem de features.
- **Widget genérico:** se for usado em mais de uma feature, colocar em `core/widgets/` (ex.: `AppButton`, `AppTextField`). Se for só da feature, em `features/<nome>/presentation/widgets/`.
- **Tema / cores:** usar `shared/theme/` (ex.: `AppDesignTokens`, `AppTheme`). Importar com `package:cortex_bank_mobile/shared/theme/...`.

### 4.5 Uma feature usar outra (ex.: extrato usar transações)

- É permitido uma feature importar outra quando fizer sentido de domínio (ex.: extrato mostrar lista de transações).
- Prefira depender de **models** e **state** (provider) da outra feature; evite depender da **presentation** ou de detalhes internos da **data** (datasources). Exemplo: extrato usa `TransactionsProvider` e `Transaction`; não acessa `TransactionsRepositoryImpl` nem os datasources.

---

## 5. Convenções e boas práticas

| Aspecto | Convenção |
|--------|-----------|
| **Pastas** | Minúsculas, singular quando fizer sentido (`auth`, `transaction`). |
| **Arquivos** | snake_case: `auth_provider.dart`, `transaction_form_page.dart`. |
| **Classes** | PascalCase: `AuthProvider`, `TransactionFormPage`. |
| **Interfaces** | Podem usar prefixo `I` (ex.: `IAuthRepository`) ou não; o projeto atualmente usa `I`. Implementação: sufixo `Impl` (ex.: `AuthRepositoryImpl`). |
| **Imports** | Preferir `package:cortex_bank_mobile/...` para arquivos do projeto. |
| **Estado** | Manter no provider; não espalhar estado global além do necessário. |
| **Erros** | Operações que podem falhar retornam `Result<T>`; usar `Failure` para mensagem/código. |
| **Core** | Não importar features (exceto em `core/di` para registrar implementações). |

---

## 6. Checklist rápido ao desenvolver

- [ ] Nova feature? Criar pasta em `features/<nome>` com data/models/state/presentation conforme necessário.
- [ ] Nova tela? Colocar em `presentation/pages/` e registrar rota em `app.dart`.
- [ ] Novo caso de uso (ação do usuário)? Método no provider que chama o repositório; página só chama o provider.
- [ ] Novo acesso a API/banco? Interface do repositório + implementação + registro no `injection.dart`; provider recebe a interface por parâmetro.
- [ ] Algo usado em várias features? Colocar em `core/` ou `shared/` e não depender de features.
- [ ] Imports: nenhum import quebrado; core não depende de features (exceto `di`).

---

## 7. Referência cruzada

- **Estrutura de pastas e regras de pasta:** [ESTRUTURA_PROJETO.md](ESTRUTURA_PROJETO.md).
- **Raiz do app e rotas:** `lib/main.dart`, `lib/app.dart`.
- **Registro de dependências:** `lib/core/di/injection.dart`.
- **Exemplos de feature completa:** `lib/features/auth/` (login, registro, repositório, datasources, provider, models).

Com isso, a arquitetura, a estrutura e o fluxo de desenvolvimento ficam documentados e reproduzíveis por qualquer pessoa que for desenvolver na mesma base.
