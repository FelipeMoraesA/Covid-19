
#####################################################################################
### Script para Importa��o e Tratamento dos dados di�rios sobre a Covid-19 (JHU) ####
### Pa�ses Selecionados: China E Estados Unidos da Am�rica                       ####
### Autor: Felipe Moraes                                                         ####
#####################################################################################

# Pacotes utilizados:
library(tidyverse)
library(stringr)
library(esquisse)

######################################### Parte 1: Download e Carregamento dos dados ########################################### 

# Neste projeto usaremos os dados fornecidos pela 'Johns Hopkins Coronavirus Resource Center'.
# Dado o arrefecimento da crise pand�mica, a coleta de dados foi interrompida em mar�o de 2023.

# Os dados s�o disponibilizados pela universidade em um resposit�rio GitHub, nos seguintes links:

# Cria os links
link.casos <- 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'
link.obitos <- 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv'

# Faz download dos dados para uma pasta pr�pria (Pasta Raw, dentro da pasta Input), lembre-se de cri�-la:
setwd('../Input/Raw/')

download.file(link.casos, str_c('raw.casos.csv'))
download.file(link.obitos, str_c('raw.obitos.csv'))

# Carregamento dos dados:
raw.casos <- read.csv('raw.casos.csv')
raw.obitos <- read.csv('raw.obitos.csv')


####################################### Parte 2: Tratamento e Limpeza dos Dados ###########################################

# China: 
# Os dados da China est�o separados por regi�o, por isso precisam ser agregados para n�vel nacional:

# Separar todos os dados que possuem a Country.Region = China em novas vari�veis: 
China.Casos <- raw.casos[raw.casos$Country.Region=='China',]
China.Obitos <- raw.obitos[raw.obitos$Country.Region=='China',]

# Para realizar a soma de cada coluna precisaremos remover as colunas de texto:
China.Casos <- China.Casos[,-c(1,2,3,4)]
China.Obitos <- China.Obitos[,-c(1,2,3,4)]

# Soma os valores observados em cada coluna:
China.Casos <- colSums(China.Casos)
China.Obitos <- colSums(China.Obitos)

# Combinar as duas vari�veis (casos e �bitos) em um dataframe principal (Dados):
Dados <- as.data.frame(cbind(China.Casos, China.Obitos)) 


# Estados Unidos da Am�rica
## Os dados para os EUA ja est�o agregados em n�vel nacional. 

# Criar duas novas vari�veis para EUA (casos e obitos): 
USA.Casos <- raw.casos[raw.casos$Country.Region=='US',] %>% as.data.frame()
USA.Obitos <- raw.obitos[raw.obitos$Country.Region=='US',] %>% as.data.frame()

# Remo��o das colunas de texto:
USA.Casos <- USA.Casos[,-c(1,2,3,4)]
USA.Obitos <- USA.Obitos[,-c(1,2,3,4)]

# Transpor o dataframe:
USA.Casos <- as.data.frame(t(USA.Casos))
USA.Obitos <- as.data.frame(t(USA.Obitos))

# Renomear as colunas:
USA.Casos <- rename(USA.Casos, USA.Casos='261')
USA.Obitos <- rename(USA.Obitos, USA.Obitos='261')

# Agreg��o dos objetos com a dataframe princial criado para a China:
Dados <- as.data.frame(cbind(Dados, USA.Casos, USA.Obitos))

# Remo��o das vari�veis desnecess�rias:
rm(China.Casos, China.Obitos, link.casos, link.obitos, raw.casos, raw.obitos, USA.Casos, USA.Obitos)


# Tratamentos das datas:
# Cria��o da coluna de data:
Dados <- mutate(Dados, Data=rownames(Dados))

# Removendo o t�tulo das linhas:
rownames(Dados) <- NULL 

# Remove o X antes da data:
Dados$Data <- gsub("X", "", Dados$Data)

# L� a coluna 'Data' como data:
Dados$Data <- as.Date(Dados$Data, format = "%m.%d.%y")

# Cria colunas de 'Ano', 'M�s' e 'Dia':
Dados <-  mutate(Dados, Ano = format(Data, "%Y"),
                 M�s = format(Data, "%m"),
                 Dia = format(Data, "%d"))

# A informa��o � apresentada de maneira acumulada, isto �, o total de casos at� determinada data.  
# Para entender a movimenta��o do v�rus, vamos criar colunas que mostrar quantos novos casos e obitos s�o registrados em cada dia:
Dados$China.Novos.Casos <- c(Dados$China.Casos[1], diff(Dados$China.Casos))
Dados$China.Novos.Obitos <- c(Dados$China.Obitos[1], diff(Dados$China.Obitos))
Dados$USA.Novos.Casos <- c(Dados$USA.Casos[1], diff(Dados$USA.Casos))
Dados$USA.Novos.Obitos <- c(Dados$USA.Obitos[1], diff(Dados$USA.Obitos))

# Reordenando colunas:
Dados <- select(Dados, Data, China.Casos, USA.Casos, China.Obitos, USA.Obitos, 
                China.Novos.Casos, USA.Novos.Casos, China.Novos.Obitos, USA.Novos.Obitos,
                everything())

# Cria��o do CSV(separado por ;) com os dados Tratados, (na pasta Processed, dentro de Input):
write.csv2(Dados, "../Processed/Dados_Tratados_CNxUS.csv", row.names = FALSE)
