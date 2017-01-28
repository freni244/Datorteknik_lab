;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Inargument: Vald tangent i d4
;;  Utargument: Inga
;;
;;  Funktion: Flyttar inneh˚allet p˚a $4001-$4003 bak˚at en byte till
;;  $4000-$4002. Lagrar sedan inneh˚allet i d4 p˚a adress $4003.
addkey
;;  F¨orberedelseuppgift: Skriv denna subrutin
	cmp.l d4,#9	;kollar om hexkey är större än 9
	bgt rts		;om d4 sst�rre �nä9->hoppa ut
	move.l $4000,d3	;annars detta
	lsl.l d3,$4000	;fortsätter vidare i strängen
	move.l d3,$4000	;flyttar tillbaka d3 till 4 senaste hexa-tecknen
	move.l d4,$4003	;senaste siffran i PIAB
	rts
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	