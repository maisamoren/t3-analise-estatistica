# Obtem os dados originais diretamente do material suplementar da eLife.
# Fonte: Segebarth et al. (2020), Figure 5 - Source data 1
# https://elifesciences.org/articles/59780/figures
# O arquivo ZIP nao e incluido neste repositorio.
# Execute com o diretorio de trabalho definido para a pasta do repositorio.

obter_dados <- function() {
  url <- "https://cdn.elifesciences.org/articles/59780/elife-59780-fig5-data1-v2.zip"
  nomes <- c("quantifications_inns1.csv",
             "stat_results_quantifications_inns1.csv",
             "readme_figure_5_source_data1.txt")
  if (all(file.exists(nomes))) {
    message("Os arquivos de origem ja estao nesta pasta. Download dispensado.")
    return(invisible(nomes))
  }

  arquivo_zip <- tempfile(fileext = ".zip")
  pasta_temp <- tempfile(pattern = "eLife_Figura5_")
  dir.create(pasta_temp)
  on.exit(unlink(arquivo_zip), add = TRUE)
  on.exit(unlink(pasta_temp, recursive = TRUE), add = TRUE)

  message("Baixando os dados suplementares da eLife...")
  utils::download.file(url, destfile = arquivo_zip, mode = "wb", quiet = FALSE)

  caminhos <- file.path("Figure5_Source_data1", nomes)
  conteudo <- utils::unzip(arquivo_zip, list = TRUE)$Name
  if (!all(caminhos %in% conteudo)) {
    stop("O ZIP recebido nao contem os tres arquivos esperados. Confira a fonte.")
  }
  utils::unzip(arquivo_zip, files = caminhos, exdir = pasta_temp)

  for (i in seq_along(nomes)) {
    origem <- file.path(pasta_temp, caminhos[i])
    if (!file.copy(origem, nomes[i], overwrite = TRUE)) {
      stop(paste("Nao foi possivel copiar:", nomes[i]))
    }
  }
  message("Dados obtidos: ", paste(nomes, collapse = ", "))
  invisible(nomes)
}

obter_dados()
