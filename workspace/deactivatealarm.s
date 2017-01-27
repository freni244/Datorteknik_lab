;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Inargument: Inga
;;  Utargument: Inga
;;
;;  Funktion: Sl¨acker lysdioden kopplad till PIAA
deactivatealarm
;;  F¨orberedelseuppgift: Skriv denna subrutin!
;;  här kan man helt enkelt kolla på föreläsningsanteckningarna från fö4:
;;  move LED,D
;;   or #$FD,D
;;  move D,LED
	move LED,D
	or #$FD,D 	;släcker lampan
	move D,LED
	rts
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	