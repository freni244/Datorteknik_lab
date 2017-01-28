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
deactivatealarm
	move LED,D
	or #$FD,D 	;släcker lampan, 
			;; Tror vi ska ha ”and $FE,D” eftersom and släcker och FE=1111 1110 
			;; väljer pinne 0, där lampan sitter.
			;; tex 1111 1110 & 0000 1001 = 0000 1000
			;; Om jag fattat rätt.
	move D,LED
	rts
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	