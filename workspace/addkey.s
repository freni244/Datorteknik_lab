setup:
	;; ...
addkey:
	;; Inargument: Vald tangent i d4
	;; Utargument: Inga
	;; Funktion: Flyttar innehallet pa $4001-$4003 bakat en byte till
	;; $4000-$4002. Lagrar sedan innehallet i d4 pa adress $4003.
	        cmp.b #'A',d4	;kollar om hexkey ar 'A'->aktivaera alarm
	        beq activatealarm
	        lsr.l #8,d3	;fortsatter vidare i strangen
	        move.l d4,$4003	;flyttar tillbaka d3 till 4 senaste hexa-tecknen
	        rts		;ska det inte vara 4001-4003 som flyttas till 4000-4002
;;; blir det inte lsr.l #8 4003 ($a $b $c $d) -> ($0 $a $b $c)
;;; sedan move.l d4,4003 ($d4 $a $b $c)
;;; Obs: inte alls saker
;;; od 29/1: det kanns som en battre losning
;;; od 29/1: fick bustrap error med lsr .l $4003 sa har far vi nog anvanda d-registret
;;; od 29/1: kanske behover fler hopp efter cmp.b for att det ska funka

	