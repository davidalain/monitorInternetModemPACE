#! /bin/bash

# Este script foi desenvolvido por David Alain. https://github.com/davidalain/monitorInternetModemPACE .

# Pré-requisitos para executar este script:
# 1- Estar executando um sistema operacional Linux em seu PC.
# 2- Ter o sshpass instalado no seu Linux.
# 3- Ter o modem PACE v5471 com um firmware da TripleOxigen versão 42K instalada no modem.
# 4- Estar com o modem configurado para utilizar a subrede 192.168.25.1/24
# 5- Estar com o computador conectado à rede do modem.
# 6- Estar com o servidor SSH habilitado no modem.
# 7- Ter acessado o modem via SSH pelo menos uma vez (para que se tenha guardado as chaves SSH).

# ==== Variáveis globais do script ====
globalIP=""
dslStatus=""
pppStatus=""
currentSpeedDown=""
currentSpeedUp=""
maxSpeedDown=""
maxSpeedUp=""
snrUp=""
snrDown=""
dateTime=""
csvLine=""
delayTime=8
upConnectionCount=0

workingDir="relatorioInternetGVT"
workingPath="/home/$USER/$workingDir/"
csvFileOut="estatisticas.csv"
csvHeaderOut="cabecalhoEstatisticas.csv"

# ====== Funções =============

printHeader(){
	# Gera o arquivo de cabeçalho
	echo "dateTime,dslStatus,pppStatus,globalIP,maxSpeedDown[Kbps],maxSpeedUp[Kbps],currentSpeedDown[Kbps],currentSpeedUp[Kbps],snrDown[dB],snrUp[dB],outputPowerDown[dBm],outputPowerUp[dBm]"
}

init(){
	# Entra no diretório de trabalho
	mkdir -p $workingPath
	cd $workingPath
	echo "Diretório atual: $(pwd)"

	printHeader > $csvHeaderOut
}

gerarRelatorio(){


	# Remove o arquivo existente para baixar um novo
	rm -f status.txt

	# Acessa o modem via SSH e executa o comando remoto salvando a saída localmente no PC
	sshpass -p "toor" ssh root@192.168.25.1 '( /home/diag/usr/bin/xdslinfo && /home/diag/bin/ifconfig ppp1 )' > status.txt

	# Pega o horário atual
	dateTime=$(date +"%a %d/%m/%y %R:%S %z")
	#echo "dateTime=$dateTime"

	# Pega o status do DSL
	dslStatus=$(cat status.txt | grep "line state" | awk '{print $4}')
	#echo "dslStatus=$dslStatus"

	# Se já foi criada a conexão ppp1 e já está conectado
	cat status.txt | grep "ppp1" > /dev/null
	v1=$?
	cat status.txt | tail -n10 | grep "UP" > /dev/null
	v2=$?

	if [ $v1 -eq 0 ] && [ $v2 -eq 0 ] ; then

		# Pega o status do PPP
		pppStatus="UP"
		#echo "pppStatus=$pppStatus"

		# Pega o valor do IP válido
		globalIP=$(cat status.txt | tail -n10 | grep "addr:" | awk '{print $2}' | tr ":" " " | awk '{print $2}')
		#echo "globalIP=$globalIP"

		# Se estava com internet, então não precisa monitorar com muita frequência, uma amostra a cada 10 segundos é suficiente. Leva-se cerca 2 segundos para cada medição.
		delayTime=8
	else

		# Pega o status do PPP
		pppStatus="DOWN"
		#echo "pppStatus=$pppStatus"

		# Pega o valor do IP válido
		globalIP=""
		#echo "globalIP=$globalIP" 

		# Estava sem internet, então precisa monitorar com muita frequência, uma amostra a cada 5 segundos é o recomendado. Leva-se cerca 2 segundos para cada medição.
		delayTime=3
	fi

	# Pega os valores (Max Speed)
	maxSpeedDown=$(cat status.txt | grep "down max rate" | awk '{print $6}')
	#echo "maxSpeedDown=$maxSpeedDown"

	maxSpeedUp=$(cat status.txt | grep "up max rate" | awk '{print $6}')
	#echo "maxSpeedUp=$maxSpeedUp"

	# Pega os valores (Current Speed)
	currentSpeedDown=$(cat status.txt | grep "down actual rate" | awk '{print $6}')
	#echo "currentSpeedDown=$currentSpeedDown"

	currentSpeedUp=$(cat status.txt | grep "up actual rate" | awk '{print $6}')
	#echo "currentSpeedUp=$currentSpeedUp"

	# Pega os valores (SNR)
	snrDown=$(cat status.txt | grep "down noise margin" | awk '{print $6}')
	#echo "snrDown=$snrDown"

	snrUp=$(cat status.txt | grep "up noise margin" | awk '{print $6}')
	#echo "snrUp=$snrUp"

	# Pega os valores (Output Power)
	outputPowerDown=$(cat status.txt | grep "down output power" | awk '{print $6}')
	#echo "outputPowerDown=$outputPowerDown"

	outputPowerUp=$(cat status.txt | grep "up output power" | awk '{print $6}')
	#echo "outputPowerUp=$outputPowerUp"


	csvLine="$dateTime,$dslStatus,$pppStatus,$globalIP,$maxSpeedDown,$maxSpeedUp,$currentSpeedDown,$currentSpeedUp,$snrDown,$snrUp,$outputPowerDown,$outputPowerUp"
	printHeader
	echo $csvLine

	if [ $pppStatus == "UP" ] ; then
		# Está online, imprime a cada 1 minuto aproximadamente no arquivo CSV
		upConnectionCount=$(($upConnectionCount+1))
		if [ $upConnectionCount -eq 6 ] ; then
			echo $csvLine >> $csvFileOut
		fi
	
	else
		# Está offline, imprime o status no arquivo CSV
		upConnectionCount=0
		echo $csvLine >> $csvFileOut
	fi

}

# ========== Código principal (main) ===============

if [ -z $1 ] ; then
	echo "Nenhum caminho foi passado. Será utilizado o caminho padrão."
else
	workingPath=$1
	echo "Utilizando o caminho $workingPath"
fi

init

while [ 1 ] ; do

	echo "===== Rodando... ========================================="
	gerarRelatorio

	echo "===== Esperando horário da próxima execução ($delayTime seg) ====="

	sleep $delayTime
done



