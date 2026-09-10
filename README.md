# 🐍 Mamba Fast Tracker

> **Aplicativo Mobile Offline-First de Jejum Intermitente e Controle Calórico Diário**
> Desenvolvido em Flutter com Clean Architecture, BLoC/Cubit, Persistência Local NoSQL (Hive) e Notificações Nativa Agendadas por Timezone.

---

## 📋 Sumário
1. [Visão Geral do Produto](#1-visão-geral-do-produto)
2. [Arquitetura de Software & Design Patterns](#2-arquitetura-de-software--design-patterns)
3. [Stack Tecnológica Completa](#3-stack-tecnológica-completa)
4. [Funcionalidades Entregues & Detalhes de Implementação](#4-funcionalidades-entregues--detalhes-de-implementação)
5. [Testes Automatizados](#5-testes-automatizados)
6. [Instruções de Execução & Entrega do APK](#6-instruções-de-execução--entrega-do-apk)

---

## 1. 🌟 Visão Geral do Produto

O **Mamba Fast Tracker** é uma solução completa para acompanhamento de saúde, com foco em **Jejum Intermitente** e **Controle Nutricional Calórico**. Projetado como uma aplicação **Offline-First**, garante autonomia total ao usuário, sem dependência de conectividade com servidores externos.

### 🛡️ Resiliência do Timer (Zero In-Memory Volatility)
Um dos principais diferenciais técnicos da aplicação é a arquitetura resiliente do timer de jejum:
- **Resiliência a Falhas & Encerramento:** O temporizador **não depende** de um serviço background ativo gastando bateria. A data/hora exata do início do jejum é persistida em formato UTC (`DateTime.now().toUtc()`) no banco NoSQL **Hive**.
- **Cálculo Delta Dinâmico:** Sempre que a aplicação é iniciada, reaberta do background ou quando o dispositivo é reiniciado, o progresso é calculado pela diferença matemática instantânea entre o horário atual e o timestamp de início:
  $$\text{elapsed} = \text{now.toUtc()} - \text{startTime}$$
- **Integridade Garantida:** Mesmo se o smartphone for desligado por 16 horas, ao reabrir o app o timer estará na contagem exata e marcará a sessão como concluída com precisão matemática.

---

## 2. 🏗️ Arquitetura de Software & Design Patterns

A aplicação adota rigorosamente os princípios da **Clean Architecture** alinhados à estratégia **Feature-First**, garantindo separação clara de responsabilidades, alta testabilidade, baixo acoplamento e escalabilidade para grandes equipes de engenharia.

```
lib/
├── main.dart
├── core/
│   ├── di/                 # Injeção de Dependências Centralizada (GetIt)
│   ├── error/              # Tratamento Global de Falhas e Exceções
│   ├── notifications/      # Serviço Encapsulado de Notificações Locais
│   ├── theme/              # Design System Dark Neon (Material 3)
│   ├── usecases/           # Contrato Base de Casos de Uso (UseCase)
│   └── utils/              # Ticker de Re-renderização e Utilitários
└── features/
    ├── auth/               # Autenticação & Sessão Persistida
    ├── fasting/            # Cronômetro, Protocolos & Sessões de Jejum
    ├── meals/              # Registro e Cálculo Diário de Refeições/Calorias
    ├── history_metrics/    # Agregação Semanal & Gráficos com fl_chart
    └── navigation/         # Controle de Navegação Principal (BottomBar)
```

### 🧱 Divisão de Camadas por Feature

Cada módulo em `lib/features/` possui a seguinte estrutura interna de 3 camadas:

```
feature_name/
├── domain/                  # 🟢 Regras de Negócio Puras (Dart Puro, Zero Flutter)
│   ├── entities/            # Entidades do Domínio (FastingSession, Meal, UserSession)
│   ├── repositories/        # Contratos Abstratos de Repositório
│   └── usecases/            # Casos de Uso Únicos (Single Responsibility Principle)
├── data/                    # 🟡 Camada de Dados e Integração Externa
│   ├── datasources/         # Fontes de Dados Locais (Hive Boxes)
│   ├── models/              # DTOs e Serializadores (TypeAdapters/JSON)
│   └── repositories/        # Implementação Concreta dos Repositórios do Domínio
└── presentation/            # 🔵 Camada de Apresentação e UI
    ├── cubit/               # Gerenciamento de Estado Reativo (BLoC/Cubit)
    ├── pages/               # Telas do Aplicativo (Scaffolds)
    └── widgets/             # Componentes Visuais Reutilizáveis e Customizados
```

### 💡 Justificativa Técnica da Arquitetura
- **Desacoplamento de UI e Regras de Negócio:** A camada `domain` não possui nenhuma dependência do Flutter SDK, permitindo testar toda a lógica de jejum e refeições com testes unitários puros ultrarrápidos.
- **Inversão de Dependência (DIP):** Os Casos de Uso dependem apenas de contratos abstratos (`FastingRepository`). A implementação concreta (`FastingRepositoryImpl`) pode ter a fonte de dados trocada (ex: de Hive para SQLite ou Firebase) sem alterar uma única linha da regra de negócio.

---

## 3. 🛠️ Stack Tecnológica Completa

| Package | Versão | Finalidade Prática no Projeto |
| :--- | :--- | :--- |
| **`flutter_bloc`** | `^8.1.3` | Gerenciamento de estado reativo previsível e testável utilizando a abordagem BLoC/Cubit. |
| **`hive`** & **`hive_flutter`** | `^2.2.3` | Banco de dados NoSQL embarcado chave-valor de alta performance para persistência offline rápida. |
| **`get_it`** | `^7.6.0` | Service Locator para injeção de dependências desacoplada e gerenciamento de singletons. |
| **`fl_chart`** | `^0.69.0` | Biblioteca de gráficos interativos para renderização das métricas semanais de jejum e calorias. |
| **`flutter_local_notifications`** | `^17.0.0` | Agendamento e disparo de notificações locais nativas no Android e iOS. |
| **`timezone`** | `^0.9.2` | Suporte a fuso horário e conversão de timestamps para agendamento preciso de alarmes. |
| **`equatable`** | `^2.0.5` | Comparação de igualdade de objetos por valor para otimização de emitição de estados no Cubit. |
| **`intl`** | `^0.19.0` | Formatação de datas, horas e localização para Português do Brasil (pt-BR). |

---

## 4. ⚡ Funcionalidades Entregues & Detalhes de Implementação

### ⏱️ Módulo 1: Jejum Intermitente (`fasting`)
- **Protocolos Pré-configurados & Personalizado:**
  - `12:12 Iniciante` (12 horas de jejum)
  - `16:8 Intermediário` (16 horas de jejum)
  - `18:6 Avançado` (18 horas de jejum)
  - `Personalizado`: Diálogo com seletor interativo de 1 a 168 horas (com chips rápidos para 14h, 20h, 24h, 36h e 48h).
- **Visualizador Circular Interativo (`CircularFastingProgressWidget`):**
  - Renderizador CustomPainter com gradiente Dark Neon.
  - Exibição de porcentagem acumulada, tempo decorrido e tempo restante formatados.
- **Distinção UX Clara entre Ações:**
  - **`CONCLUIR JEJUM`** (🟢 Verde Neon): Exibido quando a meta é atingida (100%), registrando a vitória no histórico.
  - **`ENCERRAR JEJUM`** (🟡 Dourado): Exibido para encerramento antecipado. Preserva e contabiliza as horas jejuadas no histórico e estatísticas.
  - **`CANCELAR JEJUM`** (🔴 Vermelho): Exibido para descarto explícito da sessão ativa.

### 🥗 Módulo 2: Registro de Refeições & Calorias (`meals`)
- **CRUD Completo:** Adição, edição e remoção de refeições com suporte a nome, quantidade de calorias, horário e categorias (*Café da Manhã, Almoço, Jantar, Lanche*).
- **Cálculo da Meta Diária:** Barra de progresso dinâmica em tempo real contra a meta configurável de calorias diárias (ex: 2.000 kcal).

### 📊 Módulo 3: Métricas Semanal & Histórico (`history_metrics`)
- **Gráficos com `fl_chart`:** Barras duplas com o progresso dos últimos 7 dias comparando horas jejuadas e consumo calórico.
- **Cards de Métricas:** Média de horas de jejum diário, total de sessões concluídas e consumo calórico acumulado.

### 🔔 Módulo 4: Sistema de Notificações Locais (`core/notifications`)
- Encapsulado em `NotificationService`.
- **Agendamento Inteligente:** Ao iniciar um jejum, utiliza `zonedSchedule` para agendar um alarme nativo para a hora exata do término.
- **Web Safe Guard:** Tratamento multiplataforma seguro (`if (kIsWeb) return;`) para prevenção de exceções no Flutter Web.

### 🎨 Módulo 5: UI/UX & Design System (`core/theme`)
- Design Dark Neon moderno (Fundo escuro `#0A0E12`, superfícies em card `#1E2630`, destaques em Amarelo/Dourado `#FFB800` e Verde Neon `#00E676`).
- **Localização:** 100% dos rótulos, diálogos e mensagens em **Português do Brasil (pt-BR)**.

---

## 5. 🧪 Testes Automatizados

O projeto conta com uma suíte abrangente de testes unitários para garantir a estabilidade das regras de negócio críticas.

```bash
# Comando para rodar a suíte completa de testes
flutter test
```

### Cobertura de Cenários Testados (15/15 Aprovados):
1. **Domain Testes de Jejum (`test/features/fasting/domain/fasting_session_test.dart`):**
   - Validação de cálculo de tempo decorrido (`getElapsedDuration`) via timestamps UTC fixos.
   - Validação de tempo restante (`getRemainingDuration`) e porcentagem (`getProgress`).
   - Verificação da flag `isGoalReached` quando a meta é atingida.
2. **Domain Testes de Refeições (`test/features/meals/domain/meal_calculation_test.dart`):**
   - Soma acumulada de calorias em listas de refeições.
   - Cálculo de progresso percentual e travamento em 100% no excesso de meta.
3. **Presentation Testes do Cubit (`test/features/fasting/presentation/fasting_cubit_test.dart`):**
   - Seleção de protocolos e duração personalizada.
   - Fluxo de início de jejum e disparos do `NotificationService`.
   - Fluxo de encerramento antecipado (`endedEarly`), conclusão (`completed`) e cancelamento (`cancelled`).

---

## 6. 🚀 Instruções de Execução & Entrega do APK

### Pré-requisitos
- Flutter SDK `3.x` instalado e configurado na máquina.
- Android SDK (API 34/35/36) com suporte a Desugaring habilitado.

### Comandos de Execução

#### 1. Executar no Navegador Web (Chrome)
```bash
flutter run -d chrome
```

#### 2. Executar no Emulador ou Dispositivo Android
```bash
flutter run -d android
```

#### 3. Gerar Build de Produção Android (APK)
```bash
flutter build apk --release
```

---

### 📦 Entrega do APK de Produção

O APK compilado para testes diretos em dispositivos Android está disponível na pasta `release/` na raiz do projeto:

```text
📁 release/
 └── 📄 mamba-fast-tracker.apk
```

> **Caminho Completo do Arquivo:**  
> `release/mamba-fast-tracker.apk`

---

<p align="center">
  Desenvolvido com excelência técnica para o <b>Mamba Fast Tracker</b> 🐍
</p>
