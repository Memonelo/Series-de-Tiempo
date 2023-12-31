
## Trabajo Emp�rico 2
## Guillermo Xicoht�ncatl Reza
## 16/07/2022



## Direcci�n
## setwd("d:/Users/guillermo_reza/Desktop/Maestr�a/Verano 2022/Macroeconometr�a Aplicada/Emp�rico 2")


## Librer�as
library(stats)
library(forecast)
library(urca)
library(tidyverse)
library(stargazer)
library(astsa)




## Lectura del Tipo de Cambio

tipo_cambio_serie <- read.csv("cambio.csv")

class(tipo_cambio_serie) ## Data Frame



## Se define la base de datos como una serie de tiempo


######### P A R T E _ 1 ######### 


##### a) Serie de Aproximaci�n de Rendimientos

yt <- ts(tipo_cambio_serie$et, start = c(2010,1),
                  end = c(2018,12), frequency = 12) %>% log(.) %>% diff(lag=1)



##### b) Gr�fica del Tipo de Cambio y tama�o de muestra


## Gr�fica
plot(yt, type="l", col="red")
title(main = "Tipo de Cambio", sub = "Serie diferenciada",
      ylab = "logaritmo E_t")



## Tama�o de muestra

observaciones <- length(yt)






##### c) Cuadro de Estad�sticos Descriptivos


## An�lisis descriptivo de datos

summary(yt)

## Datos
tipo_cambio <- c("valor")
Datos <- class(yt)
Frecuencia <- frequency(yt)
Inicio <- start(yt)
Final <- end(yt)
Min <- -0.066058
Max <- 0.065760
Prom <- 0.004209


## Construcci�n de la tabla
tabla_1 <- rbind(tipo_cambio,Datos,Frecuencia,
                 Inicio,Final,Min,Max,Prom,observaciones)

stargazer(tabla_1, type = "text", title = "Estad�sticas Descriptivas")




##### d) Descomposici�n Aditiva de 3 elementos: Estacionalidad, Tendencia y 
#####    Componente Aleatorio



##### Descomposici�n Aditiva

## Descomposici�n de la serie de forma ADITIVA
des_ad_yt <- decompose(yt, "additive")


## Gr�fica de la tendencia de la serie estacional descompuesta de forma ADITIVA 
plot(as.ts(des_ad_yt$trend))
title(main = "Tipo de Cambio", sub = "Componente: Tendencia")


## Gr�fica de la estacionalidad de la serie estacional descompuesta de forma ADITIVA
plot(as.ts(des_ad_yt$seasonal))
title(main = "Tipo de Cambio", sub = "Componente: Estacionalidad")


## Gr�fica de la aleatoriedad de la serie estacional descompuesta de forma ADITIVA
plot(as.ts(des_ad_yt$random))
title(main = "Tipo de Cambio", sub = "Componente: Aleatorio")




##### Descomposici�n a mano

#### TENDENCIA
## ATAJO desapib22 <- decompose(yt, "additive")
## ATAJO plot(desapib22)


## Se define una serie consecutiva del tama�o de yt
t<-c(1:length(yt))


## T�rmino LINEAL

## Se pone el vector como regresor de la serie no estacionalizada
modelo_1 <- lm(yt~t)
summary(modelo_1)


## Se define una nueva serie con los valores ajustados de la regresi�n
yt_fit_1<-modelo_1$fitted.values


## La nueva serie con los valores ajustados se define como una serie de tiempo
yt_fit_1<-ts(yt_fit_1,start=c(2010, 1), end=c(2018, 12), frequency=12)


## Gr�fica del t�rmino LINEAL ajustado a la serie con tendencia.
plot(yt,type="l",col="blue")
lines(yt_fit_1,type="l",col="red")





## T�rmino CUADR�TICO

modelo_2<-lm(yt~t+I(t^2))
summary(modelo_2)

yt_fit_2<-modelo_2$fitted.values
yt_fit_2<-ts(yt_fit_2,start=c(2010, 1), end=c(2018, 12), frequency=12)

## Gr�fica del t�rmino CUADR�TICA ajustado a la serie con tendencia.
plot(yt,type="l",col="blue")
lines(yt_fit_2,type="l",col="red")




## T�rmino C�BICOS

modelo_3<-lm(yt~t+I(t^2)+I(t^3))
summary(modelo_3)
yt_fit_3<-modelo_3$fitted.values
yt_fit_3<-ts(yt_fit_3,start=c(2010, 1), end=c(2018, 12), frequency=12)

## Gr�fica del t�rmino C�BICO ajustado a la serie con tendencia.
plot(yt,type="l",col="blue")
lines(yt_fit_3,type="l",col="red")



### Para determinar cu�l es el mejor modelo se utilizan los CRITERIOS DE INFORMACI�N AIC & BIC

## AIC

(c(AIC(modelo_1),AIC(modelo_2),AIC(modelo_3)))


## BIC

(c(BIC(modelo_1),BIC(modelo_2),BIC(modelo_3)))


## Como el menor valor tanto para el criterio AIC como para el BIC 
## es el modelo 3, se concluye que el mejor modelo es el C�BICO.


## Se define el modelo ganador (Modelo C�bico)

ytt<-yt_fit_3

## Se resta con respecto a la serie con tendencia original

yt_tendencia <- yt-ytt

## El resultado es el componente aleatorio.

## Ahora se define como serie de tiempo la serie resultante de la resta.

yt_tendencia <- ts(yt_tendencia,start=c(2010,1),end=c(2018,12),frequency=12)


## Gr�fica sin tendencia

plot(yt_tendencia,type="l",col="brown")








#### Estacionalidad

## Se define el componente estacional de la serie, con el paquete forecast

yt_stl<- stl(yt,"periodic")


## Se crea otra serie con el componente estacional,
## pero son datos ajustados de forma estacional

ytsa <- seasadj(yt_stl)


## Ahora se grafica el componente estacional con la serie no estacional y con tendencia original

plot(yt, type="l")
lines(ytsa, type="l",col="purple")


## Gr�fica de los componentes estacionales por a�o

seasonplot(ytsa, 12, col=rainbow(12), year.labels=TRUE)



###### Des-Estacionalizar la serie original


## Con el componente estacional calculado, ahora se define como serie de tiempo
ytsa<-ts(ytsa,start=c(2010,1),end=c(2018,12),frequency=12)

## Se hace la resta de la serie calculada con el ajuste estacional y la serie original.
yt_season<-yt-ytsa

## Gr�fica de la serie resultante, es la gr�fica del componente estacional de la gr�fica.
plot(yt_season,type="l",col="brown")



###### COMPONENTE DE TENDENCIA + COMPONENTE ESTACIONAL

## Ahora con los dos componentes, se busca ajustar la serie, o hacer una
## similar, con los dos componentes de tal forma que se define la serie con
## los dos componentes tendencia y estacional.

yt_fitted<-ytt+yt_season



## Gr�fica del ajuste de TENDENCIA Y ESTACIONAL con respecto a la serie original.

plot(yt,type="l",col="blue")
lines(yt_fitted,type="l",col="red")




## En la descomposici�n de la tendencia se puede observar que aunque la serie
## original del tipo de cambio muestra una clara tendencia, cuando se aplican
## los rezagos con el logaritmo, la serie resultante ya no muestra tener
## tendencia de largo plazo. Sin embargo, cuando se ajusta con una l�nea recta
## en la gr�fica se muestra una l�nea recta con pendiente positiva. El siguiente
## paso es evaluar si esa pendiente positiva es de forma sistem�tica, y requiere
## que la serie sea diferenciada una segunda vez para que sea estacionaria,
## o simplemente se trate de una tendencia de la muestra tomada. Para eso se
## realiazr� la Prueba Dicky-Fuller (Aumentada). De esta forma se tendr� 
## certeza de la tendencia.

## Por parte de la estacionalidad, esta se ajusta a laserie trabajada y por lo
## tanto, no requiere otro comentario hasta tener el resultado de la Prueba 
## Dickey-Fuller. 





##### e) Prueba Dickey-Fuller

prueba_df_aic <- ur.df(yt, type = "trend", lags = 12, selectlags = "AIC")

summary(prueba_df_aic)

## Del resutlado obtenido de la Prueba Dickey-Fuller Aumentada y tomando
## como la hip�tesis nula que hay ra�z unitaria, se rechaza la hip�tesis nula
## porque el valor -7.1435 es menor (o se encuentra m�s all� de la izquierda) de
## los valores cr�ticos de la prueba. Entonces no hay ra�z unitaria y la serie
## es estacionaria.



##### f) Verificaci�n de la serie sobre Estacionaria

## COmo la prueba de Dickey-Fuller Aumentada di� como resultado que se rechaz�
## la hip�tesis nula, que exist�a ra�z unitaria, se determin� que la serie
## es estacionaria y por lo tanto se puede aplicar el metodo Box-Jenkins




##### g) Orden de Integraci�n

## Utilizando la funci�n ndiffs() se puede verificar que la serie original del
## tipo de cambio puede ser diferenciada 1 sola vez para que sea estacionaria.

## Si aplicamos la serie de tiempo original

tipo_cambio_serie <- ts(tipo_cambio_serie, start = c(2010,1),
                        end = c(2018,12),frequency = 12) %>% ndiffs()

## El resultado es que el orden de integraci�n de la serie original del tipo 
## de cambio es 1. Mientras que el orden de integraci�n de la serie calculada
## en el inciso a) es estacionaria porque incluye una diferencia y su orden de
## integraci�n es cero.






##### h) Gr�fica de la serie estacionaria y Estad�sticos Descriptivos



## Gr�fica

plot(yt, type="l", col="blue")
title(main = "Tipo de Cambio", sub = "Serie Estacionaria",
      ylab = "logaritmo E_t")



## An�lisis descriptivo de datos


## Datos
tipo_cambio <- c("valor")
Datos <- class(yt)
Frecuencia <- frequency(yt)
Inicio <- start(yt)
Final <- end(yt)
Min <- -0.066058
Max <- 0.065760
Prom <- 0.004209


## Construcci�n de la tabla
tabla_2 <- rbind(tipo_cambio,Datos,Frecuencia,
                 Inicio,Final,Min,Max,Prom,observaciones)

stargazer(tabla_2, type = "text",
          title = "Estad�sticas Descriptivas: Serie Estacionaria")








######### P A R T E _ 2 ######### 



#### Box - Jenkins


## a) Etapa 1: Identificaci�n


## Autocorrelograma y Autocorrelograma Parcial
par(mfrow = c(2,1))
acf(yt, col=2, lwd=3)
pacf(yt, col=2, lwd=3)

## DE la lectura del Autocorrelograma se puede decir que el primer tau es
## significativo y el resto no son significativos y tampoco tienen una tendencia
## marcada a decaer. La ca�da es r�pida y no tiene un patr�n. Por parte del
## Autocorrelograma parcial solo muestra un tau significativo que se  ve en el 
## lugar 16. Por lo tanto, hay dos modelos que se proponen. Un ARMA(1,1) y
## un ARMA(0,1)






## b) Etapa 2: Estimaci�n


## Modelo ARMA(0,1)

yt_fit_01 <- sarima(yt, p = 0, d = 0, q = 1)

stargazer(yt_fit_01$ttable, type = "text", title = "Modelo ARMA (0,1)")


# Interpretaci�n: En este modelo tenemos la media m�vil (MA) que es
# estadisticamente significativa. Por lo tanto, este modeo se considera 
# para seguir con el proceso de verificaci�n.






## Modelo ARMA(1,1)

yt_fit_11 <- sarima(yt, p = 1, d = 0, q = 1)

stargazer(yt_fit_11$ttable, type = "text", title = "Modelo ARMA (1,1)")

# Con esta especificaci�n se puede ver que ninguno de los regresores es
# estad�sticamente significativos, ni al 10%. Por lo tanto, este modelo se
# descarta para la siguiente etapa.






## c) Etapa 3: Verificaci�n


## Modelo ARMA(0,1)

yt_fit_01 <- sarima(yt, p = 0, d = 0, q = 1)


## Grafica de los Residuales
## La lectura es que tiene una trayectoria al rededor del cero, tiene diferentes
## varianza en diferentes periodos pero no se ve tendencia. 
## El autocorrelograma de los residuos no son significativos, por lo tanto, esta
## verificaci�n no hay problema. El siguiente es la gr�fica Q-Q en donde se 
## muestra la trayectoria de los residuales dentro de las bandas.
## EL valor p de los residuales no son significativos, por lo tanto, se puede
## decir que los residuales son independientes.



## Sobreidentificaci�n

yt_fit1 <- arima(yt,order =c(0,0,1))
yt_fit2 <- arima(yt,order =c(1,0,1))
yt_fit3 <- arima(yt,order =c(2,0,1))
yt_fit4 <- arima(yt,order =c(3,0,2))
yt_fit5 <- arima(yt,order =c(1,0,2))


stargazer(yt_fit1,yt_fit2,yt_fit3,yt_fit4,yt_fit5, type = "text",
          title = "Sobreidentificaci�n" )


## DE la sobreidentificaci�n se puede observar que el modelo 4 es un posible 
## candidato a ser el mejor modelo. Por lo tanto, se hace la prueba de 
## verificaci�n

yt_fit_32 <- sarima(yt, p = 3, d = 0, q = 2)


## El modelo ARMA(3,2) es un candidato a ser el mejor modelo. Por lo tanto, se 
## en la siguiente etapa se consideran Criterios de Informaci�n para elegir
## el modelo correcto.





## d) Etapa 4: Elecci�n


## Modelo ARMA(0,1)
modelo_1 <- sarima(yt, p = 0, d = 0, q = 1)

modelo_1$AIC

modelo_1$BIC



## Modelo ARMA(3,2)
modelo_2 <- sarima(yt, p = 3, d = 0, q = 2)

modelo_2$AIC

modelo_2$BIC


## Comparaci�n 


ARMA <- c("AIC","BIC")
ARMA_01 <- c(modelo_1$AIC,modelo_1$BIC)
ARMA_32 <- c(modelo_2$AIC,modelo_2$BIC)


tabla_3 <- rbind(ARMA,ARMA_01,ARMA_32)

stargazer(tabla_3, type = "text", title = "COmparaci�n de Modelos")



## EL mejor modelo seg�n el an�lisis que se realiz� es el ARMA(3,2)





