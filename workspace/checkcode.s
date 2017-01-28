;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Inargument: Inga
;;  Utargument: Returnerar 1 i d4 om koden var korrekt, annars 0 i d4
;;  här kan vi antingen ändra värden internt i checkcode eller
;;  hoppa till ytterligare subrutiner och ändra
checkcode
;;  F¨orberedelseuppgift: Skriv denna subrutin
	move.l $4000,d2 ;vi kollar input
	move.l $4010,d3	;vi lägger fram korrekt kod
	cmp.l £d2,d3	;vi jämföinput med korrekt kod
	beq correct	;om rkorrekt sätts d4 till 1
	move.b #0,d4	;annars 0 i d4
	rts
correct:
	move.b #1,d4	;checkcode hoppar hit om d2 och d3 är samma
	rts
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;