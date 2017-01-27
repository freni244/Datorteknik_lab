;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Inargument: Inga
;;  Utargument: Tryckt knappt returneras i d4
getkey
;;  F¨orberedelseuppgift: Skriv denna subrutin!
;;  här läser vi av piab 0, piab 1, piab 2, piab 3 med abcd och a=MSB
;;  kolla setuppia-rutinen fö ingångar till hexa-tangentborde
;;  om hexa-tecknet är mellan 0 och 9 skrivs en siffra utannars inte
	move.l $10082,d5 	;inmatning från PIAB
	
	move.l d5,$4010		;inmatning av kod till minne
	move.l #$1234,$4000	;korrekt kod

	rts
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;