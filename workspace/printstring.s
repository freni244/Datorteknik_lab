;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Inargument: Pekare till str¨angen i a4
;;  L¨angd p˚a str¨angen i d5
printstring
;;  F¨orberedelseuppgift: Skriv denna subrutin!
;;  vi kan loopa mha printchar och närlängden av d5 är 0
;;  vet vi att alla tecken blir utskrivna
printstring
	move.l #$C126,a4
	move.l #$16,d5
	move.l (a7)-,d4	;flyttar pekaren till a4
	jsr printchar	;återanvänd stack-funktionaliteten här
	sub.l #1,d5	;minskar längd d5 nmed 1 nu neftr printen
	beq rts		;ljämför om branc är 'equal'
			;; Förslag: 	ben printstring ; om 0 gå vidare annars branch
			;;		rts
	bra printstring	;hoppa direkt till början
	rts		;gå till subrutinen som kallade på printstring
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;