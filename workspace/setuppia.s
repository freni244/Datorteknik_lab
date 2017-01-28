;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setuppia
	move.b #0,$10084 	; V¨alj datariktningsregistret (DDRA)
	move.b #1,$10080 	; S¨att pinne 0 p˚a PIAA som utg˚ang
	move.b #4,$10084 	; V¨alj in/utg˚angsregistret
	move.b #0,$10086 	; V¨alj datariktningsregistret (DDRB)
	move.b #0,$10082 	; S¨att alla pinnar som ing˚angar
	move.b #4,$10086 	; V¨alj in/utg˚angsregistret
	rts
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	