;--------------------------------------------------------------------------------
; $7F5010 - Scratch Space
;--------------------------------------------------------------------------------

DrawDungeonCompassCounts:
	LDX $1B : BNE + : RTL : + ; Skip if outdoors
	LDX $040C : CPX.b #$FF : BNE + : RTL : + ; Skip if not in a dungeon

	CMP.w #$0002 : BEQ ++ ; if CompassMode==2, we don't check for the compass
		LDA $7EF364 : AND.l .item_masks, X ; Load compass values to A, mask with dungeon item masks
		BNE + : RTL : + ; skip if we don't have compass
	++

	LDA $040C : LSR
	BNE +
		INC
	+ TAX : LDA.l CompassTotal, X : AND #$00FF
	SEP #$20
	JSR HudHexToDec2Digit
	REP #$20
	PHX
		LDX.b $06 : TXA : ORA #$2400 : STA $7EC79A
		LDX.b $07 : TXA : ORA #$2400 : STA $7EC79C
	PLX

	LDA $7EF4BF, X : AND #$00FF
	SEP #$20
	JSR HudHexToDec2Digit
	REP #$20

	LDX.b $06 : TXA : ORA #$2400 : STA $7EC794 ; Draw the item count
	LDX.b $07 : TXA : ORA #$2400 : STA $7EC796
	
	LDA.w #$2830 : STA $7EC798 ; draw the slash

	.done
RTL

.item_masks ; these are dungeon correlations to $7EF364 - $7EF369 so it knows where to store compasses, etc
    dw $8000, $4000, $2000, $1000, $0800, $0400, $0200, $0100
    dw $0080, $0040, $0020, $0010, $0008, $0004

;--------------------------------------------------------------------------------
; $7EF4C0-7EF4CF - item locations checked indexed by $040C >> 1
;--------------------------------------------------------------------------------
