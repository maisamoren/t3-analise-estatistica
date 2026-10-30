# Verificacao adicional dos testes reproduzidos em R.
# Execute APOS reproducao_T3_detalhada.R.

arquivo <- "resultados_T3_detalhados.csv"
if (!file.exists(arquivo)) {
  stop("Execute primeiro: source('reproducao_T3_detalhada.R')")
}
obtidos <- read.csv(arquivo, stringsAsFactors = FALSE)
referencia <- data.frame(
  variavel = c("norm_cfos_per_area", "norm_mean_intensity"),
  U = c(8, 3),
  p_mannwhitney = c(0.002880484669027, 0.0007028607191035),
  eta2 = c(0.4803508771929823, 0.6189473684210525)
)
comparacao <- merge(obtidos, referencia, by = "variavel", suffixes = c("_r", "_ref"))
if (nrow(comparacao) != 2L) stop("Nao foram encontradas as duas variaveis previstas.")
if (!all(comparacao$n_ctrl == 10 & comparacao$n_ext == 9)) {
  stop("Tamanho amostral diferente do esperado (Ctrl=10, Ext=9).")
}
for (col in c("U", "p_mannwhitney", "eta2")) {
  if (!all(abs(comparacao[[paste0(col, "_r")]] -
               comparacao[[paste0(col, "_ref")]]) < 1e-8)) {
    stop(paste("Divergencia em:", col))
  }
}
print(comparacao[, c("variavel", "U_r", "p_mannwhitney_r", "eta2_r")],
      row.names = FALSE, digits = 9)
cat("\nConferencia concluida: resultados compativeis com as referencias.\n")
