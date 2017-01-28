;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Inargument: Inga
;;  Utargument: Inga
;;
;;  Funktion: S¨atter inneh˚allet p˚a $4000-$4003 till $FF
clearinput
;;  F¨orberedelseuppgift: Skriv denna subrutin
;;  Här kan i fylla minnet med 20 bitar (minneskapaciteten i MC68008)
;;  typ som setup i dugga1 fast istä�llet med tomma värden
	move.l #��$fffff,$4000
	rts
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;