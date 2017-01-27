;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Inargument: Inga
;;  Utargument: Inga
;;
;;  Funktion: T¨ander lysdioden kopplad till PIAA
activatealarm
;;  F¨orberedelseuppgift: Skriv denna subrutn!
;;  samma här som de-.s läs föreläsnsanteckningar från fö4:
	move LED,D
	or #$01,D 	;t�nd diod
	move D,LED
	rts			
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;