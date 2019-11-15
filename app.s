.data

	XML:		.asciiz "<Grupo>
	<Aluno>
		<Nome>Hugo</Nome>
		<Apelido>Neves</Apelido>
		<NMEC>88167</NMEC>
	</Aluno>
	<Aluno>
		<Nome>Joao</Nome>
		<Apelido>Santos</Apelido>
		<NMEC>88007</NMEC>
	</Aluno>
	<Aluno>
		<Nome>Tiago</Nome>
		<Apelido>Silva</Apelido>
		<NMEC>87913</NMEC>
	</Aluno>
</Grupo>"
	buffer:		.space	2048	 
	inserirXML:	.asciiz	"Inserir Conteudo do Ficheiro XML. NAO Usar Copiar Colar! Limite de 2048 Caracteres!\n\n"
	imprimir:	.asciiz	"\nA Imprimir o Ficheiro\n\n"

.text

#$t0 - Armazena o conteudo do ficheiro no formato de string
#$t1 - Caracter a ser analisado
#$t2 - Contador do percorreXML
#$t3 - Armazenar o comprimento da string
#$t5 - Armazena o numero de espacos a colocar em cada linha
#$t6 - Contador para outros loops que estejam dentro do percorreXML

main:

################OBTEM CONTEUDO DO FICHEIRO XML################

#			la	$a0, inserirXML				#Carrega em $a0 a mensagem	
#			li	$v0, 4					#Prepara o sistema para imprimir
#			syscall						#Imprime
#			li	$v0, 8					#Prepara o sistema para receber input to user
#			la	$a0, XML				#Guarda o que o user escrever em XML
#			la	$a1, buffer				#Maximo de caracteres que e permitido escrever
#			syscall						#Receve input do user

##############################################################
					
################COMPRIMENTO DA STRING QUE ARMAZENA O XML################

			la	$t0, XML				#Carrega o conteudo do ficheiro no registo $t0
			li	$t2, 0					#Inicia o contador a 0
	loopLength:
			lb 	$t1, 0($t0)				#Carrega o caracter a ser analisado em $t1
			addi	$t0, $t0, 1				#Passa para o proximo caracter da string
			addi	$t2, $t2, 1				#Adiciona 1 ao contador
			bnez	$t1, loopLength				#Verifica se ja chegou ao fim da string, se sim sai do loop, se nao continua				
			addi	$t2, $t2, -1				#O contador acaba com um valor a mais do que o comprimento da string entao temos de lhe tirar 1
			move	$t3, $t2				#Guarda o comprimento da string em $t3					

#########################################################################

################PERCORRE CADA CARACTER DO FICHEIRO XML################

			la	$a0, imprimir				#Carrega em $a0 a mensagem
			li	$v0, 4					#Prepara o sistema para imprimir					
			syscall						#Imprime
			la	$t0, XML				#Carrega o conteudo do ficheiro no registo $t0	
			sub	$t0, $t0, 1				#De modo a string iniciar no index 0 subtrai-se 1
			li	$t5, 0					#Inicia o numero de espacos necessarios por linha com 0
			li	$t2, 0					#Inicia o contador a 0						
	percorreXML:
			bge	$t2, $t3, end				#Quando o contador for igual ao comprimento da string termina o programa
			addi	$t0, $t0, 1				#Passa para o proximo caracter da string
			addi	$t2, $t2, 1				#Adiciona 1 a contador				
			lb 	$t1, 0($t0)				#Carrega o caracter a ser analisado em $t1
		checkChar:		
			beq	$t1, 60, checkCaracterMenor		#Se o caracter for igual a "<" entao ramifica para checkCaracterMenor, se nao continua 
			beq	$t1, 62, checkCaracterMaior		#Se o caracter for igual a ">" entao ramifica para checkCaracterMaior, se nao continua
			move	$a0, $t1				#Prepara o sistema para imprimir o caracter
			li	$v0, 11
			syscall						#Imprime					
			j	percorreXML				#Volta ao inicio do loop
				
######################################################################

################QUANDO O CARACTER FOR "<"################			
		
		checkCaracterMenor:										
				addi	$t0, $t0, 1			#Passa para o proximo caracter da string
				addi	$t2, $t2, 1			#Adiciona 1 a contador	
				lb 	$t1, 0($t0)			#Carrega o caracter a ser analisado em $t1			
				beq	$t1, 47, seBarra		#Se o caracter seguinte a "<" for "/" entao ramifica para seBarra, se nao continua
				la 	$a0, '+'			#Carrega para $a0 o caracter "+"
				li	$v0, 11				#Prepara o sistema para imprimir o caracter				
				syscall					#Imprime					
				j	checkChar			#Como o caracter seguinte a "<" nao e "/" vai verificar
			seBarra:
				sub 	$t5, $t5, 6			#Fim da tag entao retira 3 espacos
				loopMenorSeBarra:		
				beq	$t1, 62, checkCaracterMaior	#Quando o caracter for igual a ">" entao ramifica para checkCaracterMaior, se nao continua a repetir
				addi	$t0, $t0, 1			#Passa para o proximo caracter da string
				addi	$t2, $t2, 1			#Adiciona 1 a contador	
				lb 	$t1, 0($t0)			#Carrega o caracter a ser analisado em $t1
				j	loopMenorSeBarra		#Volta ao inicio do loop
				
#######################################################
			
################QUANDO O CARACTER FOR ">"################		
			
		checkCaracterMaior: 				
				addi	$t5,$t5, 3			#Acrescenta 3 espacos				
				j	passarProximo			#Passa para o proximo caracter e adiciona 1 a contador
			loopCaracterMaior:
				beq	$t1, 10, passarProximo		#Se o caracter for igual a uma nova linha entao passa para o proximo caracter e volta a verificar, se nao continua		
				beq	$t1, 11, passarProximo		#Se o caracter for igual a "\n" entao passa para o proximo caracter e volta a verificar, se nao continua						
				beq	$t1, 9, passarProximo		#Se o caracter for igual a "\t" entao passa para o proximo caracter e volta a verificar, se nao continua						
				beq	$t1, 32, passarProximo		#Se o caracter for igual a " " entao passa para o proximo caracter e volta a verificar, se nao continua e quer dizer que encontrou um caracter que nao era um espaco em branco					
				la	$a0, '\n'			#Quando encontrar algum caracter que nao seja espaco em branco carrega para $a0 uma nova linha				
				li	$v0, 11				#Prepara o sistema para imprimir nova linha				
				syscall					#Imprime								
				li	$t6, 0				#Inicia o contador a 0			
				imprimeTabs:									
				beq	$t6, $t5, checkChar		#Se contador e igual ao numero de espaços a imprimir entao volta a percorrer a string				
				la	$a0, ' '			#Carrega para $a0 o caracter a imprimir				
				li	$v0, 11				#Prepara o sistema para imprimir o espaco				
				syscall					#Imprime				
				addi	$t6, $t6, 1			#Adiciona 1 a contador				
				j	imprimeTabs			#Volta ao inicio do loop				
				passarProximo:							
				addi	$t0, $t0, 1			#Passa para o proximo caracter da string				
				addi	$t2, $t2, 1			#Adiciona 1 a contador			
				lb 	$t1, 0($t0)			#Carrega o caracter a ser analisado em $t1			
				j	loopCaracterMaior		#Volta ao inicio do loop	
				
#######################################################
return:
				jr	$ra				#Volta para o local onde a funcao foi chamada
end:
				li	$v0, 10				#Termina 
				syscall					#	Programa
