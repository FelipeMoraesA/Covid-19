# Covid-19
Repositório criado para assuntos relacionados à Covid-19.  
<br>
A estrutura básica das pastas do projeto é:
<br>
- "Code" -> para inclusão dos scripts;  
- "Input" -> para receber as entradas de dados;
- "Input/Raw" -> para os dados brutos;  
- "Input/Processed" -> para os dados processados;  
- "Output" -> para as saídas/resultados;  
<br>
  
## Script 1 - (JHU) Dados Diários Covid-19 - Importação e Tratamento
O script 1 foi desenvolvido para acessar, baixar, carregar e tratar — gerando um arquivo csv final — os dados diários sobre a Covid-19 disponibilizados pela Johns Hopkins University (JHU), em seu Center for Systems Science and Engineering (CSSE).  
A coleta dos dados foi encerrada pela JHU em março de 2023, e a série utilizada traz dados diários acumulados sobre casos e óbitos por Covid-19 em diversos países do mundo.  
<br>
No Script 1, seleciono os dados da China e dos EUA criando um único data.fame com os dados dos dois países. Além disso, calculo a quantidade de novos casos e óbitos diários para cada país, tendo em vista que os dados originais apresentam apenas o acumulado.  
Também é feito o tratamento das datas (que não estavam padronizadas).  
<br>
Produto Final: um csv com dados acumulados e novos dados diários para casos e óbitos por Covid-19 na China e nos EUA.
