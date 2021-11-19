################################################################################
## calculatrice.s
################################################################################
##
## Examples (assuming 'Mars4_5.jar' is present in the current directory):
## $ echo -en "10\n+\n10\n\n" java -jar Mars4_5.jar nc calculatrice.s
## $ java -jar Mars4_5.jar nc calculatrice.s <test_001.txt 2>/dev/null
## $ java -jar Mars4_5.jar nc calculatrice.s pa "integer"
## $ java -jar Mars4_5.jar nc calculatrice.s pa "float"
## $ java -jar Mars4_5.jar nc calculatrice.s pa "double"
##
################################################################################
##
## Copyright (c) 2019 John Doe <user@server.tld>
## This work is free. It comes without any warranty, to the extent permitted by
## applicable law.You can redistribute it and/or modify it under the terms of
## the Do What The Fuck You Want To Public License, Version 2, as published by
## Sam Hocevar. See http://www.wtfpl.net/ or below for more details.
##
################################################################################
##        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
##                    Version 2, December 2004
##
## Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
##
## Everyone is permitted to copy and distribute verbatim or modified
## copies of this license document, and changing it is allowed as long
## as the name is changed.
##
##            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
##   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
##
##  0. You just DO WHAT THE FUCK YOU WANT TO.
################################################################################


################################################################################
# How does it work ?
################################################################################
#	MODES : INTEGER (Line 180) - FLOAT (Line 510) - DOUBLE (Line 760)
#	=================================================================
#
#	- Integer : + - * / abs pow min max
#		  bin hexa prime mod pgcd reset
#		  facto fibo float double opp
#		  also enter an empty line ends the program	
#
#	- Float   : + - * / abs pow min max
#		  double integer reset inv
#		  opp expo ln sqrt round
#		  also enter an empty line ends the program
#
#	- Double : works the same way as Float mode, but instead of
#		"double" use "float"
################################################################################
# Data
################################################################################

.data

# Floating point values
fp0: 	.float 	0.0
fp1: 	.float 	1.0
fp2: 	.float 	2.0
fpe: 	.float 	2.71828182846		#e
fp5: 	.float  5			# k pour fonction ln
fp100: 	.float  100			# pour conversion en float ou double
fp05:	.float	0.5			# pour conversion en float ou double

# Double point values
dp0: 	.double 0.0
dp1: 	.double 1.0
dp2: 	.double 2.0
dpe: 	.double 2.71828182846		#e
dp5: 	.double 5			# k pour fonction ln

# Characters
operation: .space 16			# string pour operateur
plus: 	.byte 	'+'
minus: 	.byte 	'-'
multi: 	.byte 	'*'
divi: 	.byte 	'/'
space: 	.byte 	' '
prompt: .byte 	'\n'

#-------------------------------------------------------------------------------
# Strings
#-------------------------------------------------------------------------------

# Misc.
string_space: 		.asciiz 	" "
string_newline: 	.asciiz 	"\n"
string_output_prefix: 	.asciiz 	"> "
string_arg: 		.asciiz 	"arg "
string_calculator: 	.asciiz 	"calculator "

string_erreur: 		.asciiz	 	"Division par 0 impossible. Entrer a nouveau\n"
string_erreur_fibo: 	.asciiz 	"Depacement de capacite a partir de 47. Entrer a nouveau\n"
string_erreur_minus: 	.asciiz 	"Calcul impossible si inf a zero. Entrer a nouveau\n"
string_erreur_facto: 	.asciiz 	"Depassement de capacite a partir de 17. Entrer a nouveau\n"
string_erreur_ln: 	.asciiz 	"Ln de x inf a 0 impossible. Entrer a nouveau\n"

# Cli args
string_integer: 	.asciiz 	"integer"
string_float: 		.asciiz 	"float"
string_double: 		.asciiz 	"double"

# Operations
string_min: 	.asciiz 	"min"
string_max: 	.asciiz 	"max"
string_pow: 	.asciiz 	"pow"
string_abs: 	.asciiz 	"abs"
string_opp: 	.asciiz 	"opp"
string_inv: 	.asciiz 	"inv"
string_facto: 	.asciiz 	"facto"
string_expo: 	.asciiz 	"expo"
string_reset: 	.asciiz 	"reset"
string_fibo: 	.asciiz 	"fibo"
string_pgcd: 	.asciiz 	"pgcd"
string_mod: 	.asciiz 	"mod"
string_prime: 	.asciiz		"prime"
string_ln: 	.asciiz		"ln"
string_sqrt: 	.asciiz		"sqrt"
string_round: 	.asciiz		"round"
string_bin: 	.asciiz		"bin"
string_hexa: 	.asciiz		"hexa"
hexadecimal:	.space 	 	 8 

string_unknown: .asciiz "Operateur inconnu ! Nouvel operateur :\n"

################################################################################
# Text
################################################################################

.text
.globl __start

__start:
	beq 	$a0 $0 	ignore_cli_args			# Line 143
	jal 	handle_cli_args				# Line 1024
	j 	calculator_selection			# Line 146

ignore_cli_args:
  	li 	$v0 0

calculator_selection:
  	beq 	$v0 1 	calculator_select_float		# Line 156	
  	beq 	$v0 2	calculator_select_double	# Line 161

# Si 0
calculator_select_integer:
    	jal 	calculator_integer			# Line 178
    	j 	program_exit				# Line 170
 
# Si 1   
calculator_select_float:
    	jal 	calculator_float			# Line 510
    	j 	program_exit				# Line 170
    	
# Si 2 	
calculator_select_double:
    	jal 	calculator_double			# Line 762
    	j 	program_exit				# Line 170

# Sinon
calculator_select_default:
    	j 	program_exit				# Line 170

# Exit 
program_exit:
  	li 	$v0 10
  	syscall

#######################################################################################################
# Calculator main : INTEGER === Tests : 223 a 315 === Pre-calcul : 317 a 485 === Calculs : 1485 a 1735
#######################################################################################################

calculator_integer:
  	subu 	$sp $sp 32
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)
  	sw 	$a1 8($sp)
  	sw 	$a2 12($sp)
  	sw 	$s0 16($sp)
 	sw 	$s1 20($sp)
 	sw 	$s2 24($sp)
 	sw 	$s3 28($sp)

	# Debugging info (integer mode) on stderr
  	la 	$a0 string_calculator
	jal 	print_string_stderr			# Line 1234

	la 	$a0 string_integer
	jal 	print_string_stderr			# Line 1234
  
	jal 	print_newline_stderr
	beq 	$t9 1 	calculator_integer_print	# Line 204 : si t9 = 1 : saut
  
calculator_integer_start:				# sinon on fonctionne normalement
    	jal 	read_int
    	move 	$s0 $v0
   	 j 	calculator_integer_loop			# Line 210
    
calculator_integer_print:				# si 1, on recupere la valeur pre enregistree via switch
    	move 	$a0 $s0
	jal 	print_int
	jal 	print_newline

# Calculator loop : 
calculator_integer_loop:
    	li 	$v0 8 
   	la 	$a0 operation				# Demande un opérateur
    	li 	$a1 16
    	syscall
    	
    	li 	$v0 0					# Initialise le futur resultat
    	move 	$a0 $s0
    
    	la 	$a1 operation				# stocke string dans a1
    	lb 	$t0 operation				# stocke premer bit dans t0
    	
    	lb 	$t1 plus				# compare bit "+" avec t0, si 1 alors calcule
    	beq 	$t0 $t1 Add_int				# Pareil pour "-" ; "*"; "/"
    	
    	lb 	$t1 minus
    	beq 	$t0 $t1 Sub_int
    	
    	lb 	$t1 multi
    	beq 	$t0 $t1 Mul_int
    	
    	lb 	$t1 divi				
    	beq 	$t0 $t1 Div_int
    	
    	la 	$a0 string_abs				# compare string "abs" avec operateur
  	jal 	simple_strncmp
  	move 	$a0 $s0					# Copie premiere operande dans a0, car a0 modif dans strncmp
    	bnez 	$v0 Abs_int				# Si 1, alors calcule
    	
    	la 	$a0 string_max				# Pareil pour "max" ; "min" ; "pow" ; "opp" ; "facto" ; "reset"
  	jal 	simple_strncmp				#		"float" ; "double" ; "fibo" ; "pgcd" ; "mod"
  	move 	$a0 $s0					#		"prime" ; "bin" ; "hexa" ; "\n"
    	bnez 	$v0 Max_int
    		
  	la 	$a0 string_min
  	jal 	simple_strncmp
  	move 	$a0 $s0
    	bnez 	$v0 Min_int
    	
    	la 	$a0 string_pow
  	jal 	simple_strncmp
  	move 	$a0 $s0
    	bnez 	$v0 Pow_int
    	
    	la 	$a0 string_opp
  	jal 	simple_strncmp
  	move 	$a0 $s0
    	bnez 	$v0 Opp_int
    	
    	la 	$a0 string_facto
  	jal 	simple_strncmp
  	move 	$a0 $s0
    	bnez 	$v0 Facto_int
    	
    	la 	$a0 string_reset
  	jal 	simple_strncmp
    	bnez 	$v0 Reset_int
    	
    	la 	$a0 string_float
    	jal 	simple_strncmp
    	bnez 	$v0 Float_int
    	
    	la 	$a0 string_double
    	jal 	simple_strncmp
    	bnez 	$v0 Double_int
    	
    	la 	$a0 string_fibo
    	jal 	simple_strncmp
    	move 	$a0 $s0
    	bnez 	$v0 Fibo_int
    	
    	la 	$a0 string_pgcd
    	jal 	simple_strncmp
    	move 	$a0 $s0
    	bnez 	$v0 Pgcd_int
    	
    	la 	$a0 string_mod
    	jal 	simple_strncmp
    	move 	$a0 $s0
    	bnez 	$v0 Mod_int
    	
    	la 	$a0 string_prime
    	jal	simple_strncmp
    	move 	$a0 $s0
    	bnez	$v0 Prime_int
    	
    	la 	$a0 string_bin
    	jal 	simple_strncmp
    	move 	$a0 $s0
    	bnez 	$v0 Bin_int
    	
    	la 	$a0 string_hexa
    	jal 	simple_strncmp
    	move 	$a0 $s0
    	bnez 	$v0 Hexa_int

    	la 	$a0 string_newline
    	jal 	simple_strncmp
    	bnez 	$v0 program_exit
    	
    	la 	$a0 string_unknown			# Si 0 pour tout, alors print string "inconnu"
   	li 	$v0 4
   	syscall
   	
   	b calculator_integer_loop			# continue jusqu'a vrai
    	
	Add_int:
		jal 	read_int			# Demande deuxieme operande
   		move 	$a1 $v0				# copie dans a1
   		jal 	operation_integer_addition	# execute l addition
   		b  	calculator_integer_loop_end	# retourne le resultat

	Sub_int:
   		jal 	read_int			# Pareil pour fonction a deux operandes :
   		move 	$a1 $v0				#	+ - * / min max pow pgcd mod
   		jal 	operation_integer_substraction
   		b  	calculator_integer_loop_end
   		
	Mul_int:
   		jal 	read_int
   		move 	$a1 $v0
   		jal 	operation_integer_multiplication_init
   		b  	calculator_integer_loop_end
   		
   	Div_int:
   		jal 	read_int
   		move 	$a1 $v0
   		beqz 	$a1 Div_int_err
   		jal 	operation_integer_division
   		b  	calculator_integer_loop_end
   		
   		Div_int_err:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
   			j 	Div_int
   		
   	Min_int:
   		jal 	read_int
   		move 	$a1 $v0
   		jal 	operation_integer_minimum
   		b  	calculator_integer_loop_end

   	Max_int:
   		jal 	read_int
   		move 	$a1 $v0
   		jal 	operation_integer_maximum
   		b  	calculator_integer_loop_end
   		
   	Pow_int:
   		jal 	read_int
   		move 	$a1 $v0
   		jal 	operation_init_int_pow
   		b  	calculator_integer_loop_end
   		
   	Abs_int:
   		jal 	operation_integer_abs		# va exectuer le calcul et retourner le resultat, pour une operande
   		b  	calculator_integer_loop_end		# pareil pour facto float double fibo prime bin hexa
   		
   	Opp_int:
   		jal 	operation_integer_opp
   		b  	calculator_integer_loop_end
   		
   	Facto_int:
   		bge 	$a0 17 Facto_int_err		# erreur si 17 <= x
   		blt 	$a0 1 Facto_int_err_minus	# erreur si x < 0
   		jal 	operation_init_int_facto
   		b  	calculator_integer_loop_end
   		
   		Facto_int_err:
   			la 	$a0 string_erreur_facto
  			jal 	print_string_stderr
   			jal 	read_int
   			move 	$a0 $v0
   			j 	Facto_int
   			
   		Facto_int_err_minus:
   			la 	$a0 string_erreur_minus
  			jal 	print_string_stderr
   			jal 	read_int
   			move 	$a0 $v0
   			j 	Facto_int
   		
   	Reset_int:
   		jal 	operation_integer_reset  	# retourne 0
   		b  	calculator_integer_loop_end
   			
   	Float_int:					# convert de int a float
   		li 	$t9 1
   		mtc1 	$s0 $f0
   		cvt.s.w $f0 $f0
   		j 	calculator_float
   		
   	Double_int:					# convert de int a double
   		li 	$t9 1
   		mtc1 	$s0 $f0
   		cvt.d.w $f0 $f0
   		j 	calculator_double
   		
   	Fibo_int:
   		bge 	$a0 47 Fibo_int_err_plus	# erreur si 47 <= x
   		blt 	$a0 0 Fibo_int_err_minus	# erreur so x < 0
   		jal 	operation_test_int_fibo
   		b  	calculator_integer_loop_end
   		
   		Fibo_int_err_plus:
   			la 	$a0 string_erreur_fibo
  			jal 	print_string_stderr
   			jal 	read_int
   			move 	$a0 $v0
   			j 	Fibo_int
   			
   		Fibo_int_err_minus:
   			la 	$a0 string_erreur_minus
  			jal 	print_string_stderr
   			jal 	read_int
   			move 	$a0 $v0
   			j 	Fibo_int
   	
   	Pgcd_int:
   		move 	$s5 $a0					# copie 1ere operande dans s5
   		jal 	read_int
   		move 	$a1 $v0					# stocke 2eme operande dans a1
   		move 	$s6 $v0					# copie 2eme operande dans s6
   		
   		Pgcd_int_test:
   			beqz 	$a0 Pgcd_int_err 		# Si a0 = 0 demande une nouvelle operande
   			beqz 	$a1 Pgcd_int_err_for_a		# Si a1 = 0 demande une nouvelle operande
   			jal 	operation_integer_init_pgcd
   			b  	calculator_integer_loop_end
   			
   		Pgcd_int_err:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
   			jal 	read_int
   			move 	$a0 $v0
   			move 	$s5 $a0
   			move 	$a1 $s6
   			j 	Pgcd_int_test
   			
   		Pgcd_int_err_for_a:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
  			move 	$a0 $s5
  			j 	Pgcd_int
   		
   	Mod_int:
   		jal 	read_int	
   		move 	$a1 $v0					
   		beqz 	$a1 Mod_int_err			# Si 2eme operande est 0, demande nouvelle
   		jal 	operation_integer_mod
   		b  	calculator_integer_loop_end
   		
   		Mod_int_err:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
   			j 	Mod_int
   	
   	Prime_int:
   		jal 	operation_integer_prime_init
   		b  	calculator_integer_loop_end
	
   	Bin_int:
   		jal	operation_integer_bin_init
   		jal	print_newline
   		li	$v0 10					# Fin du programme apres conversion
   		syscall	
   		
   	Hexa_int:
   		li	$t1 8					# taille 8
   		la 	$s3 hexadecimal				# stocke string hexadecimal dans s3
   		jal 	operation_integer_hexa_init
   		la 	$a0 hexadecimal 			
		jal 	print_string
   		li	$v0 10					# Fin du programme apres conversion
   		syscall
   		
calculator_integer_loop_end:
      	move 	$s0 $v0						# copie
      	move 	$a0 $v0
      	jal 	print_int					# affichage resultat et retour a la ligne
      	jal 	print_newline

	# Line 210
      	j 	calculator_integer_loop				# recommence

calculator_integer_exit:
	lw 	$ra 0($sp)
	lw 	$a0 4($sp)
    	lw 	$a1 8($sp)
   	lw 	$a2 12($sp)
    	lw 	$s0 16($sp)
    	lw 	$s1 20($sp)
    	lw 	$s2 24($sp)
    	lw 	$s3 28($sp)
    	addu 	$sp $sp 32
    	jr 	$ra

###################################################################################################
# Calculator main : FLOAT === Tests : 540 a 625 === Pre-calcul : 630 a 740 === Calculs : 1735 a 1950
###################################################################################################

calculator_float:
  	subu 	$sp $sp 24
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)
  	swc1 	$f0 8($sp)
  	swc1 	$f12 12($sp)
  	swc1 	$f13 16($sp)
  	swc1 	$f3 20($sp)

	# Debugging info (float mode) on stderr
	la 	$a0 string_calculator
  	jal 	print_string_stderr
  	
  	la 	$a0 string_float
  	jal 	print_string_stderr
  	
  	jal 	print_newline_stderr
  	beq 	$t9 1 calculator_float_print		# si t9 = 1 : saut
  
calculator_float_start:					# sinon, demande une 1ere operande
    	jal 	read_float	
    	mov.s 	$f3 $f0
    	j 	calculator_float_loop
    
calculator_float_print:					# si 1, copie resultat en 1ere operande
    	mov.s 	$f3 $f0
    	mov.s 	$f12 $f0
    	jal 	print_float
    	jal 	print_newline

# Calculator loop  
calculator_float_loop:    
    	li 	$v0 8 					# demande un operateur
   	la 	$a0 operation
    	li 	$a1 25
    	syscall
    	
    	li 	$v0 0					# Initalise a 0
    	mov.s 	$f12 $f3				# copie 1ere operande stockee dans f12
    	
    	la 	$a1 operation				# stocke string operateur dans a1
    	lb 	$t0 operation				# stocke premier bit dans t0
    	
    	lb 	$t1 plus				# compare bit "+" avec t0, si 1 alors calcule
    	beq 	$t0 $t1 Add_float				# Pareil pour "-" ; "*"; "/"
    	
    	lb 	$t1 minus
    	beq 	$t0 $t1 Sub_float
    	
    	lb 	$t1 multi
    	beq 	$t0 $t1 Mul_float
    	
    	lb 	$t1 divi
    	beq 	$t0 $t1 Div_float
    	
    	la 	$a0 string_abs				# compare string "abs" avec operateur
  	jal 	simple_strncmp				
    	bnez 	$v0 Abs_float				# Si 1, alors calcule
    	
    	la 	$a0 string_max				# Pareil pour "max" ; "min" ; "pow" ; "opp" ; "inv" ; "expo" ; "\n"
  	jal 	simple_strncmp					# "reset" ; "integer" ; "double" ; "ln" ; "sqrt" ; "round"
    	bnez 	$v0 Max_float
    		  	
  	la 	$a0 string_min
  	jal 	simple_strncmp
    	bnez 	$v0 Min_float
    	
    	la 	$a0 string_pow
  	jal 	simple_strncmp
    	bnez 	$v0 Pow_float
    	
    	la 	$a0 string_opp
  	jal 	simple_strncmp
    	bnez 	$v0 Opp_float
    	
    	la 	$a0 string_inv
  	jal 	simple_strncmp
    	bnez 	$v0 Inv_float	
    	
    	la 	$a0 string_expo
  	jal 	simple_strncmp
    	bnez 	$v0 Expo_float
    	
    	la 	$a0 string_reset
  	jal 	simple_strncmp
    	bnez 	$v0 Reset_float
    	
    	la 	$a0 string_integer
    	jal 	simple_strncmp
    	bnez 	$v0 Int_float
    	
    	la 	$a0 string_double
    	jal 	simple_strncmp
    	bnez 	$v0 Double_float
    	
   	la 	$a0 string_ln
    	jal 	simple_strncmp
    	bnez 	$v0 Ln_float
   	
   	la 	$a0 string_sqrt
    	jal 	simple_strncmp
    	bnez 	$v0 Sqrt_float
    	
    	la 	$a0 string_round
    	jal 	simple_strncmp
    	bnez 	$v0 Round_float
    	
    	la 	$a0 string_newline
    	jal 	simple_strncmp
    	bnez 	$v0 program_exit
    	
    	la 	$a0 string_unknown			# Si toujours 0, affiche inconnu et recommence boucle
   	li 	$v0 4
   	syscall
   	
   	b calculator_float_loop
    	
	Add_float:					# Demande deuxieme operande
   		jal 	read_float			# copie dans a1
   		mov.s 	$f13 $f0			# execute l addition
   		jal 	operation_float_addition	# retourne le resultat
   		b  	calculator_float_loop_end

	Sub_float:					# Pareil pour fonction a deux operandes :#	+ - * / min max pow
   		jal 	read_float			#	+ - * / min max pow
   		mov.s 	$f13 $f0
   		jal 	operation_float_substraction
   		b  	calculator_float_loop_end
   		
	Mul_float:
   		jal 	read_float
   		mov.s 	$f13 $f0
   		jal 	operation_float_multiplication
   		b  	calculator_float_loop_end
   		
   	Div_float:
   		l.s 	$f10 fp0
   		jal 	read_float
   		mov.s 	$f13 $f0
   		c.eq.s 	$f13 $f10			# division par 0 impossible, demande une nouvelle operande
   		bc1t 	Div_float_err
   		jal 	operation_float_division
   		b  	calculator_float_loop_end
   		
   		Div_float_err:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
   			j 	Div_float
   		
   	Min_float:					
   		jal 	read_float
   		mov.s 	$f13 $f0
   		jal 	operation_float_minimum
   		b  	calculator_float_loop_end

   	Max_float:
   		jal 	read_float
   		mov.s 	$f13 $f0
   		jal 	operation_float_maximum
   		b  	calculator_float_loop_end
   		
   	Pow_float:
   		jal 	read_float
   		mov.s 	$f13 $f0
   		jal 	operation_float_pow_init
   		b  	calculator_float_loop_end
   		
   	Abs_float:
   		jal 	operation_float_abs
   		b  	calculator_float_loop_end
   		
   	Opp_float:
   		jal 	operation_float_opp
   		b  	calculator_float_loop_end
   		
   	Ln_float:
   		l.s 	$f10 fp1
   		c.lt.s 	$f12 $f10				# impossible si x < 1, demande nouvelle operande
   		bc1t 	Ln_float_err
   		jal 	operation_init_float_ln
   		b 	calculator_float_loop_end
   		
   		Ln_float_err:
   			la 	$a0 string_erreur_ln
  			jal 	print_string_stderr
   			jal 	read_float
   			mov.s 	$f12 $f0
   			j 	Ln_float
   		
   	Inv_float:						# division par 0 impossible, demande nouvelle operande
   		l.s 	$f10 fp0
   		c.eq.s 	$f12 $f10
   		bc1t 	Inv_float_err
   		jal 	operation_float_inv
   		b  	calculator_float_loop_end
   		
   		Inv_float_err:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
   			jal 	read_float
   			mov.s 	$f12 $f0
   			j 	Inv_float
   		
   	Expo_float:					
   		jal 	operation_float_expo
   		b  	calculator_float_loop_end
   		
   	Reset_float:
   		jal 	operation_float_reset
   		b  	calculator_float_loop_end
   		
   	Int_float:					# conversion de float a integer
   		li 	$t9 1
   		cvt.w.s $f12, $f12
		mfc1 	$s0,$f12
   		j 	calculator_integer
   		
   	Double_float:					# conversion de float a double
   		li 	$t9 1
   		cvt.d.s $f0, $f0
   		j 	calculator_double
   		
   	Round_float:					# arrondis
   		jal 	operation_float_round
   		b  	calculator_float_loop_end
   			
   	Sqrt_float:					# valeur absolue
   		jal 	operation_float_sqrt
   		b  	calculator_float_loop_end

calculator_float_loop_end:
  	mov.s 	$f3 $f0					# copie
      	mov.s 	$f12 $f0
      	jal 	print_float				# affichage resultat et retour a la ligne
      	jal 	print_newline

      	j 	calculator_float_loop			# recommence

calculator_float_exit:
    	lw 	$ra 0($sp)
    	lw 	$a0 4($sp)
    	lwc1 	$f0 8($sp)
    	lwc1 	$f12 12($sp)
    	lwc1 	$f13 16($sp)
    	lwc1 	$f3 20($sp)
    	addu 	$sp $sp 24
    	jr 	$ra
    	
#####################################################################################################
# Calculator main : DOUBLE === Tests : 800 a 880 === Pre-calcul : 880 a 1000 === Calculs : 1955 a 2160
#####################################################################################################
    
calculator_double:
  	subu 	$sp $sp 24
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)
  	swc1 	$f0 8($sp)
  	swc1 	$f12 12($sp)
  	swc1 	$f14 16($sp)
  	swc1 	$f4 20($sp)

	# Debugging info (double mode) on stderr
  	la 	$a0 string_calculator
  	jal 	print_string_stderr
  	
  	la 	$a0 string_double
  	jal 	print_string_stderr
  	
  	jal 	print_newline_stderr
  	beq 	$t9 1 calculator_double_print		# si t9 = 1 : saut
  
calculator_double_start:				# sinon on fonctionne normalement
    	jal 	read_double
    	mov.d 	$f4 $f0
    	j 	calculator_double_loop
    
calculator_double_print:				# si 1, on recupere la valeur pre enregistree via switch
    	mov.d 	$f4 $f0
    	mov.d 	$f12 $f0
    	jal 	print_double
    	jal 	print_newline
 
# Calculator loop   	
calculator_double_loop:
    
    	li 	$v0 8 					# Demande un operateur
   	la 	$a0 operation
    	li 	$a1 25
    	syscall
    	
    	li 	$v0 0					# intialise a 0
    	mov.d 	$f12 $f4				# copie premiere operande enregistre dans f12
    	
    	la 	$a1 operation				# stocke string operateur dans a1
    	lb 	$t0 operation				# stocke 1er bit operateur dans t0
    	
    	lb 	$t1 plus				# compare le premier bit de operateur avec "+"
    	beq 	$t0 $t1 Add_double			# si 1, alors calcule
    	
    	lb 	$t1 minus				# pareil pour - * /
    	beq 	$t0 $t1 Sub_double
    	
    	lb 	$t1 multi
    	beq 	$t0 $t1 Mul_double
    	
    	lb 	$t1 divi
    	beq 	$t0 $t1 Div_double
    	
    	la 	$a0 string_abs				# compare string "abs" avec operateur
  	jal 	simple_strncmp
    	bnez 	$v0 Abs_double				# Si 1, alors calcule
    	
    	la 	$a0 string_max				# Pareil pour "max" ; "min" ; "pow" ; "opp" ; "inv" ; "expo" ; "\n"
  	jal 	simple_strncmp					# "reset" ; "integer" ; "double" ; "ln" ; "sqrt" ; "round"
    	bnez 	$v0 Max_double
    		  	
  	la 	$a0 string_min
  	jal 	simple_strncmp
    	bnez 	$v0 Min_double
    	
    	la 	$a0 string_pow
  	jal 	simple_strncmp
    	bnez 	$v0 Pow_double
    	
    	la 	$a0 string_opp
  	jal 	simple_strncmp
    	bnez 	$v0 Opp_double
    	
    	la 	$a0 string_inv
  	jal 	simple_strncmp
    	bnez 	$v0 Inv_double	
    	
    	la 	$a0 string_expo
  	jal 	simple_strncmp
    	bnez 	$v0 Expo_double
    	
    	la 	$a0 string_reset
  	jal 	simple_strncmp
    	bnez 	$v0 Reset_double
    	
    	la 	$a0 string_integer
    	jal 	simple_strncmp
    	bnez 	$v0 Int_double
    	
    	la 	$a0 string_float
    	jal 	simple_strncmp
    	bnez 	$v0 Float_double
    	
   	la 	$a0 string_ln
    	jal 	simple_strncmp
    	bnez 	$v0 Ln_double
   	
   	la 	$a0 string_sqrt
    	jal 	simple_strncmp
    	bnez 	$v0 Sqrt_double
    	
    	la 	$a0 string_round
    	jal 	simple_strncmp
    	bnez 	$v0 Round_double
    	
    	la 	$a0 string_newline
    	jal 	simple_strncmp
    	bnez 	$v0 program_exit
    	
    	la 	$a0 string_unknown
   	li 	$v0 4						# Si toujours 0, affiche inconnu et recommence boucle
   	syscall
   	
   	b calculator_double_loop
    	
	Add_double:						# Demande deuxieme operande
   		jal 	read_double				# copie dans a1
   		mov.d 	$f14 $f0				# execute l addition
   		jal 	operation_double_addition		# retourne le resultat
   		b  	calculator_double_loop_end

	Sub_double:						# Pareil pour fonction a deux operandes : + - * / min max pow
   		jal 	read_double
   		mov.d 	$f14 $f0
   		jal 	operation_double_substraction
   		b  	calculator_double_loop_end
   		
	Mul_double:
   		jal 	read_double
   		mov.d 	$f14 $f0
   		jal 	operation_double_multiplication
   		b  	calculator_double_loop_end
   		
   	Div_double:							# division par 0 impossible, demande une nouvelle operande
   		l.d 	$f10 dp0
   		jal 	read_double
   		mov.d 	$f14 $f0
   		c.eq.d 	$f14 $f10
   		bc1t 	Div_double_err
   		jal 	operation_double_division
   		b  	calculator_double_loop_end
   		
   		Div_double_err:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
   			j 	Div_double
   		
   	Min_double:
   		jal 	read_double
   		mov.d 	$f14 $f0
   		jal 	operation_double_minimum
   		b  	calculator_double_loop_end

   	Max_double:
   		jal 	read_double
   		mov.d 	$f14 $f0
   		jal 	operation_double_maximum
   		b  	calculator_double_loop_end
   		
   	Pow_double:
   		jal 	read_double
   		mov.d 	$f14 $f0
   		jal 	operation_double_pow_init
   		b  	calculator_double_loop_end
   		
   	Abs_double:
   		jal 	operation_double_abs
   		b  	calculator_double_loop_end
   		
   	Opp_double:
   		jal 	operation_double_opp
   		b  	calculator_double_loop_end
   		
   	Ln_double:						# impossible pour x < 1
   		l.d 	$f10 dp1
   		c.lt.d 	$f12 $f10
   		bc1t 	Ln_double_err
   		jal 	operation_init_double_ln
   		b 	calculator_double_loop_end
   		
   		Ln_double_err:
   			la 	$a0 string_erreur_ln
  			jal 	print_string_stderr
   			jal 	read_double
   			mov.d 	$f12 $f0
   			j 	Ln_double
   		
   	Inv_double:						# division par 0 impossible, demande nouvelle operande
   		l.d 	$f10 dp0
   		c.eq.d 	$f12 $f10
   		bc1t 	Inv_double_err
   		jal 	operation_double_inv
   		b  	calculator_double_loop_end
   		
   		Inv_double_err:
   			la 	$a0 string_erreur
  			jal 	print_string_stderr
   			jal 	read_double
   			mov.d 	$f12 $f0
   			j 	Inv_double
   		
   	Expo_double:
   		jal 	operation_double_expo
   		b  	calculator_double_loop_end
   		
   	Reset_double:						# retourne 0 en premiere operande
   		jal 	operation_double_reset
   		b  	calculator_double_loop_end
   		
   	Int_double:						# conversion de double a integer
   		li 	$t9 1
   		cvt.w.d $f12, $f12
		mfc1 	$s0,$f12
   		j 	calculator_integer
   		
   	Float_double:						# conversion de double a float
   		li 	$t9 1
   		cvt.s.d $f0, $f0
   		j 	calculator_float
   		
   	Round_double:						# round double
   		jal 	operation_double_round
   		b  	calculator_double_loop_end
   		
   	Sqrt_double:		
   		jal 	operation_double_sqrt
   		b  	calculator_double_loop_end

calculator_double_loop_end:
      	mov.d 	$f4 $f0						# copie
      	mov.d 	$f12 $f0
      	jal 	print_double					# affiche resultat et retour a la ligne
      	jal 	print_newline

      	j 	calculator_double_loop				# boucle

calculator_double_exit:
    	lw 	$ra 0($sp)
    	lw 	$a0 4($sp)
    	lwc1 	$f0 8($sp)
    	lwc1 	$f12 12($sp)
    	lwc1 	$f14 16($sp)
    	lwc1 	$f4 20($sp)
    	addu 	$sp $sp 24
    	jr 	$ra

################################################################################
# CLI
################################################################################

## Handle CLI arguments (currently just prints them...)
##
## Inputs:
## $a0: argc
## $a1: argv
##
## Outputs:
## $v0: 0 if we choose integer mode, 1 if we choose float mode

handle_cli_args:
  	subu 	$sp $sp 20
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)
  	sw 	$a1 8($sp)
  	sw 	$s0 12($sp)
  	sw 	$s1 16($sp)

	# Copy argc and argv in $s0 and $s1
  	move 	$s0 $a0
  	move 	$s1 $a1
  	# Set default return value
  	li 	$v0 0

	handle_cli_args_loop:
    		beq 	$s0 $0 handle_cli_args_exit		# Si pas d'argument : fin ; sinon :

    	# Debugging info on stderr
    	handle_cli_args_loop_debug:
    		# Print the prefix "arg: "
      		la 	$a0 string_arg				
      		jal 	print_string_stderr			
      		# Print current arg on stderr
      		lw 	$a0 ($s1)			
      		jal 	print_string_stderr
      		jal 	print_space_stderr
      		jal 	print_newline_stderr
      	
      	# Process the current argument	
    	handle_cli_args_loop_current_arg_handling:
      		lw 	$a0 0($s1)
      
      		la 	$a1 string_float			# si arg = a1 alors float
      		jal 	simple_strncmp
      		bnez 	$v0 calculator_float
      
      		la 	$a1 string_double			# si arg = a1 alors double
      		jal 	simple_strncmp
      		bnez 	$v0 calculator_double
      
      		j calculator_integer				# sinon integer
      

	# Move on to the next argument (akin to argc--, argv++)
	handle_cli_args_loop_end:
      		add 	$s0 $s0 -1
      		add 	$s1 $s1 4
      		j 	handle_cli_args_loop

handle_cli_args_exit:
   	lw 	$ra 0($sp)
   	lw 	$a0 4($sp)
    	lw 	$a1 8($sp)
    	lw 	$s0 12($sp)
    	lw 	$s1 16($sp)
    	addu 	$sp $sp 20
    	jr 	$ra

################################################################################
# I/O
################################################################################

#-------------------------------------------------------------------------------
# stdout
#-------------------------------------------------------------------------------

## Print a string on stdout
##
## Inputs:
## $a0: string
##
## Outputs:
## none

print_string:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	li 	$v0 4
  	syscall

  	print_string_exit:
   	 	lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra
   
## Print a newline on stdout
##
## Inputs:
## none
##
## Outputs:
## none
 		
print_newline:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	la 	$a0 string_newline
  	jal 	print_string

  	print_newline_exit:
   	 	lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

## Print a space on stdout
##
## Inputs:
## none
##
## Outputs:
## none

print_space:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	la 	$a0 string_space
  	jal 	print_string

  	print_space_exit:
    		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra
 
## Print an integer on stdout
##
## Inputs:
## $a0: integer
##
## Outputs:
## none
   		
print_int:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	li 	$v0 1
  	syscall

  	print_int_exit:
    		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

## Print a float (single precision) on stdout
##
## Inputs:
## $f12: float
##
## Outputs:
## none

print_float:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	swc1 	$f12 4($sp)

  	li 	$v0 2
  	syscall

  	print_float_exit:
    		lw 	$ra 0($sp)
    		lwc1 	$f12 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

## Print a double (double precision) on stdout
##
## Inputs:
## $f12: double
##
## Outputs:
## none

print_double:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	swc1 	$f12 4($sp)

  	li 	$v0 3
  	syscall

  	print_double_exit:
    		lw 	$ra 0($sp)
    		lwc1 	$f12 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra
    
#-------------------------------------------------------------------------------
# stderr
#-------------------------------------------------------------------------------

## Print a string on stderr
##
## Inputs:
## $a0: string
##
## Outputs:
## none

print_string_stderr:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	jal 	strlen
  	move 	$a2 $v0
  	move 	$a1 $a0
  	li 	$a0 2
	# syscall 15 (write to file)
 	# a0: file descriptor
  	# a1: address of buffer
  	# a2: number of characters to write
  	li 	$v0 15
  	syscall

  	print_string_stderr_exit:
    		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

## Print a newline on stderr
##
## Inputs:
## none
##
## Outputs:
## none

print_newline_stderr:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	la 	$a0 string_newline
  	jal 	print_string_stderr

  	print_newline_stderr_exit:
    	lw 	$ra 0($sp)
    	lw 	$a0 4($sp)
    	addu 	$sp $sp 8
    	jr 	$ra

## Print a space on stderr
##
## Inputs:
## none
##
## Outputs:
## none

print_space_stderr:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	la 	$a0 string_space
  	jal 	print_string_stderr

  	print_space_stderr_exit:
    		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

print_result_prefix:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	la 	$a0 string_output_prefix
  	jal 	print_string_stderr

  	print_result_prefix_exit:
   		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

#-------------------------------------------------------------------------------
# misc.
#-------------------------------------------------------------------------------

## Read an integer
##
## Inputs:
## none
##
## Outputs:
## $v0: read integer

read_int:
  	li 	$v0 5
  	syscall
  	jr 	$ra

## Read a float
##
## Inputs:
## none
##
## Outputs:
## $f0: read float

read_float:
  	li 	$v0 6
  	syscall
  	jr 	$ra

## Read a double
##
## Inputs:
## none
##
## Outputs:
## $f0: read double

read_double:
  	li 	$v0 7
  	syscall
  	jr 	$ra
  
################################################################################
# Strings
################################################################################

## Ignore spaces in a string
##
## Inputs:
## $a0: null terminated string
##
## Outputs:
## $v0: first non-space character

ignore_spaces:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	la 	$t0 space
  	lb 	$t0 0($t0)

  	move 	$v0 $a0
  	
  	ignore_spaces_loop:
    		lb 	$t1 0($v0)
    		beq 	$t0 $0 ignore_spaces_exit
    		bne 	$t0 $t1 ignore_spaces_exit
    		addu 	$v0 $v0 1
    		j 	ignore_spaces_loop

  	ignore_spaces_exit:
    		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

## strlen
##
## Inputs:
## $a0: input null terminated string
##
## Outputs:
## $v0: string length

strlen:
  	subu 	$sp $sp 8
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)

  	move 	$v0 $0

  	strlen_loop:
    		lb 	$t1 0($a0)
    		beq 	$t1 $0 strlen_exit
    		add 	$v0 $v0 1
    		add 	$a0 $a0 1
    		j 	strlen_loop

  	strlen_exit:
    		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		addu 	$sp $sp 8
    		jr 	$ra

## Simplified strncmp
##
## Simplified strncmp outputs a boolean value as opposed to the common behaviour
## (Usually it outpus 0 for perfect match or either a negative or positive
## value if the (sub)strings do not exactly match)
##
## Inputs:
## $a0: string 1
## $a1: string 2
## $a2: n
##
## Outputs:
## $v0: boolean

simple_strncmp:
  	subu 	$sp $sp 16
  	sw 	$ra 0($sp)
  	sw 	$a0 4($sp)
  	sw 	$a1 8($sp)
  	sw 	$a2 12($sp)

  	# Initialize result to true
  	li 	$v0 1
  
  	jal 	strlen
  	move 	$a2 $v0
  
  	simple_strncmp_loop:
    		# Have we compared n characters?
    		ble 	$a2 $0 simple_strncmp_exit

    		# Load the characters for comparison
    		lb 	$t0 0($a0)
    		lb 	$t1 0($a1)

    		bne 	$t0 $t1 simple_strncmp_false
    		addi 	$a0 $a0 1
    		addi 	$a1 $a1 1
    		addi 	$a2 $a2 -1
    		j 	simple_strncmp_loop

  		simple_strncmp_exit_of_string:
   			 # (Sub)Strings match
    			li 	$v0 1
    			j 	simple_strncmp_exit

  	simple_strncmp_false:
    		# (Sub)Strings do not match
    		li 	$v0 0
    		j 	simple_strncmp_exit

  	simple_strncmp_exit:
    		lw 	$ra 0($sp)
    		lw 	$a0 4($sp)
    		lw 	$a1 8($sp)
    		lw 	$a2 12($sp)
    		addu 	$sp $sp 16
    		jr 	$ra

################################################################################
# Integer Operations : 1485 a 1735
################################################################################

## Inputs:
## $a0: operand 1
## $a1: operand 2
##
## Outputs:
## $v0: $a1 + $a2

######################
# ==== Addition ==== #
######################

operation_integer_addition:
  	add 	$v0 $a0 $a1
  	jr 	$ra

##########################
# ==== Substraction ==== #
##########################

operation_integer_substraction:
  	sub 	$v0 $a0 $a1
  	jr 	$ra

###################################
# ==== Binary Multiplication ==== #
###################################

operation_integer_multiplication_init:
	li 	$v0 0
	operation_integer_multiplication:
    		andi 	$t0 $a1 1		# Si a1 =1 alors t0 = 1, sinon t0 =0
    		beq 	$t0 $zero clear		# Si t0 = 0, saut dans clear
    		addu 	$v0 $v0 $a0  		# sinon v0 = v0 + a0
	clear:
    		sll 	$a0 $a0 1     		# multiplie a0 par 2
    		srl 	$a1 $a1 1     		# divise a1 par 2
    		bne 	$a1 $zero operation_integer_multiplication	# while a1 != 0, boucle
   		jr 	$ra			# return
   		
######################
# ==== Division ==== #
######################

operation_integer_division:
  	div 	$v0 $a0 $a1
  	jr 	$ra

#####################
# ==== Minimum ==== #
#####################

operation_integer_minimum:	
  	move 	$v0 $a0				# initialise min = a0
  	bgt 	$a0 $a1 ope_int_mini		# si a0 > a1, saute et return min = a1
  	jr 	$ra				
	ope_int_mini:
  		move 	$v0 $a1
  		jr 	$ra
  		
#####################
# ==== Maximum ==== #
#####################

operation_integer_maximum:
  	move 	$v0 $a1				# initialise max = a1	
  	bgt 	$a0 $a1 ope_int_maxi		# si a0 > a1, saute et return min = a0	
  	jr 	$ra				
	ope_int_maxi:
  		move 	$v0 $a0
  		jr 	$ra

###################
# ==== Power ==== #				
###################

operation_init_int_pow:
  	li 	$v0 1
  	li 	$t0 1
	operation_integer_pow:
  		beqz 	$a1 jrra			# si x = 0, return, sinon :
  		bltz 	$a1 operation_integer_pow_inf	# si x < 0, saute	
  		mul 	$v0 $v0 $a0			# sinon, x*x et y--, boucle						
  		add 	$a1 $a1 -1				
  		j 	operation_integer_pow
	operation_integer_pow_inf:			# abs(f13), x*x, y--, v0 = 1/x, boucle
  		abs 	$a1 $a1
  		beqz 	$a1 jrra
  		mul 	$t0 $t0 $a0
  		div 	$v0 $v0 $t0
  		add 	$a1 $a1 -1
  		j operation_integer_pow_inf

######################
# ==== Absolute ==== #
######################

operation_integer_abs:
  	abs 	$v0 $a0
  	jr 	$ra
 
######################
# ==== Opposite ==== #
######################
 
operation_integer_opp:
  	neg 	$v0 $a0
  	jr 	$ra

######################
# ==== Reminder ==== #
######################

operation_integer_mod:
  	div 	$a0 $a1
  	mfhi 	$v0			# reste de la division
  	jr 	$ra

###################
# ==== Reset ==== #
###################

operation_integer_reset:
  	li 	$v0 0			# resultat = 0
  	jr 	$ra

#######################
# ==== Factorial ==== #
#######################
	
operation_init_int_facto:
  	li 	$v0 1			# initialise resultat a 1
	operation_integer_facto:
 		blt 	$a0 1 jrra	# si 1ere operande = 1, return
  		mul 	$v0 $v0 $a0	# sinon, v0 = v0 * a0, a0 --, boucle
  		addi 	$a0 $a0 -1	 
  		j 	operation_integer_facto
  		
#######################
# ==== Fibonacci ==== #
#######################

operation_test_int_fibo:
  	li 	$v0 0			# initialise resultat a 0
  	beqz 	$a0 jrra		# si 1ere operande = 0, return
  	li 	$v0 1			# sinon, intialise resultat a 1
  	beq 	$a0 1 jrra 		# si 1ere operande = 1,, return
	operation_init_int_fibo:	# sinon, initalise deux premieres variables de la suite :
  		li 	$t0 0		
  		li 	$t1 1
	operation_integer_fibo:
  		beq 	$a0 1 jrra	# si a0 = 1, return
  		add 	$v0 $t0 $t1	# sinon, v0 = t0 + t1, a0 --
  		add 	$a0 $a0 -1	
  		move 	$t0 $t1		# t0 = t1 et t1 = v0
  		move 	$t1 $v0		
  		j 	operation_integer_fibo	# boucle
  		
##################
# ==== PGCD ==== #
##################

operation_integer_init_pgcd:
  	jal 	operation_integer_maximum	# maximum dans t0
  	move 	$t0 $v0
  	jal 	operation_integer_minimum	# minimum dans t1
  	move 	$t1 $v0
	operation_integer_pgcd:
  		div 	$t0 $t1
  		mfhi 	$t2			# reste dans t2
  		mflo 	$t6			# quotient dans t6
  		mul 	$t5 $t1 $t6		# t5 = max * quotient
  		beq 	$t5 $t0 int_endtest_pgcd	# si t5 = 0, saute
  		move 	$t0 $t1			# sinon, ancien min devient max 
  		move 	$t1 $t2				# reste devient min
  		j 	operation_integer_pgcd	# boucle
	int_endtest_pgcd:
  		li 	$v1 1			
  		add 	$v0 $zero $t1		# res = min
  		b 	calculator_integer_loop_end	# return

###################
# ==== Prime ==== #
###################

operation_integer_prime_init:
	li	$t0 2			# initialise t0 = 2
	operation_integer_prime_test:
		slt	$t1 $t0 $a0	# t1 = 1 si 2 < a0			
		bne	$t1 $zero operation_integer_prime	# sinon	saute
		move	$v0 $a0		# v0 = a0	
		jr	$ra		# return						
	operation_integer_prime:						
		div	$a0 $t0					
		mfhi	$t3		# reste de a0/t0				
		slti	$t4 $t3 1	# t4 = 1 si t3 < 1 alors v0 = 0 (pas premier)			
		beq	$t4 1 operation_integer_prime_fin	
		addi 	$t0 $t0 1	# sinon, t0 ++ et boucle			
		j	operation_integer_prime_test							
	operation_integer_prime_fin:		
		li	$v0 0				
		jr	$ra

####################
# ==== Binary ==== #				# Affichage bit par bit
####################
		
operation_integer_bin_init:
	move 	$t0 $a0		# t0 = a0
	li 	$t1 0		# t1 = 0, t3 = 1
	li 	$t3 1
	sll 	$t3 $t3 31	# t3 = t3 * 2 (31 fois)
	li 	$t4 32		# t4 = 32 (compteur)
	operation_integer_bin_loop:
		and 	$t1 $t0 $t3	# t1 = 1 si premier bit : t0 = t3 
		beq 	$t1 $zero operation_integer_bin_end # sinon affiche 0
		li 	$t1 1		# alors affiche 1
	operation_integer_bin_end:
		li 	$v0 1
		move 	$a0 $t1
		syscall			# affichage t1
		srl	$t3 $t3 1	# divise t3 par 2
		addi 	$t4 $t4 -1	# t4--
		bne 	$t4 $zero operation_integer_bin_loop # si t4 = 0a alors return, sinon boucle
		jr 	$ra

#########################
# ==== Hexadecimal ==== #
#########################
	
operation_integer_hexa_init:
	beq 	$t1 $zero operation_integer_hexa_end		# si t1 = 0, return
	rol 	$a0 $a0 4					# decale a0 de 4 bit vers la gauche
	and 	$t3 $a0 0xf					# si 1er caractere $a0 != 0 alors $t3 = $a0 (le premier caractere)			
	ble 	$t3 9 operation_integer_hexa_add		# si : $t3 <= 9, alors $t3 = $t3 + 48 (en ASCII : 0 est 48, 9 est 57)
	addi 	$t3 $t3 55					# sinon : $t3 = $t3 + 55 (55+10=65, en ASCII : A est 65)
	operation_integer_hexa:
		sb 	$t3 0($s3)				# stocke $t3 dans $s3 hexadecimal
		addi 	$s3 $s3 1				# incremente l'adresse de $s3 de 1
		addi 	$t1 $t1 -1				# $t1 = $t1 - 1
		j 	operation_integer_hexa_init 		# boucle
	operation_integer_hexa_add: 
		addi 	$t3 $t3 48				# $t3 = $t3 + 48	
		j 	operation_integer_hexa			# boucle
	operation_integer_hexa_end:
		jr 	$ra					# return
	
################################################################################
# Floating Point Operations : 1735 a 1950
################################################################################

## Float addition
##
## Inputs
## $f12: first argument
## $f13: second argument
##
## Outputs
## $f0: $f12 + $f13

######################
# ==== Addition ==== #
######################
operation_float_addition:
  	add.s 	$f0 $f12 $f13
  	jr 	$ra
  	
##########################
# ==== Substraction ==== #
##########################

operation_float_substraction:
  	sub.s 	$f0 $f12 $f13
  	jr 	$ra
  	
############################
# ==== Multiplication ==== #
############################

operation_float_multiplication:
  	mul.s 	$f0 $f12 $f13				
  	jr 	$ra
  	
######################
# ==== Division ==== #
######################

operation_float_division:
  	div.s 	$f0 $f12 $f13
  	jr 	$ra
  	
#####################
# ==== Minimum ==== #			# Meme principe que pour integer
#####################

operation_float_minimum:	
  	mov.s 	$f0 $f13				
  	c.lt.s 	$f12 $f13
  	bc1t 	ope_float_mini			
  	jr 	$ra				
	ope_float_mini:
  		mov.s 	$f0 $f12
  		jr 	$ra
  		
#####################
# ==== Maximum ==== #			# Meme principe que pour integer
#####################

operation_float_maximum:
  	mov.s 	$f0 $f12				
  	c.lt.s 	$f12 $f13
  	bc1t 	ope_float_maxi			
  	jr 	$ra				
	ope_float_maxi:
  		mov.s 	$f0 $f13
  		jr 	$ra
  		
###################### 		
# ==== Absolute ==== #
######################

operation_float_abs:
  	abs.s 	$f0 $f12
  	jr 	$ra
  	
######################
# ==== Opposite ==== #
######################

operation_float_opp:
  	neg.s 	$f0 $f12
  	jr 	$ra

#####################
# ==== Reverse ==== #
#####################

operation_float_inv:
  	l.s 	$f10 fp1
  	div.s 	$f0 $f10 $f12		# v0 = 1 / f12
  	jr 	$ra
  	
#########################
# ==== Exponential ==== #	
#########################

operation_float_expo:
  	mov.s 	$f13 $f12		# copie f12 dans f13 (comme exposant)
  	l.s 	$f12 fpe		# set e comme premiere operande
  	j 	operation_float_pow_init	# calcule et retour de resultat via "Power"

###################
# ==== Reset ==== #
###################

operation_float_reset:
  	l.s 	$f0 fp0			# v0 = 0 et return
  	jr 	$ra
  	
#######################  	
# ==== Neper Log ==== #			# ln(x) = 2 * [ 1/ (2k+1)] * [( (x-1) / (x+1) ) ^ (2k+1)]
#######################

operation_init_float_ln:
	l.s 	$f20 fp0		# 0 1 2 5
	l.s 	$f21 fp1
	l.s 	$f22 fp2
	l.s 	$f25 fp5
	l.s 	$f1 fp0			# k = 0
	l.s 	$f0 fp0
operation_float_ln:
	c.eq.s 	$f1 $f25		# si k=5
	bc1t 	operation_float_ln_end
	mul.s 	$f10 $f1 $f22		# k = 2k
	add.s 	$f10 $f10 $f21		# k = 2k+1
	div.s 	$f15 $f21 $f10		# A : 1/2k+1
	sub.s 	$f16 $f12 $f21		# B : y-1
	add.s 	$f26 $f12 $f21		# C : y+1
	div.s 	$f16 $f16 $f26		# B : B/C
	mov.s 	$f27 $f10		# k' = k
	mov.s 	$f17 $f16
	j 	operation_float_ln_pow
	operation_float_ln_next:
		mul.s 	$f17 $f17 $f15	# B : B*A
		add.s 	$f0 $f0 $f17	# E : E+B
		add.s 	$f1 $f1 $f21	# k++
		mov.s 	$f10 $f21	# k = 1
		j 	operation_float_ln
	operation_float_ln_pow:
		c.eq.s 	$f27 $f21
		bc1t 	operation_float_ln_next # B = B^(2k+1)
		mul.s 	$f17 $f17 $f16
		sub.s 	$f27 $f27 $f21		# k'--
		j 	operation_float_ln_pow
	operation_float_ln_end:
		mul.s 	$f0 $f0 $f22
		jr 	$ra	
		
########################
# ==== Squareroot ==== #
########################
	
operation_float_sqrt:
	sqrt.s 	$f0 $f12
	jr 	$ra
	
###################
# ==== Power ==== #
###################

operation_float_pow_init:
	l.s 	$f0 fp1
	l.s 	$f20 fp0
	l.s 	$f21 fp1
	c.eq.s 	$f13 $f20			# si x = 0, return, sinon :
	bc1t 	operation_float_pow_null
	mov.s 	$f0 $f12
	operation_float_pow:
		c.lt.s 	$f13 $f20			# si x < 0, abs(f13) et t0 = 1, boucle a operation_float_pow
		bc1t 	operation_float_pow_inf	
		c.lt.s 	$f21 $f13			# si x > 1, x*x et y--, boucle a operation_float_pow
		bc1t 	operation_float_pow_sup	
	operation_float_pow_test:
		beq 	$t0 1 operation_float_pow_end
		jr 	$ra
	operation_float_pow_end:
		div.s 	$f0 $f21 $f0
		jr 	$ra
	operation_float_pow_null:
		mov.s 	$f0 $f21
		j 	operation_float_pow_test
	operation_float_pow_inf:
		abs.s 	$f13 $f13
		li 	$t0 1
		j 	operation_float_pow
	operation_float_pow_sup:
		mul.s 	$f0 $f0 $f12
		sub.s 	$f13 $f13 $f21
		j 	operation_float_pow	
		
###################
# ==== Round ==== #
###################

operation_float_round:
	l.s 	$f20 fp0
	l.s 	$f21 fp100
	l.s 	$f22 fp05
	mul.s 	$f12 $f12 $f21		# mulitiplie par 100, ajoute 0,5
	c.le.s 	$f20 $f12
	bc1t 	operation_float_round_next
	sub.s 	$f12 $f12 $f22
	operation_float_round_end:
		cvt.w.s $f0, $f0	# conversion en integer
		mfc1 	$s0 $f0
		mtc1 	$s0 $f0
		cvt.s.w $f0, $f0	# conversion en float
		jr 	$ra
	operation_float_round_next:
		add.s 	$f12 $f12 $f22
		j 	operation_float_round_end	# return

################################################################################
# Double Point Operations :	1955 a 2160
################################################################################

## Double addition
##
## Inputs
## $f12: first argument
## $f14: second argument
##
## Outputs
## $f0: $f12 + $f14

######################
# ==== Addition ==== #				!!! LE MODE DOUBLE EST EXACTEMENT PAREIL QUE LE MODE FLOAT POUR LES CALCULS !!!
######################					!!! SIMPLEMENT ADAPTE AVEC .d AU LIEU DE .s PAR EXEMPLE !!!

operation_double_addition:
  	add.d 	$f0 $f12 $f14
  	jr 	$ra

##########################
# ==== Substraction ==== #
##########################

operation_double_substraction:
  	sub.d 	$f0 $f12 $f14
  	jr 	$ra

############################
# ==== Multiplication ==== #
############################

operation_double_multiplication:
  	mul.d 	$f0 $f12 $f14				
  	jr 	$ra
  	
######################
# ==== Division ==== #
######################

operation_double_division:
  	div.d 	$f0 $f12 $f14
  	jr 	$ra

#####################
# ==== Minimum ==== #
#####################

operation_double_minimum:	
  	mov.d 	$f0 $f14				
  	c.lt.d 	$f12 $f14
  	bc1t 	ope_double_mini			
  	jr 	$ra				
	ope_double_mini:
  		mov.d 	$f0 $f12
  		jr 	$ra

#####################
# ==== Maximum ==== #
#####################

operation_double_maximum:
  	mov.d 	$f0 $f12				
  	c.lt.d 	$f12 $f14
  	bc1t 	ope_double_maxi			
  	jr 	$ra				
	ope_double_maxi:
  		mov.d 	$f0 $f14
  		jr 	$ra
  		
######################
# ==== Absolute ==== #
######################
 
operation_double_abs:
  	abs.d 	$f0 $f12
  	jr 	$ra

######################
# ==== Opposite ==== #
######################
  
operation_double_opp:
  	neg.d 	$f0 $f12
  	jr 	$ra

#####################
# ==== Reverse ==== #
#####################

operation_double_inv:
  	l.d 	$f10 dp1
  	div.d 	$f0 $f10 $f12
  	jr 	$ra

#########################
# ==== Exponential ==== #
#########################

operation_double_expo:
  	mov.d 	$f14 $f12
  	l.d 	$f12 dpe
  	j 	operation_double_pow_init
  
###################
# ==== Reset ==== #
###################

operation_double_reset:
  	l.d 	$f0 dp0
  	jr 	$ra
  	
#######################  	
# ==== Neper Log ==== #
#######################
 
operation_init_double_ln:
	l.d 	$f20 dp0		# 0 1 2 5
	l.d 	$f24 dp1
	l.d 	$f22 dp2
	l.d 	$f4 dp5
	l.d 	$f2 dp0		# k = 0
	l.d 	$f0 dp0
	operation_double_ln:
		c.eq.d 	$f2 $f4		# si k=5
		bc1t 	operation_double_ln_end
		mul.d 	$f10 $f2 $f22	# k = 2k
		add.d 	$f10 $f10 $f24	# k = 2k+1
		div.d 	$f14 $f24 $f10	# A : 1/2k+1
		sub.d 	$f16 $f12 $f24	# B : y-1
		add.d 	$f26 $f12 $f24	# C : y+1
		div.d 	$f16 $f16 $f26	# B : B/C
		mov.d 	$f28 $f10		# k' = k
		mov.d 	$f18 $f16
		j 	operation_double_ln_pow
	operation_double_ln_next:
		mul.d 	$f18 $f18 $f14	# B : B*A
		add.d 	$f0 $f0 $f18	# E : E+B
		add.d 	$f2 $f2 $f24	# k++
		mov.d 	$f10 $f24		# k = 1
		j 	operation_double_ln
	operation_double_ln_pow:
		c.eq.d 	$f28 $f24
		bc1t 	operation_double_ln_next # B = B^(2k+1)
		mul.d 	$f18 $f18 $f16
		sub.d 	$f28 $f28 $f24		# k'--
		j 	operation_double_ln_pow
	operation_double_ln_end:
		mul.d 	$f0 $f0 $f22
		jr 	$ra

########################
# ==== Squareroot ==== #
########################
	
operation_double_sqrt:
	sqrt.d 	$f0 $f12
	jr 	$ra

###################
# ==== Power ==== #
###################
	
operation_double_pow_init:
	l.d 	$f0 dp1
	l.d 	$f20 dp0
	l.d 	$f22 dp1
	c.eq.d 	$f14 $f20			# si x = 0
	bc1t 	operation_double_pow_null
	mov.d 	$f0 $f12
	operation_double_pow:
		c.lt.d 	$f14 $f20			# si x < 0
		bc1t 	operation_double_pow_inf	
		c.lt.d 	$f22 $f14			# si x > 1
		bc1t 	operation_double_pow_sup	
	operation_double_pow_test:
		beq 	$t0 1 operation_double_pow_end
		jr 	$ra
	operation_double_pow_end:
		div.d 	$f0 $f22 $f0
		jr 	$ra
	operation_double_pow_null:
		mov.d 	$f0 $f22
		j 	operation_double_pow_test
	operation_double_pow_inf:
		abs.d 	$f14 $f14
		li 	$t0 1
		j 	operation_double_pow
	operation_double_pow_sup:
		mul.d 	$f0 $f0 $f12
		sub.d 	$f14 $f14 $f22
		j 	operation_double_pow

###################
# ==== Round ==== #
###################
	
operation_double_round:
	round.w.d $f0 $f12
	cvt.d.w $f0 $f0
	jr 	$ra

#########################################
#	JUMP	BACK	LABEL		#
#########################################

jrra: 
  	jr $ra
