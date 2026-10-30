# T3 - reproducao detalhada de duas comparacoes da Figura 5 - suplemento 1C
# Base: Segebarth et al. (2020), Figure 5 - Source data 1, Lab-Inns1
# Coloque quantifications_inns1.csv na mesma pasta e execute source('reproducao_T3_detalhada.R')
# Dependencias: apenas funcoes do R base

arquivo <- 'quantifications_inns1.csv'
stopifnot(file.exists(arquivo))
brutos <- read.csv(arquivo, stringsAsFactors = FALSE, check.names = FALSE)
cat('Registros no arquivo completo:', nrow(brutos), '\n')

# 1) Recorte previamente especificado - um modelo e uma regiao
recorte20 <- subset(brutos,
  ens == 'consensus1' &
  unet == 'mue_consensus1_1.0009.h5' &
  model == 'model1' & init == 'fine-tuned' & Area == 'BLA'
)
print(table(recorte20$Kondition))
stopifnot(nrow(recorte20) == 20L)

# 2) Conciliacao documentada com os n divulgados (10 Ctrl / 9 Ext)
# O README NAO explica a exclusao. Ela foi inferida ao reconstruir os resultados.
recorte <- subset(recorte20, Nummer != 1080)
stopifnot(nrow(recorte) == 19L,
          sum(recorte$Kondition == 'Ctrl') == 10L,
          sum(recorte$Kondition == 'Ext') == 9L,
          !anyDuplicated(recorte$Nummer))
vars <- c('norm_cfos_per_area','norm_mean_intensity')
stopifnot(all(is.finite(as.matrix(recorte[,vars]))))
write.csv(recorte[,c('Nummer','Kondition',vars)],
          'dados_filtrados_T3.csv',row.names = FALSE)

# 3) Levene pela variacao absoluta em torno da mediana (Brown-Forsythe)
levene_mediana_p <- function(valores, grupo) {
  grupo <- factor(grupo, levels = c('Ctrl','Ext'))
  desvio <- abs(valores - ave(valores, grupo, FUN = median))
  summary(aov(desvio ~ grupo))[[1]][['Pr(>F)']][1]
}

# 4) Analise de cada variavel, com o mesmo metodo aproximado do arquivo de autores
avaliar <- function(nome) {
  x <- recorte[recorte$Kondition == 'Ctrl', nome]
  y <- recorte[recorte$Kondition == 'Ext', nome]
  swx <- shapiro.test(x); swy <- shapiro.test(y)
  mw <- wilcox.test(x, y, alternative = 'two.sided', exact = FALSE, correct = TRUE)
  U <- unname(mw$statistic) # No R, a estatistica W aqui equivale a U do 1o grupo
  n1 <- length(x); n2 <- length(y)
  mediaU <- n1*n2/2
  dpU <- sqrt(n1*n2*(n1+n2+1)/12)
  ZsemCorrecao <- (U-mediaU)/dpU
  eta2 <- ZsemCorrecao^2/(n1+n2) # Formula explicitada pelos autores
  pLevene <- levene_mediana_p(c(x,y),c(rep('Ctrl',n1),rep('Ext',n2)))
  data.frame(variavel=nome, n_ctrl=n1, n_ext=n2,
   media_ctrl=mean(x), media_ext=mean(y),
   mediana_ctrl=median(x), mediana_ext=median(y),
   dp_ctrl=sd(x), dp_ext=sd(y),
   shapiroW_ctrl=unname(swx$statistic), shapiroP_ctrl=swx$p.value,
   shapiroW_ext=unname(swy$statistic), shapiroP_ext=swy$p.value,
   leveneP=pLevene, U=U, p_mannwhitney=mw$p.value, eta2=eta2)
}
resultados <- do.call(rbind,lapply(vars,avaliar))
write.csv(resultados,'resultados_T3_detalhados.csv',row.names=FALSE)
print(resultados, digits=9, row.names=FALSE)

# 5) Analise de sensibilidade: incluir imagem Nummer 1080 (sem a exclusao)
cat('\nSENSIBILIDADE A OBSERVACAO 1080\n')
for (v in vars) {
  a <- recorte20[recorte20$Kondition == 'Ctrl',v]
  b <- recorte20[recorte20$Kondition == 'Ext',v]
  teste <- wilcox.test(a,b,exact=FALSE,correct=TRUE,alternative='two.sided')
  cat(v,'- U=',unname(teste$statistic),'p=',format(teste$p.value,digits=8),'\n')
}

# 6) Graficos para conferencia
pdf('graficos_T3_R.pdf',width=9,height=5)
par(mfrow=c(1,2),mar=c(4,4,3,1))
for (v in vars) boxplot(recorte[[v]] ~ recorte$Kondition,
                        main=v, xlab='Condicao',ylab='Valor normalizado')
dev.off()
cat('\nArquivos gerados: dados_filtrados_T3.csv, resultados_T3_detalhados.csv, graficos_T3_R.pdf\n')
