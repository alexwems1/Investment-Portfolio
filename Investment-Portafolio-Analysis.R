#Portafolio de inversion
library(tidyquant)
library(timetk)
library(dplyr)
library(ggplot2)
acciones = c("TSLA","AAPL","AMZN","NFLX","GOOG")
weights = c(0.25,0.25,0.20,0.15,0.15)
#Segundo 
datos<- acciones %>% tq_get(get = "stock.prices")
Retorno_Individual <- datos %>%
  group_by(symbol) %>%
  tq_transmute( mutate_fun = periodReturn,
               select = adjusted, period = "daily", col_rename = "Ret")
agrupacion <- tibble(symbol = acciones, wts = weights)
ret_data <- left_join(Retorno_Individual , agrupacion, by = 'symbol')
ret_porc <- ret_data %>% mutate(retornopp = wts * Ret)
port_ret <- ret_porc %>% group_by(date) %>% summarise(port_ret = sum(retornopp))
port_cumulative_ret <- port_ret %>% mutate(cr= cumprod(1 + port_ret))
port_cumulative_ret %>%
  ggplot(aes(x = date, y = cr)) +
  geom_line() +
  labs(x = 'Date',
       y = 'Cumulative Returns',
       title = 'Portfolio Cumulative Returns') +
  theme_classic() +
  scale_y_continuous(breaks = seq(1,2,0.1)) +
  scale_x_date(date_breaks = 'year',
               date_labels = '%Y')
#Probrema_3
Por_anual <- port_cumulative_ret %>% 
  tq_performance(Ra = port_ret,
                 performance_fun = Return.annualized)
cat("The average annual portfolio returns is ", round((Por_anual[[1]] * 100),2),"%", sep = "")
vola_d <- sd(port_cumulative_ret$port_ret)                    
cat("The daily portfolio volatility is", round((vola_d),4))
vola_a <- vola_d *sqrt(252)
SR <- Por_anual$AnnualizedReturn / vola_a
SRA <- port_cumulative_ret %>% tq_performance(Ra = port_ret, performance_fun = SharpeRatio.annualized) %>% .[[1]]
cat("The annual portfolio sharpe ratio calculated using the tq_performance function is", round((SRA),4))

