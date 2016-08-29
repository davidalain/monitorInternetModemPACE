# Monitor de Internet Modem PACE v5471

#### Códigos em shell para monitoramento do status da conexão com a internet no modem PACE v5471.
Estes códigos capturam informações da conexão e salvam essas informações em um arquivo CSV para extração de informações e/ou interpretação dos dados de maneira gráfica.

São capturados os seguintes dados:

+ **dateTime:** Data e hora da medição.
+ **dslStatus:** Status do DSL (conectado ou desconectado).
+ **pppStatus:** Status da autenticação via PPP (conectado ou desconectado).
+ **globalIP:** IP válido fornecido pela operadora.
+ **maxSpeedDown[Kbps]:** Velocidade máxima possível de download para a qualidade do sinal atual.
+ **maxSpeedUp[Kbps]:**  Velocidade máxima possível de upload para a qualidade do sinal atual.
+ **currentSpeedDown[Kbps]:** Velocidade atual de download que o modem estabeleceu com a operadora.
+ **currentSpeedUp[Kbps]:** Velocidade atual de download que o modem estabeleceu com a operadora.
+ **snrDown[dB]:** Relação Sinal/Ruído (SNR) do sinal de download.
+ **snrUp[dB]:** Relação Sinal/Ruído (SNR) do sinal de upload.
+ **outputPowerDown[dBm]:** Potência de saída do sinal de download.
+ **outputPowerUp[dBm]:** Potência de saída do sinal de upload.

