#' @title Campo Analítico — API de Dados de Futebol
#' @description Funções para acessar remotamente o banco de dados de futebol
#'   hospedado no GitHub do Campo Analítico. Todos os dados são carregados
#'   diretamente via URL raw do GitHub, sem necessidade de credenciais.
#' @author Campo Analítico <campoanalitico.com.br>

# URL base do repositório raw
.BASE_URL <- "https://raw.githubusercontent.com/campoanaliticoestudos/Banco-de-dados-futebol/main/data"

#' Listar datasets disponíveis
#'
#' Retorna um data frame com todos os datasets disponíveis no banco de dados.
#'
#' @return Um data frame com colunas: dataset, descricao, formato, atualizado_em
#' @export
#' @examples
#' catalogo <- ca_catalogo()
#' print(catalogo)
ca_catalogo <- function() {
  data.frame(
    dataset = c(
      "partidas",
      "jogadores",
      "times",
      "estatisticas_jogadores",
      "estatisticas_times",
      "transferencias",
      "estadios",
      "arbitros"
    ),
    descricao = c(
      "Resultados e informacoes de partidas",
      "Cadastro de jogadores",
      "Cadastro de times e clubes",
      "Estatisticas individuais por partida/temporada",
      "Estatisticas coletivas por partida/temporada",
      "Historico de transferencias de jogadores",
      "Informacoes de estadios",
      "Informacoes de arbitros"
    ),
    formato = rep("CSV", 8),
    stringsAsFactors = FALSE
  )
}

#' Carregar dataset remoto
#'
#' Funcao interna para baixar e carregar um arquivo CSV do repositorio.
#'
#' @param nome_arquivo Nome do arquivo CSV (com extensao)
#' @param ... Argumentos adicionais passados para read.csv()
#' @return Um data frame com os dados carregados
#' @keywords internal
.ca_carregar <- function(nome_arquivo, ...) {
  url <- paste0(.BASE_URL, "/", nome_arquivo)

  tryCatch({
    dados <- read.csv(url(url), encoding = "UTF-8", stringsAsFactors = FALSE, ...)
    message("[ OK ] ", nome_arquivo, " carregado: ", nrow(dados), " linhas x ", ncol(dados), " colunas")
    return(dados)
  }, error = function(e) {
    stop(
      "Erro ao carregar '", nome_arquivo, "'.\n",
      "Verifique sua conexao com a internet ou se o arquivo existe no repositorio.\n",
      "URL tentada: ", url, "\n",
      "Detalhe: ", e$message
    )
  })
}

#' Carregar partidas
#'
#' Carrega o dataset de partidas do repositorio remoto.
#'
#' @param competicao Filtrar por competicao (ex: "Brasileirao", "Copa do Brasil"). NULL para todas.
#' @param temporada Filtrar por temporada/ano (ex: 2023). NULL para todas.
#' @return Um data frame com os dados de partidas
#' @export
#' @examples
#' # Todas as partidas
#' partidas <- ca_partidas()
#'
#' # Apenas Brasileirao 2023
#' br2023 <- ca_partidas(competicao = "Brasileirao", temporada = 2023)
ca_partidas <- function(competicao = NULL, temporada = NULL) {
  dados <- .ca_carregar("partidas.csv")

  if (!is.null(competicao)) {
    dados <- dados[grepl(competicao, dados$competicao, ignore.case = TRUE), ]
  }
  if (!is.null(temporada)) {
    dados <- dados[dados$temporada == temporada, ]
  }

  return(dados)
}

#' Carregar jogadores
#'
#' Carrega o dataset de cadastro de jogadores.
#'
#' @param posicao Filtrar por posicao (ex: "Atacante", "Meia"). NULL para todos.
#' @param nacionalidade Filtrar por nacionalidade (ex: "Brasil"). NULL para todas.
#' @return Um data frame com os dados de jogadores
#' @export
#' @examples
#' # Todos os jogadores
#' jogadores <- ca_jogadores()
#'
#' # Apenas atacantes brasileiros
#' atacantes_br <- ca_jogadores(posicao = "Atacante", nacionalidade = "Brasil")
ca_jogadores <- function(posicao = NULL, nacionalidade = NULL) {
  dados <- .ca_carregar("jogadores.csv")

  if (!is.null(posicao)) {
    dados <- dados[grepl(posicao, dados$posicao, ignore.case = TRUE), ]
  }
  if (!is.null(nacionalidade)) {
    dados <- dados[grepl(nacionalidade, dados$nacionalidade, ignore.case = TRUE), ]
  }

  return(dados)
}

#' Carregar times
#'
#' Carrega o dataset de times e clubes.
#'
#' @param pais Filtrar por pais (ex: "Brasil"). NULL para todos.
#' @return Um data frame com os dados de times
#' @export
#' @examples
#' times <- ca_times()
#' times_br <- ca_times(pais = "Brasil")
ca_times <- function(pais = NULL) {
  dados <- .ca_carregar("times.csv")

  if (!is.null(pais)) {
    dados <- dados[grepl(pais, dados$pais, ignore.case = TRUE), ]
  }

  return(dados)
}

#' Carregar estatisticas de jogadores
#'
#' Carrega o dataset de estatisticas individuais por partida ou temporada.
#'
#' @param jogador_id ID do jogador para filtrar. NULL para todos.
#' @param temporada Filtrar por temporada/ano (ex: 2023). NULL para todas.
#' @param tipo Tipo de estatistica: "partida" ou "temporada". Default: "temporada".
#' @return Um data frame com as estatisticas de jogadores
#' @export
#' @examples
#' # Estatisticas de todos os jogadores na temporada 2023
#' stats <- ca_stats_jogadores(temporada = 2023)
#'
#' # Estatisticas por partida de um jogador especifico
#' stats_id <- ca_stats_jogadores(jogador_id = 42, tipo = "partida")
ca_stats_jogadores <- function(jogador_id = NULL, temporada = NULL, tipo = "temporada") {
  arquivo <- if (tipo == "partida") "estatisticas_jogadores_partida.csv" else "estatisticas_jogadores.csv"
  dados <- .ca_carregar(arquivo)

  if (!is.null(jogador_id)) {
    dados <- dados[dados$jogador_id == jogador_id, ]
  }
  if (!is.null(temporada)) {
    dados <- dados[dados$temporada == temporada, ]
  }

  return(dados)
}

#' Carregar estatisticas de times
#'
#' Carrega o dataset de estatisticas coletivas por partida ou temporada.
#'
#' @param time_id ID do time para filtrar. NULL para todos.
#' @param temporada Filtrar por temporada/ano. NULL para todas.
#' @param tipo Tipo de estatistica: "partida" ou "temporada". Default: "temporada".
#' @return Um data frame com as estatisticas de times
#' @export
#' @examples
#' stats_times <- ca_stats_times(temporada = 2023)
ca_stats_times <- function(time_id = NULL, temporada = NULL, tipo = "temporada") {
  arquivo <- if (tipo == "partida") "estatisticas_times_partida.csv" else "estatisticas_times.csv"
  dados <- .ca_carregar(arquivo)

  if (!is.null(time_id)) {
    dados <- dados[dados$time_id == time_id, ]
  }
  if (!is.null(temporada)) {
    dados <- dados[dados$temporada == temporada, ]
  }

  return(dados)
}

#' Carregar transferencias
#'
#' Carrega o historico de transferencias de jogadores.
#'
#' @param temporada Filtrar por temporada/ano. NULL para todas.
#' @param janela Filtrar por janela de transferencia: "verao", "inverno" ou NULL para todas.
#' @return Um data frame com o historico de transferencias
#' @export
#' @examples
#' transferencias <- ca_transferencias(temporada = 2023)
ca_transferencias <- function(temporada = NULL, janela = NULL) {
  dados <- .ca_carregar("transferencias.csv")

  if (!is.null(temporada)) {
    dados <- dados[dados$temporada == temporada, ]
  }
  if (!is.null(janela)) {
    dados <- dados[grepl(janela, dados$janela, ignore.case = TRUE), ]
  }

  return(dados)
}

#' Carregar estadios
#'
#' Carrega o dataset com informacoes dos estadios.
#'
#' @param pais Filtrar por pais. NULL para todos.
#' @return Um data frame com os dados dos estadios
#' @export
#' @examples
#' estadios <- ca_estadios()
#' estadios_br <- ca_estadios(pais = "Brasil")
ca_estadios <- function(pais = NULL) {
  dados <- .ca_carregar("estadios.csv")

  if (!is.null(pais)) {
    dados <- dados[grepl(pais, dados$pais, ignore.case = TRUE), ]
  }

  return(dados)
}

#' Verificar conectividade com o repositorio
#'
#' Testa se o repositorio remoto esta acessivel.
#'
#' @return TRUE se acessivel, FALSE caso contrario
#' @export
#' @examples
#' ca_ping()
ca_ping <- function() {
  url_teste <- paste0(.BASE_URL, "/partidas.csv")

  resultado <- tryCatch({
    con <- url(url_teste)
    open(con)
    close(con)
    TRUE
  }, error = function(e) FALSE)

  if (resultado) {
    message("[ OK ] Repositorio acessivel em: ", .BASE_URL)
  } else {
    message("[ ERRO ] Nao foi possivel conectar ao repositorio. Verifique sua internet.")
  }

  invisible(resultado)
}

#' Versao e informacoes do pacote
#'
#' Exibe informacoes sobre o pacote e o repositorio de dados.
#'
#' @export
#' @examples
#' ca_info()
ca_info <- function() {
  cat("======================================\n")
  cat(" Campo Analitico — Banco de Dados\n")
  cat("======================================\n")
  cat(" Repositorio: github.com/campoanaliticoestudos/Banco-de-dados-futebol\n")
  cat(" URL dos dados:", .BASE_URL, "\n")
  cat(" Site: campoanalitico.com.br\n")
  cat(" Suporte: @analiticocampo\n")
  cat("--------------------------------------\n")
  cat(" Datasets disponiveis:\n")
  cat(paste0("  - ", ca_catalogo()$dataset, ": ", ca_catalogo()$descricao, "\n"), sep = "")
  cat("======================================\n")
}
