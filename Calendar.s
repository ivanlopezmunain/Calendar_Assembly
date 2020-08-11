	.data
	.globl __start
moduloNormal:	.word -1 0 3 3 6 1 4 6 2 5 0 3 5
moduloBisiesto:	.word -1 0 3 4 0 2 5 0 3 6 1 4 6
espaciofecha1:	.space 100
espaciofecha2:	.space 100
domingo:	.asciiz "Domingo, "
lunes:		.asciiz "Lunes, "
martes:		.asciiz "Martes, "
miercoles:	.asciiz "Miercoles, "
jueves:		.asciiz "Jueves, "
viernes:	.asciiz "Viernes, "
sabado:		.asciiz "Sabado, "
enero:		.asciiz " de Enero del "
febrero:	.asciiz " de Febrero del "
marzo:		.asciiz " de Marzo del "
abril:		.asciiz " de Abril del "
mayo:		.asciiz " de Mayo del "
junio:		.asciiz " de Junio del "
julio:		.asciiz " de Julio del "
agosto:		.asciiz " de Agosto del "
septiembre:	.asciiz " de Septiembre del "
octubre:	.asciiz " de Octubre del "
noviembre:	.asciiz " de Noviembre del "
diciemrbe:	.asciiz " de Diciembre del "	
entrada:	.asciiz "Introduzca la primera fecha en formato dd/mm/aaaa: "
entrada2:	.asciiz "Introduzca la segunda fecha en formato dd/mm/aaaa: "
entradaerror2:	.asciiz "Formato incorrecto."
entradaerror3:	.asciiz "Caracter incorrecto."
entradaerror4:	.asciiz "En Europa antes del 1582 se usaba el calendario Juliano, esta aplicacion esta orientada completamente al calendario Gregoriano." 
	.text
__start:
	la $a0 entrada
	li $v0 4
	syscall
	la $a0 espaciofecha1
	addi $a1 $zero 15
	li $v0 8
	syscall
	move $s0 $a0			#se guarda en $s0 la primera fecha.
	jal comprobadorLongitud
	la $a0 espaciofecha1
	move $s0 $a0
	jal comprobadorBarras
	jal getAno			#año calculado en $v0
	move $s1 $v0			#movemos el año a $s1
	jal ComprobarBisiesto		
	jal getMes			#mes calculado en $v0
	move $s2 $v0			#movemos a $s2 el MES CALCULADO
	jal getDia			#dia calculado en $v0
	move $s3 $v0			#movemos a $s3 el DIA CALCULADO
	jal getFecha			#en $s9 se encuentra ya cargado el modulo correspondiente al mes y devuelve en $v0 el resultado
	jal Imprimir
	jal ImprimirMes
	li $v0 10
	syscall

comprobadorLongitud:
	addi $t0 $zero 0
	addi $t2 $zero 10
	addi $t3 $zero 11
BucleCompr:	
	lb $t1 0($s0)
	addi $s0 $s0 1
	beq $t1 $t2 FinFech 
	beq $t0 $t2 FechLarga
	addi $t0 $t0 1
	j BucleCompr

FechLarga:				#imprime error si cadena demasiado larga o demasiado corta
	la $a0 entradaerror2
	li $v0 4
	syscall
	li $v0 10
	syscall
FinFech:
	slt $t1 $t0 $t2
	bne $zero $t1 FechLarga
	jr $ra

comprobadorBarras:			#comprobador de formato
	lb $t0 2($s0)
	addi $t1 $zero 47
	bne $t0 $t1 MALFORM
	lb $t0 5($s0)
	bne $t0 $t1 MALFORM
	jr $ra
MALFORM:
	la $a0 entradaerror2
	li $v0 4
	syscall
	li $v0 10 
	syscall
getAno:					#comprobar si año correcto 
	addi $t2 $s0 6
	addi $t6 $zero 10
	addi $t3 $zero 48
	addi $t5 $zero 57
BucleAno:
	lb $t0 0($t2)
	beq $t0 $t6 CalculoAno
	slt $t4 $t0 $t3
	bne $t4 $zero MALCARAC
	slt $t4 $t5 $t0
	bne $t4 $zero MALCARAC
	addi $t2 $t2 1
	j BucleAno
CalculoAno:
	lb $t0 6($s0)
	addi $t0 $t0 -48		#multiplico por 1000
	mul $v0 $t0 $t6
	mul $v0 $v0 $t6
	mul $v0 $v0 $t6
	lb $t0 7($s0)
	addi $t0 $t0 -48		#multiplico por 100
	mul $t1 $t0 $t6
	mul $t1 $t1 $t6
	lb $t0 8($s0)
	addi $t0 $t0 -48		#multiplico por 10
	mul $t2 $t0 $t6
	lb $t0 9($s0)
	addi $t0 $t0 -48
	add $v0 $v0 $t1
	add $v0 $v0 $t2
	add $v0 $v0 $t0			#en $v0 esta el año (CALCULADO)
	addi $t9 $zero 1583
	slt $t8 $v0 $t9
	bne $zero $t8 Juliano
	jr $ra
Juliano:				# si año menor que 1583: error calendario juliano
	la $a0 entradaerror4
	li $v0 4
	syscall
	li $v0 10
	syscall

MALCARAC:
	la $a0 entradaerror3
	li $v0 4
	syscall
	li $v0 10 
	syscall

ComprobarBisiesto:				#si año bisiesto cargamos moduloBisiesto y sino moduloNormal (sirven para calcular el dia de la semana)
	addi $t8 $zero 4
	addi $t9 $zero 100
	addi $t7 $zero 400
	div $s1 $t8
	mfhi $t0
	beq $t0 $zero BisiestoCompr
	la $a2 moduloNormal
	jr $ra
BisiestoCompr:
	div $s1 $t9
	mfhi $t0 
	beq $t0 $zero BisiestoCompr2
	la $a2 moduloBisiesto
	jr $ra
BisiestoCompr2:
	div $s1 $t7
	mfhi $t0 
	beq $t0 $zero BisiestoCompr3
	la $a2 moduloNormal
	jr $ra
BisiestoCompr3:
	la $a2 moduloBisiesto
	jr $ra


getMes:						#comprueba si el mes es correcto y lo obtiene
	addi $t2 $s0 3
	addi $t3 $zero 48
	addi $t6 $zero 49
	addi $t7 $zero 50
	addi $t5 $zero 57
	addi $t8 $zero 10
BucleMes:
	lb $t0 0($t2)				#Guarda el PRIMER DIGITO DEL MES en $t0
	beq $t0 $t3 Caso0Mes              	#$t3 es 48 tomado antes 
	beq $t0 $t6 Caso1Mes
	la $a0 entradaerror3
	li $v0 4
	syscall
	li $v0 10 
	syscall
Caso0Mes:
	lb $t1 1($t2)				#Guarda el SEGUNDO DIGITO DEL MES en $t1					
	slt $t4 $t1 $t3
	bne $t4 $zero MALCARAC2
	slt $t4 $t5 $t1
	bne $t4 $zero MALCARAC2
	j CalculoMes

Caso1Mes:
	lb $t1 1($t2)				#Guarda el SEGUNDO DIGITO DEL MES en $t1		
	beq $t1 $t3 CalculoMes             
	beq $t1 $t6 CalculoMes
	beq $t1 $t7 CalculoMes
	la $a0 entradaerror3
	li $v0 4
	syscall
	li $v0 10 
	syscall
CalculoMes:
	addi $t0 $t0 -48
	mul $v0 $t0 $t8
	addi $t1 $t1 -48
	add $v0 $v0 $t1				#guardamos en $v0 el mes CALCULADO
	jr $ra
MALCARAC2:
	la $a0 entradaerror3
	li $v0 4
	syscall
	li $v0 10 
	syscall

getDia:					#comprobamos si el dia es correcto y se calcula
	addi $t6 $zero 10
	lb $t4 0($s0)
	addi $t4 $t4 -48
	mul $t4 $t4 $t6
	lb $t5 1($s0)
	addi $t5 $t5 -48
	add $t4 $t5 $t4			#$t4 numero del dia CALCULADO
	divu $s2 $t6			
	mflo $t0			#obtenemos el primer digito del mes
	mfhi $t1			#obtenemos el segundo digito del mes
	beq $t0 $zero Caso0Dia		#Si el primer digito del mes es cero iremos a los meses que van del cero al 9
	bne $t0 $zero Caso1Dia		#Si el primer digito del mes es  distinto de cero iremos a los meses que van del 10 al 12
Caso0Dia:				#Nudillos:meses de 31 dias. Huecos: meses de 30 dias
	addi $t2 $zero 1
	beq $t1 $t2 Nudillos
	addi $t2 $zero 3
	beq $t1 $t2 Nudillos
	addi $t2 $zero 5
	beq $t1 $t2 Nudillos
	addi $t2 $zero 7
	beq $t1 $t2 Nudillos
	addi $t2 $zero 8
	beq $t1 $t2 Nudillos
	addi $t2 $zero 2
	beq $t1 $t2 Febrero
	addi $t2 $zero 4
	beq $t1 $t2 Huecos
	addi $t2 $zero 6
	beq $t1 $t2 Huecos
	addi $t2 $zero 9
	beq $t1 $t2 Huecos
Caso1Dia:
	addi $t2 $zero 1
	beq $t1 $t2 Huecos
	addi $t2 $zero 0
	beq $t1 $t2 Nudillos
	addi $t2 $zero 2
	beq $t1 $t2 Nudillos
Nudillos:					#comprobamos que el dia este entre 1 y 31		
	addi $t3 $zero 1
	addi $t5 $zero 31
	slt $t6 $t4 $t3
	bne $t6 $zero MALCARAC3
	slt $t6 $t5 $t4
	bne $t6 $zero MALCARAC3
	j CalculoDia

Huecos:						#comprobamos que el dia este entre 1 y 30
	addi $t3 $zero 1
	addi $t5 $zero 30
	slt $t6 $t4 $t3
	bne $t6 $zero MALCARAC3
	slt $t6 $t5 $t4
	bne $t6 $zero MALCARAC3
	j CalculoDia

Febrero:					#comprobamos que el dia este entre 1 y 28/29 (depende de si es bisiesto)
	addi $t8 $zero 4
	addi $t9 $zero 100
	addi $t7 $zero 400
	div $s1 $t8
	mfhi $t0
	beq $t0 $zero Bisiesto
	addi $t3 $zero 1
	addi $t5 $zero 28
	slt $t6 $t4 $t3
	bne $t6 $zero MALCARAC3
	slt $t6 $t5 $t4
	bne $t6 $zero MALCARAC3
	j CalculoDia
Bisiesto:
	div $s1 $t9
	mfhi $t0 
	beq $t0 $zero Bisiesto2
	addi $t3 $zero 1
	addi $t5 $zero 29
	slt $t6 $t4 $t3
	bne $t6 $zero MALCARAC3
	slt $t6 $t5 $t4
	bne $t6 $zero MALCARAC3
	j CalculoDia
Bisiesto2:
	div $s1 $t7
	mfhi $t0 
	beq $t0 $zero Bisiesto3
	addi $t3 $zero 1
	addi $t5 $zero 28
	slt $t6 $t4 $t3
	bne $t6 $zero MALCARAC3
	slt $t6 $t5 $t4
	bne $t6 $zero MALCARAC3
	j CalculoDia
Bisiesto3:
	addi $t3 $zero 1
	addi $t5 $zero 29
	slt $t6 $t4 $t3
	bne $t6 $zero MALCARAC3
	slt $t6 $t5 $t4
	bne $t6 $zero MALCARAC3
	

CalculoDia:
	move $v0 $t4
	jr $ra 				#movemos el dia calculado de $t4 a $v0

MALCARAC3:
	la $a0 entradaerror3
	li $v0 4
	syscall
	li $v0 10 
	syscall


getFecha:				#obtenemos el dia de la semana que corresponde con la fecha
	addi $t3 $zero 7
	addi $t5 $zero 100
	addi $t6 $zero 3
	sll $t2 $s2 2
	add $a2 $t2 $a2
	lw $t2 0($a2)			#en $t2 tenemos el modulo
	addi $t1 $s1 -1			#decrementamos en una unidad el año. en $t1 (año-1)
	divu $t1 $t3
	mfhi $t4			#en $t4 (año-1)%7
	srl $t0 $t1 2			#(año-1)/4 en $t0
	divu $t1 $t5
	mflo $t5			# en $t5 (año-1)/100
	addi $t5 $t5 1
	mul $t5 $t5 $t6
	srl $t5 $t5 2			#en $t5 (3*((año-1)/100+1)/4)
	sub $t5 $t0 $t5			#(año-1)/4 - (3*((año-1)/100+1)/4)
	divu $t5 $t3
	mfhi $t5 			# ((año-1)/4 - (3*((año-1)/100+1)/4))%7			
	divu $s3 $t3
	mfhi $t6			#en $t6 dia%7
	add $t6 $t6 $t2			#en $t6 dia%7 + Modulo
	add $v0 $t6 $t5
	add $v0 $v0 $t4
	divu $v0 $t3
	mfhi $v0			#$v0 tiene un valor del 0 al 6 (0 domingo, 6 sabado)
	jr $ra

Imprimir:				#imprimir el dia de la semana y el numero		
	addi $t0 $zero 0
	beq $t0 $v0 Domingo
	addi $t0 $zero 1
	beq $t0 $v0 Lunes
	addi $t0 $zero 2
	beq $t0 $v0 Martes
	addi $t0 $zero 3
	beq $t0 $v0 Miercoles
	addi $t0 $zero 4
	beq $t0 $v0 Jueves
	addi $t0 $zero 5
	beq $t0 $v0 Viernes
	addi $t0 $zero 6
	beq $t0 $v0 Sabado

Domingo:
	la $a0 domingo
	li $v0 4
	syscall
	move $a0 $s3
	li $v0 1
	syscall
	jr $ra
	
Lunes:
	la $a0 lunes
	li $v0 4
	syscall
	move $a0 $s3
	li $v0 1
	syscall
	jr $ra
Martes:
	la $a0 martes
	li $v0 4
	syscall
	move $a0 $s3
	li $v0 1
	syscall
	jr $ra
Miercoles:
	la $a0 miercoles
	li $v0 4
	syscall
	move $a0 $s3
	li $v0 1
	syscall
	jr $ra
Jueves:
	la $a0 jueves
	li $v0 4
	syscall
	move $a0 $s3
	li $v0 1
	syscall
	jr $ra
Viernes:
	la $a0 viernes
	li $v0 4
	syscall
	move $a0 $s3
	li $v0 1
	syscall
	jr $ra
Sabado:
	la $a0 sabado
	li $v0 4
	syscall
	move $a0 $s3
	li $v0 1
	syscall
	jr $ra
ImprimirMes:				#imprimir el mes y el año
	addi $t0 $zero 1
	beq $t0 $s2 Enero
	addi $t0 $zero 2
	beq $t0 $s2 Febrero1
	addi $t0 $zero 3
	beq $t0 $s2 Marzo
	addi $t0 $zero 4
	beq $t0 $s2 Abril
	addi $t0 $zero 5
	beq $t0 $s2 Mayo
	addi $t0 $zero 6
	beq $t0 $s2 Junio
	addi $t0 $zero 7
	beq $t0 $s2 Julio
	addi $t0 $zero 8
	beq $t0 $s2 Agosto
	addi $t0 $zero 9
	beq $t0 $s2 Septiembre
	addi $t0 $zero 10
	beq $t0 $s2 Octubre
	addi $t0 $zero 11
	beq $t0 $s2 Noviembre
	addi $t0 $zero 12
	beq $t0 $s2 Diciembre

Enero:
	la $a0 enero
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra	
Febrero1:
	la $a0 febrero
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Marzo:
	la $a0 marzo
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Abril:
	la $a0 abril
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Mayo:
	la $a0 mayo
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Junio:
	la $a0 junio
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Julio:
	la $a0 julio
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Agosto:
	la $a0 agosto
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Septiembre:
	la $a0 septiembre
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Octubre:
	la $a0 octubre
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Noviembre:
	la $a0 noviembre
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
Diciembre:
	la $a0 diciembre
	li $v0 4
	syscall
	move $a0 $s1
	li $v0 1
	syscall
	jr $ra
