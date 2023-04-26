
#####################################################################################
### Script para Importação e Tratamento dos dados diários sobre a Covid-19 (JHU) ####
### Países Selecionados: China E Estados Unidos da América                       ####
### Autor: Felipe Moraes                                                         ####
#####################################################################################

# Pacotes utilizados:
library(tidyverse)
library(stringr)
library(esquisse)

######################################### Parte 1: Download e Carregamento dos dados ########################################### 

# Neste projeto usaremos os dados fornecidos pela 'Johns Hopkins Coronavirus Resource Center'.
# Dado o arrefecimento da crise pandêmica, a coleta de dados foi interrompida em março de 2023.

# Os dados são disponibilizados pela universidade em um respositório GitHub, nos seguintes links:

# Cria os links
link.casos <- 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'
link.obitos <- 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv'

# Faz download dos dados para uma pasta própria (Pasta Raw, dentro da pasta Input), lembre-se de criá-la:
setwd('../Input/Raw/')

download.file(link.casos, str_c('raw.casos.csv'))
download.file(link.obitos, str_c('raw.obitos.csv'))

# Carregamento dos dados:
raw.casos <- read.csv('raw.casos.csv')
raw.obitos <- read.csv('raw.obitos.csv')


####################################### Parte 2: Tratamento e Limpeza dos Dados ###########################################

# China: 
# Os dados da China estão separados por região, por isso precisam ser agregados para nível nacional:

# Separar todos os dados que possuem a Country.Region = China em novas variáveis: 
China.Casos <- raw.casos[raw.casos$Country.Region=='China',]
China.Obitos <- raw.obitos[raw.obitos$Country.Region=='China',]

# Para realizar a soma de cada coluna precisaremos remover as colunas de texto:
China.Casos <- China.Casos[,-c(1,2,3,4)]
China.Obitos <- China.Obitos[,-c(1,2,3,4)]

# Soma os valores observados em cada coluna:
China.Casos <- colSums(China.Casos)
China.Obitos <- colSums(China.Obitos)

# Combinar as duas variáveis (casos e óbitos) em um dataframe principal (Dados):
Dados <- as.data.frame(cbind(China.Casos, China.Obitos)) 


# Estados Unidos da América
## Os dados para os EUA ja estão agregados em nível nacional. 

# Criar novos dois novas variáveis (casos e obitos): 
USA.Casos <- raw.casos[raw.casos$Country.Region=='US',] %>% as.data.frame()
USA.Obitos <- raw.obitos[raw.obitos$Country.Region=='US',] %>% as.data.frame()

# Remocao das colunas de texto:
USA.Casos <- USA.Casos[,-c(1,2,3,4)]
USA.Obitos <- USA.Obitos[,-c(1,2,3,4)]

# Transpor o dataframe:
USA.Casos <- as.data.frame(t(USA.Casos))
USA.Obitos <- as.data.frame(t(USA.Obitos))

# Renomear as colunas:
USA.Casos <- rename(USA.Casos, USA.Casos='261')
USA.Obitos <- rename(USA.Obitos, USA.Obitos='261')

# Agregção dos objetos com a dataframe princial criado para a China:
Dados <- as.data.frame(cbind(Dados, USA.Casos, USA.Obitos))

# Remoção das variáveis desnecessárias:
rm(China.Casos, China.Obitos, link.casos, link.obitos, raw.casos, raw.obitos, USA.Casos, USA.Obitos)


# Tratamentos das datas:
# Criação da coluna de data:
Dados <- mutate(Dados, Data=rownames(Dados))

# Removendo o título das linhas:
rownames(Dados) <- NULL 

# Remove o X antes da data:
Dados$Data <- gsub("X", "", Dados$Data)

# Lê a coluna 'Data' como data:
Dados$Data <- as.Date(Dados$Data, format = "%m.%d.%y")

# Cria colunas de 'Ano', 'Mês' e 'Dia':
Dados <-  mutate(Dados, Ano = format(Data, "%Y"),
                 Mês = format(Data, "%m"),
                 Dia = format(Data, "%d"))

# A informação é apresentada de maneira acumulada, isto é, o total de casos até determinada data.  
# Para entender a movimentação do vírus, vamos criar colunas que mostrar quantos novos casos e obitos são registrados em cada dia:
Dados$China.Novos.Casos <- c(Dados$China.Casos[1], diff(Dados$China.Casos))
Dados$China.Novos.Obitos <- c(Dados$China.Obitos[1], diff(Dados$China.Obitos))
Dados$USA.Novos.Casos <- c(Dados$USA.Casos[1], diff(Dados$USA.Casos))
Dados$USA.Novos.Obitos <- c(Dados$USA.Obitos[1], diff(Dados$USA.Obitos))

# Reordenando colunas:
Dados <- select(Dados, Data, China.Casos, USA.Casos, China.Obitos, USA.Obitos, 
                China.Novos.Casos, USA.Novos.Casos, China.Novos.Obitos, USA.Novos.Obitos,
                everything())

# Criação do CSV(separado por ;) com os dados Tratados, (na pasta Processed, dentro de Input):
write.csv2(Dados, "../Processed/Dados_Tratados_CNxUS.csv", row.names = FALSE)
