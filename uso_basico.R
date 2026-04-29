# =============================================================================
# Campo Analítico — Exemplos de uso da API remota
# github.com/campoanaliticoestudos/Banco-de-dados-futebol
# =============================================================================

# 1. Instalar o pacote (apenas na primeira vez) ----------------------------

install.packages("devtools")  # se ainda não tiver
devtools::install_github("campoanaliticoestudos/Banco-de-dados-futebol")


# 2. Carregar o pacote ------------------------------------------------------

library(campodados)


# 3. Verificar conectividade ------------------------------------------------

ca_ping()
# [ OK ] Repositorio acessivel em: https://raw.githubusercontent.com/...


# 4. Ver datasets disponíveis -----------------------------------------------

ca_info()
ca_catalogo()


# 5. Carregar dados ---------------------------------------------------------

# Todas as partidas
partidas <- ca_partidas()

# Apenas Brasileirão 2023
br2023 <- ca_partidas(competicao = "Brasileirao", temporada = 2023)

# Jogadores atacantes brasileiros
atacantes <- ca_jogadores(posicao = "Atacante", nacionalidade = "Brasil")

# Times brasileiros
times_br <- ca_times(pais = "Brasil")

# Estatísticas da temporada 2023
stats_2023 <- ca_stats_jogadores(temporada = 2023)

# Estatísticas por partida de um jogador específico
stats_jogador <- ca_stats_jogadores(jogador_id = 1, tipo = "partida")

# Transferências do verão de 2023
transf <- ca_transferencias(temporada = 2023, janela = "verao")

# Estádios no Brasil
estadios_br <- ca_estadios(pais = "Brasil")


# 6. Exemplo de análise: Top 10 artilheiros do Brasileirão 2023 ------------

library(dplyr)
library(ggplot2)

stats <- ca_stats_jogadores(temporada = 2023)
jogadores <- ca_jogadores()

artilheiros <- stats %>%
  group_by(jogador_id) %>%
  summarise(gols = sum(gols, na.rm = TRUE)) %>%
  arrange(desc(gols)) %>%
  slice(1:10) %>%
  left_join(jogadores[, c("jogador_id", "nome", "time")], by = "jogador_id")

ggplot(artilheiros, aes(x = reorder(nome, gols), y = gols, fill = time)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Top 10 Artilheiros — Brasileirão 2023",
    subtitle = "Fonte: Campo Analítico | campoanalitico.com.br",
    x = NULL,
    y = "Gols"
  ) +
  theme_minimal(base_size = 13)


# 7. Exemplo: Estatísticas de times — xG e posse de bola ------------------

stats_times <- ca_stats_times(temporada = 2023)

ggplot(stats_times, aes(x = posse_bola_media, y = xg_media, label = time)) +
  geom_point(size = 3, color = "#1D9E75") +
  geom_text(vjust = -0.8, size = 3) +
  labs(
    title = "Posse de Bola vs xG Médio — Brasileirão 2023",
    subtitle = "Fonte: Campo Analítico | campoanalitico.com.br",
    x = "Posse de Bola Média (%)",
    y = "xG Médio por Partida"
  ) +
  theme_minimal()
