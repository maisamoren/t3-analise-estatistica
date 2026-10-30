# Reprodução de análises estatísticas em imagens biomédicas

Repositório com o código utilizado para reproduzir duas comparações estatísticas
publicadas por **Segebarth et al. (2020)**, com dados quantitativos de imagens de
microscopia do conjunto **Lab-Inns1** (*Figure 5 — Source Data 1*).

A análise é parte de um trabalho acadêmico sobre **processamento de imagens
biomédicas**. O objetivo do repositório é documentar a origem dos dados,
os critérios de seleção e os procedimentos necessários para reproduzir os testes.

> **Escopo:** esta reprodução compara as condições biológicas controle (`Ctrl`)
> e extinção (`Ext`).

## Artigo e origem dos dados

- **Artigo:** Segebarth, D. et al. (2020). *On the objectivity, reliability,
  and validity of deep learning enabled bioimage analyses*. eLife 9:e59780.
  DOI: <https://doi.org/10.7554/eLife.59780>.
- **Dados suplementares:** [Figure 5 — Source Data 1, eLife](https://elifesciences.org/articles/59780/figures).
- **Download original dos dados:** <https://cdn.elifesciences.org/articles/59780/elife-59780-fig5-data1-v2.zip>.

Os arquivos CSV de entrada **não foram republicados neste repositório**.
O script `baixar_dados.R` faz o download do material suplementar no endereço
original e extrai somente os três arquivos necessários à análise de `Lab-Inns1`.
A disponibilidade do download depende da manutenção desses endereços pela eLife.

## Conteúdo do repositório

```text
t3-analise-estatistica-bioimagens/
├── resultados_exemplo/
│   └── resultados_T3_detalhados.csv
├── README.md
├── baixar_dados.R
├── conferir_resultados.R
├── reproducao_T3_detalhada.R
└── .gitignore
```

- `reproducao_T3_detalhada.R`: código **preservado do pacote usado no RStudio**,
  com seleção dos dados, estatística descritiva, Shapiro–Wilk, teste de Levene
  centrado na mediana (Brown–Forsythe), Mann–Whitney U e análise de sensibilidade.
- `baixar_dados.R`: obtém os CSV oficiais, sem exigir cópia manual dos dados.
- `conferir_resultados.R`: confere os valores de U, *p* e η² reproduzidos.
- `resultados_exemplo/resultados_T3_detalhados.csv`: saída previamente
  calculada e conferida, disponibilizada **apenas como exemplo de referência**.
- `.gitignore`: impede a inclusão acidental dos dados de origem e dos arquivos
  temporários gerados na execução.

## Como executar no Windows (RStudio)

**Requisitos:** R e RStudio instalados; conexão à internet para a etapa de download.
O código usa somente recursos da instalação padrão do R (*R base*).

1. Baixe este repositório em **Code → Download ZIP** no GitHub e extraia
   o ZIP em uma pasta do Windows. Abra o RStudio.
2. No RStudio, escolha **File → Open File** e abra `reproducao_T3_detalhada.R`.
3. Selecione **Session → Set Working Directory → To Source File Location**.
   Isso define a pasta do repositório como diretório de trabalho.
4. Cole, **um comando por vez**, no Console e pressione **Enter**:

   ```r
   source("baixar_dados.R")
   source("reproducao_T3_detalhada.R")
   source("conferir_resultados.R")
   ```

5. Ao final, o Console deverá informar que os arquivos de resultados foram
   gerados e que a conferência foi concluída.

Se o download automático falhar, obtenha manualmente o ZIP na página da eLife.
Extraia `quantifications_inns1.csv` da pasta `Figure5_Source_data1` para a pasta
raiz do repositório e execute diretamente `source("reproducao_T3_detalhada.R")`.

### Saídas produzidas

O script principal cria, na pasta do repositório:

- `dados_filtrados_T3.csv`: 19 observações da análise principal;
- `resultados_T3_detalhados.csv`: estatísticas descritivas e resultados dos testes;
- `graficos_T3_R.pdf`: gráficos comparativos das duas variáveis.

Os arquivos recém-gerados são locais e são ignorados pelo Git para manter
o repositório limpo. O exemplo de resultados permanece em `resultados_exemplo/`.

## Recorte analisado

O CSV original contém 700 registros associados a diferentes configurações
de análise computacional. Foi utilizado o seguinte recorte:

| Coluna | Valor selecionado |
|---|---|
| `ens` | `consensus1` |
| `unet` | `mue_consensus1_1.0009.h5` |
| `model` | `model1` |
| `init` | `fine-tuned` |
| `Area` | `BLA` |

O recorte retorna **20 imagens** (10 `Ctrl` e 10 `Ext`). Para reconstruir os
resultados apresentados no arquivo estatístico suplementar, a análise principal
utiliza **19 imagens** (10 `Ctrl` e 9 `Ext`), após retirar a imagem identificada
por `Nummer = 1080` do grupo `Ext`.

**Importante:** a retirada dessa imagem foi **inferida na reconstrução** por
correspondência com os resultados publicados. O README do suplemento não
confirma um motivo específico para excluir a imagem `1080`. Por isso, o script
também apresenta uma **análise de sensibilidade** incluindo a imagem excluída.

As medidas avaliadas são `norm_cfos_per_area` (densidade normalizada de
estruturas positivas para cFOS por área) e `norm_mean_intensity` (intensidade
média normalizada do sinal de fluorescência).

## Resultados da reprodução principal

| Medida | `n_Ctrl` | `n_Ext` | U de Mann–Whitney | Valor de *p* |
|---|---:|---:|---:|---:|
| Densidade normalizada de cFOS | 10 | 9 | 8 | 0,0028805 |
| Intensidade média normalizada | 10 | 9 | 3 | 0,0007029 |

Os testes foram realizados no R usando `wilcox.test(..., exact = FALSE,
correct = TRUE)` (aproximação normal com correção de continuidade).

**Limitação de interpretação:** os valores acima se referem às imagens
analisadas. Como mais de uma imagem pode ter origem no mesmo camundongo,
**19 imagens não correspondem a 19 réplicas biológicas independentes**.
Esse aspecto deve ser considerado ao interpretar a inferência estatística.

## Como citar

O artigo científico original e seus dados devem ser citados separadamente
deste repositório. A fonte dos dados é a publicação de Segebarth et al. (2020)
indicada acima; os scripts de reprodução são um material computacional associado
ao trabalho acadêmico.

Depois de publicar o repositório, acrescente seu endereço definitivo ao
relatório, por exemplo:

> Os scripts utilizados para a preparação dos dados e a reprodução dos testes
> estatísticos estão disponíveis em repositório público no GitHub
> (URL do repositório). Os dados de entrada foram obtidos do material suplementar
> *Figure 5 — Source Data 1* de Segebarth et al. (2020).

Para criar a referência BibTeX do repositório, veja `COMO_CITAR.md`.

## Observações

O repositório disponibiliza o **código da reprodução**, não o código original
utilizado pelos autores para desenvolver seus modelos de aprendizado profundo.
O artigo e seu material suplementar mantêm seus próprios créditos e condições
de reutilização. Nenhuma licença para este repositório foi atribuída
automaticamente; caso queira permitir reutilização, escolha uma licença
explicitamente antes da publicação.
