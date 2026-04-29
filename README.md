# Banco de Dados de Futebol — Campo Analítico

#### Por: Campo Analítico
#### Suporte: [campoanalitico.com.br](https://campoanalitico.com.br/) · [@analiticocampo](https://x.com/analiticocampo)
#### Atualizado em: Abril de 2025

---

Este repositório contém um banco de dados estruturado de futebol — partidas, jogadores, times, estatísticas, transferências e estádios — disponibilizado em formato CSV e acessível remotamente via pacote R. Os dados podem ser carregados diretamente no R sem necessidade de download manual dos arquivos.

---

## Instalação

Certifique-se de ter o **R 4.0 ou superior** e o pacote `devtools` instalados.

```r
# Instalar devtools se necessário
install.packages("devtools")

# Instalar o pacote campodados
devtools::install_github("campoanaliticoestudos/Banco-de-dados-futebol")

# Carregar
library(campodados)
```

---

## Início Rápido

```r
library(campodados)

# Verificar conexão com o repositório
ca_ping()

# Ver todos os datasets disponíveis
ca_info()

# Carregar partidas do Brasileirão 2023
partidas <- ca_partidas(competicao = "Brasileirao", temporada = 2023)

# Carregar estatísticas de jogadores
stats <- ca_stats_jogadores(temporada = 2023)
```

---

## Funções da API

### `ca_ping()`

Testa a conectividade com o repositório remoto.

```r
ca_ping()
# [ OK ] Repositorio acessivel em: https://raw.githubusercontent.com/...
```

---

### `ca_catalogo()`

Retorna um data frame com todos os datasets disponíveis e suas descrições.

```r
catalogo <- ca_catalogo()
print(catalogo)
```

---

### `ca_partidas(competicao, temporada)`

Carrega o dataset de partidas.

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `competicao` | character | Filtrar por competição (ex: `"Brasileirao"`, `"Copa do Brasil"`). Default: `NULL` |
| `temporada` | numeric | Filtrar por ano (ex: `2023`). Default: `NULL` |

```r
# Todas as partidas disponíveis
partidas <- ca_partidas()

# Brasileirão 2023
br2023 <- ca_partidas(competicao = "Brasileirao", temporada = 2023)

# Copa do Brasil 2022
copa22 <- ca_partidas(competicao = "Copa do Brasil", temporada = 2022)
```

**Colunas retornadas:**

```
partida_id | data | competicao | temporada | rodada |
time_casa | time_visitante | gols_casa | gols_visitante |
estadio | arbitro | publico
```

---

### `ca_jogadores(posicao, nacionalidade)`

Carrega o cadastro de jogadores.

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `posicao` | character | Filtrar por posição (ex: `"Atacante"`, `"Meia"`, `"Zagueiro"`). Default: `NULL` |
| `nacionalidade` | character | Filtrar por nacionalidade (ex: `"Brasil"`, `"Argentina"`). Default: `NULL` |

```r
# Todos os jogadores
jogadores <- ca_jogadores()

# Atacantes brasileiros
atacantes_br <- ca_jogadores(posicao = "Atacante", nacionalidade = "Brasil")
```

**Colunas retornadas:**

```
jogador_id | nome | data_nascimento | nacionalidade |
posicao | pe_dominante | altura | peso | time_atual
```

---

### `ca_times(pais)`

Carrega o cadastro de times e clubes.

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `pais` | character | Filtrar por país. Default: `NULL` |

```r
times <- ca_times()
times_br <- ca_times(pais = "Brasil")
```

---

### `ca_stats_jogadores(jogador_id, temporada, tipo)`

Carrega estatísticas individuais de jogadores.

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `jogador_id` | numeric | ID do jogador para filtrar. Default: `NULL` |
| `temporada` | numeric | Filtrar por ano. Default: `NULL` |
| `tipo` | character | `"temporada"` (agregado) ou `"partida"` (por jogo). Default: `"temporada"` |

```r
# Estatísticas agregadas de 2023
stats_2023 <- ca_stats_jogadores(temporada = 2023)

# Estatísticas por partida de um jogador específico
stats_id <- ca_stats_jogadores(jogador_id = 42, tipo = "partida")
```

**Colunas retornadas (principais):**

```
jogador_id | temporada | partidas | minutos | gols | assistencias |
xg | xa | chutes | chutes_no_alvo | passes | passes_precisos |
dribles | desarmes | interceptacoes | faltas
```

---

### `ca_stats_times(time_id, temporada, tipo)`

Carrega estatísticas coletivas de times.

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `time_id` | numeric | ID do time para filtrar. Default: `NULL` |
| `temporada` | numeric | Filtrar por ano. Default: `NULL` |
| `tipo` | character | `"temporada"` ou `"partida"`. Default: `"temporada"` |

```r
stats_times <- ca_stats_times(temporada = 2023)
stats_flamengo <- ca_stats_times(time_id = 10, tipo = "partida")
```

---

### `ca_transferencias(temporada, janela)`

Carrega o histórico de transferências.

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `temporada` | numeric | Filtrar por ano. Default: `NULL` |
| `janela` | character | `"verao"` ou `"inverno"`. Default: `NULL` |

```r
transferencias <- ca_transferencias(temporada = 2023)
transf_inv <- ca_transferencias(temporada = 2023, janela = "inverno")
```

---

### `ca_estadios(pais)`

Carrega informações sobre estádios.

```r
estadios <- ca_estadios()
estadios_br <- ca_estadios(pais = "Brasil")
```

---

## Exemplos de Análise

### Top 10 artilheiros do Brasileirão 2023

```r
library(campodados)
library(dplyr)
library(ggplot2)

stats    <- ca_stats_jogadores(temporada = 2023)
jogadores <- ca_jogadores()

artilheiros <- stats %>%
  group_by(jogador_id) %>%
  summarise(gols = sum(gols, na.rm = TRUE)) %>%
  arrange(desc(gols)) %>%
  slice(1:10) %>%
  left_join(jogadores[, c("jogador_id", "nome", "time")], by = "jogador_id")

ggplot(artilheiros, aes(x = reorder(nome, gols), y = gols)) +
  geom_col(fill = "#1D9E75") +
  coord_flip() +
  labs(
    title    = "Top 10 Artilheiros — Brasileirão 2023",
    subtitle = "Fonte: Campo Analítico | campoanalitico.com.br",
    x = NULL, y = "Gols"
  ) +
  theme_minimal(base_size = 13)
```

### Posse de bola vs xG médio

```r
stats_times <- ca_stats_times(temporada = 2023)

ggplot(stats_times, aes(x = posse_bola_media, y = xg_media, label = time)) +
  geom_point(size = 3, color = "#0F6E56") +
  geom_text(vjust = -0.8, size = 3) +
  labs(
    title    = "Posse de Bola vs xG Médio — Brasileirão 2023",
    subtitle = "Fonte: Campo Analítico | campoanalitico.com.br",
    x = "Posse de Bola Média (%)",
    y = "xG Médio por Partida"
  ) +
  theme_minimal()
```

---

## Acesso Direto por URL (sem pacote)

Caso prefira não instalar o pacote, qualquer arquivo CSV pode ser carregado diretamente via URL:

```r
# URL base
base <- "https://raw.githubusercontent.com/campoanaliticoestudos/Banco-de-dados-futebol/main/data/"

# Carregar partidas diretamente
partidas <- read.csv(paste0(base, "partidas.csv"), encoding = "UTF-8")

# Carregar jogadores diretamente
jogadores <- read.csv(paste0(base, "jogadores.csv"), encoding = "UTF-8")

# Carregar estatísticas diretamente
stats <- read.csv(paste0(base, "estatisticas_jogadores.csv"), encoding = "UTF-8")
```

---

## Estrutura do Repositório

```
Banco-de-dados-futebol/
├── R/
│   └── api.R                    # Funções de acesso remoto (pacote campodados)
├── data/
│   ├── partidas.csv
│   ├── jogadores.csv
│   ├── times.csv
│   ├── estatisticas_jogadores.csv
│   ├── estatisticas_jogadores_partida.csv
│   ├── estatisticas_times.csv
│   ├── estatisticas_times_partida.csv
│   ├── transferencias.csv
│   └── estadios.csv
├── inst/
│   └── examples/
│       └── uso_basico.R         # Script de exemplos completo
├── DESCRIPTION
├── NAMESPACE
└── README.md
```

---

## Dependências

O pacote `campodados` depende apenas de `utils` (base do R). Para as análises dos exemplos:

```r
install.packages(c("dplyr", "ggplot2", "tidyr"))
```

---

## Notas

- Os dados são atualizados periodicamente. Execute `ca_ping()` antes de iniciar uma análise para confirmar que o repositório está acessível.
- Caracteres especiais são codificados em UTF-8. Em Windows, caso ocorram problemas de encoding, adicione `fileEncoding = "UTF-8"` nas chamadas diretas por URL.
- Para relatar erros nos dados ou sugerir melhorias, abra uma [Issue](https://github.com/campoanaliticoestudos/Banco-de-dados-futebol/issues).
- Para dúvidas sobre análise e uso em R, acesse [campoanalitico.com.br](https://campoanalitico.com.br/).

---

## Sobre

Este banco de dados é mantido pelo **Campo Analítico**, primeira escola brasileira de estatística aplicada ao futebol para analistas de desempenho.

[![GitHub](https://img.shields.io/badge/GitHub-campoanaliticoestudos-0F6E56?style=for-the-badge&logo=github&logoColor=white)](https://github.com/campoanaliticoestudos)
[![Site](https://img.shields.io/badge/Site-campoanalitico.com.br-1D9E75?style=for-the-badge)](https://campoanalitico.com.br/)
