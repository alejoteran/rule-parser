.data

parsing:	.asciiz "C:/Users/57301/Download/Proyecto_Final/Parsing_Rules.config"
dataa:	.asciiz "C:/Users/57301/Download/Proyecto_Final/data"
bufferparsing:		.space 200
bufferData: 	.space 200
dirIP:	.asciiz 8000 #Cada dirección IP ocupa 40 (multiplicar por la cantidad de direcciones IP)
username:	.asciiz 8000 
textSalida: 		.asciiz	"C:/Users/57301/Download/Proyecto_Final/Alerts_Triggered.log"
tspData:	.asciiz 8000

textReporte:	.asciiz "C:/Users/57301/Download/Proyecto_Final/Report.log"

alertas:		.asciiz 8000


.text

	#parsing
	li $v0,13
	la $a0,parsing
	li $a1,0
	li $a2,0
	li $s1, 2000 #cont ordenar

	syscall
	
	move $t0,$v0
	
	li $v0,14
	move $a0,$t0
	la $a1,bufferparsing
	li $a2,49
	syscall
	
	li $v0,16
	move $a0,$t0
	syscall
	
	#Data
	
	li $v0,13
	la $a0,dataa
	li $a1,0
	li $a2,0
	syscall
	
	move $t0,$v0
	
	li $v0,14
	move $a0,$t0
	la $a1,bufferData
	li $a2,49
	syscall
	
	li $v0,16
	move $a3,$t0
	syscall
	
	
	#Extraer IP y Usernames
	
	la $t1,bufferparsing
	la $t2,dirIP #Se guarda la dirección de memoria de la primera dirección IP
	la $t4, username
	
	addi $t1,$t1,3 #Se suman 3 posiciones para no tomar la palabra "IP:"
	
	#move $a0, $t2
	#li $v0, 4
	#syscall
	
	
	
	
	GUARDARIP:
	
	lb $t3, 0($t1) #Para recorrer byte a byte
	beq $t3,'\n',GUARDARUSERS
	beq $t3,',',FINIP
	
	sb $t3, 0($t2) #Guarda en el arreglo de direcciones el byte que se cargó en $t3
	addi $t2, $t2,1 #Se mueve una posición en el arreglo
	addi $t1, $t1, 1

	 
	 FINIP:
	 
	 li $t2, '\n'
	 
	 j GUARDARIP
	 
	 GUARDARUSERS:
	 
	 addi $t1,9 #para no tomar la palabra usernaame:
	 
	 lb $t3, 0($t1) #Para recorrer byte a byte
	beq $t3,'*',FIN
	beq $t3,',',FINUSER
	
	sb $t3, 0($t4) #Guarda en el arreglo de direcciones el byte que se cargó en $t3
	addi $t4, $t4,1 #Se mueve una posición en el arreglo
	addi $t1, $t1, 1
	
	FINUSER:
	
	li $t4,'\n'
	j GUARDARUSERS
	
	FIN:
	
	#Lectura del archivo data
	
	
	la $t1,bufferData
	la $t6,dirIPData #Se guarda la dirección de memoria de la primera dirección IP
	la $t4, usernameData
	la &t5, tspData
	
	GUARDARDATOS:
	
	beq $t7,'*',ORDENAR
	addi $t1,$t1,5 #Se suman 3 posiciones para no tomar la palabra "|ip:'"
	
	GUARDARIPDATA:
	lb $t7, 0($t1) #Para recorrer byte a byte
	sb $t7, 0($t6) #Para guardar en el arreglo de direcciones
	addi $t6,$t6,1 #Para movernos una posición en el arreglo de  direcciones
	addi $t1,$t1,1 #Para movernos en el buffer
	beq $t7,'´',GUARDARUSERNAME
	j GUARDARIPDATA
	
	
	

	GUARDARUSERNAME:
	
	addi $t7,$t7,7
	
	lb $t7, 0($t1) #Para recorrer byte a byte
	beq $t7,'|',GUARDARTIEMPO
	
	sb $t7, 0($t4) #Guarda en el arreglo de direcciones el byte que se cargó en $t3
	addi $t4, $t4,1 #Se mueve una posición en el arreglo
	addi $t1, $t1, 1
	
	beq $t7,'|', GUARDARTIEMPO
	j GUARDARUSERNAME
	
	GUARDARTIEMPO:
	
	addi $t7,$t7,7 #Para ignorar "|tsp:'"
	
	lb $t7, 0($t1) #Para recorrer byte a byte
	beq $t7,'|',GUARDARDATOS
	sb $t7, 0($t5) #Guarda en el arreglo de direcciones el byte que se cargó en $t3
	addi $t5, $t5,1 #Se mueve una posición en el arreglo
	addi $t1, $t1, 1

	j GUARDARTIEMPO
	
	
	#FIN CARGAR ARCHIVOS
	
	
		
	
	ORDENAR:
	
	la $t8, tspData #Guardaar la dirección del arreglo de tiempo
	addi $t8,$t8,10 #Sumar 10
	
	la $t9, usernameData #Guardaar la dirección del arreglo de usernaame
	addi $t9,$t9,9 #Sumar 9
	
	la $s3, dirIPData #Guardaar la dirección del arreglo de ip
	addi $s3,$s3,11 #Sumar 11
	
	ORDER:
	
	beq $s1,0, FINORDER
	
	bgt 0($t5), 0($t8), CAMBIO	#Si $t5 es mayor a $t8, ir a CAMBIO
	addi $t5, $t5, 1
	addi $t8, $t8, 1
	sub $s1, $s1, 1
	j ORDER
	
	
	CAMBIO:
	li $s2,10
	WHILE:
	beq $s2, 0, CAMBIARUSERNAME
	
	move $s0, 0($t5) #$s0 es una variable auxiliar
	move 0($t5), 0($t8)
	move 0($t8), $s0
	addi $t5, $t5, 1
	addi $t8, $t8, 1
	
	sub $s2,$s2,1
	
	j WHILE
	
	CAMBIARUSERNAME:

	beq $t9,'\n',COMPARAR
	
	NOCUMPLE:
	move $s0, 0($t4) #$s0 es una variable auxiliar
	move 0($t4), 0($t9)
	move 0($t9), $s0
	addi $t4, $t4, 1
	addi $t9, $t9, 1
	j CAMBIARUSERNAME
	
	COMPARAR:
	beq $t4,'\n', CAMBIARIP
	j NOCUMPLE
	
	
	CAMBIARIP:
	
	beq $s3,'\n',COMPARARIP
	
	NOCUMPLEIP:
	move $s0, 0($t6) #$s0 es una variable auxiliar
	move 0($t6), 0($s3)
	move 0($s3), $s0
	addi $t6, $t6, 1
	addi $s3, $s3, 1
	j CAMBIARIP
	
	COMPARARIP:
	beq $t6,'\n', ORDER
	j NOCUMPLEIP
	
	
	
	FINORDER:
	la $s4,alertas

	WHILEALERTAS:
	
	
	
	bne 0($t2),0($t6),OTRADIR
	
	sb $t2,0($s4)
	
	addi $t2,$t2,1
	addi $t6,$t6,1
	
	
	j WHILEALERTAS
	
	OTRADIR:
	FOR:
	beq $t2,'\n',WHILEALERTAS
	addi $t2,$t2,1
	j FOR
	

	#Ecritura de Archivos
	
	li $v0,13
	la $a0,textSalida
	li $a1,1
	li $a2,0
	syscall
	
	move	$t0,$v0
	
	li $v0,15
	move $a0,$t0
	la $a1,$s4
	li $a2,50
	syscall
	
	li $v0,16
	move $a0,$t0
	syscall
	
	
	
	la $a0, buscarip
	li $a1, 16
	li $v0, 8
	syscall
	
	BUSCAR:
	
	bne 0($a0),0($t2), OTRAIP
	beq $a0, '\n', REPORT
	sb $a0,$s5 
	addi $a0, $a0, 1
	addi $t2, $t2, 1
	
	j BUSCAR
	
	
	OTRAIP:
    FOR:
	beq $t2,'\n',BUSCAR
	addi $t2,$t2,1
	j FOR
    
	
	REPORT:
	
	
	#Ecritura de Archivos
	
	li $v0,13
	la $a0,textReporte
	li $a1,1
	li $a2,0
	syscall
	
	move	$t0,$v0
	
	li $v0,15
	move $a0,$t0
	la $a1,$s5
	li $a2,50
	syscall
	
	li $v0,16
	move $a0,$t0
	syscall



	li 	$v0,10
	syscall