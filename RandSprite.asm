;================================================================================
macro ChangeSpriteOnEvent(event)
	LDA DisableRandomSpriteOnEvent : BNE .endChangeSpriteOnEvent
	PHP : REP #$30
    LDA RandomSpriteOnEvent : AND <event> : BEQ .no_change
	PLP
	JSR change_sprite
	BRA .endChangeSpriteOnEvent	;Burn the 3 cycles for previous branch not taken
	.no_change
	NOP	;Burn the 2 cycles for previous branch already taken.
	PLP
	JSR dont_change_sprite
	.endChangeSpriteOnEvent
endmacro

OnInitFileSelectRandSprite:
{
	LDA DisableRandomSpriteOnEvent : BNE .continue
	LDA #$E0 : STA $BC	; Set default sprite.
    %ChangeSpriteOnEvent(RandomSpriteOnEvent)
	.continue
    JSL OnInitFileSelect
    RTL
}

Palette_ArmorAndGlovesRandSprite:
{
    ;DEDF9
     LDA DisableRandomSpriteOnEvent : BEQ .continue
        LDA.b #$10 : STA $BC ; Load Original Sprite Location
        REP #$21
        LDA $7EF35B
        JSL $1BEDFF;Read Original Palette Code
    RTL
    .part_two
    SEP #$30
    LDA DisableRandomSpriteOnEvent : BEQ .continue
        REP #$30
        LDA $7EF354
        JSL $1BEE21;Read Original Palette Code
    RTL

    .continue

    PHX : PHY : PHA
    ; Load armor palette
        PHB : PHK : PLB
    REP #$20
    
    ; Check what Link's armor value is.
    LDA $7EF35B : AND.w #$00FF : TAX
    
    ; (DEC06, X)
    
    LDA $1BEC06, X : AND.w #$00FF : ASL A : ADC.w #$F000 : STA $00
    ;replace D308 by 7000 and search
    REP #$10
    
    LDA.w #$01E2 ; Target SP-7 (sprite palette 6)
    LDX.w #$000E ; Palette has 15 colors
    
    TXY : TAX
    
    ;LDA  $7EC178 : AND #$00FF : STA $02
    LDA.b $BC : AND #$00FF : STA $02

.loop

    LDA [$00] : STA $7EC300, X : STA $7EC500, X
    
    INC $00 : INC $00
    
    INX #2
    
    DEY : BPL .loop

    SEP #$30
    
    
    PLB
    INC $15
    PLA : PLY : PLX
    RTL
}

change_sprite:
{
    JSL GetRandomInt : AND #$1F : !ADD #$E0 : STA $BC
    STA $7EC178
    JSL Palette_ArmorAndGlovesRandSprite
    STZ $0710
	RTS
}

dont_change_sprite:
{
    JSL GetRandomInt : AND #$1F : !ADD #$E0 : LDA $BC
	STA $7EC178
	JSL Palette_ArmorAndGlovesRandSprite
	STZ $0710
	RTS
}

change_sprite_damage:
{
	%ChangeSpriteOnEvent(#$0001)
	LDA $0E20, X : CMP.b #$61 ; Restored Code Bank06.asm(5967) ; LDA $0E20, X : CMP.b #$61 : BNE .not_beamos_laser
    RTL
}

change_sprite_enter:
{
    %ChangeSpriteOnEvent(#$0002)
    LDA.b #$01 : STA $1B
    RTL
}

change_sprite_exit:
{
    %ChangeSpriteOnEvent(#$0004)
    STZ $1B : STZ $0458
    RTL
}

change_sprite_slash:
{
    %ChangeSpriteOnEvent(#$0008)
    JSL $0DBB67
    RTL
}

change_sprite_item:
{
    %ChangeSpriteOnEvent(#$0010)
    JSL AddReceivedItemExpandedGetItem
    RTL
}

EndOfRandSprite:
macro copysprite()
	!spritescopied #= 0
	!spritesoffset #= $E08000
	while !spritescopied < 32
		org !spritesoffset
		!copycount #= 0
		while !copycount+3 < $7000
			dd read4(pctosnes($80000+!copycount))
			!copycount #= !copycount+4
		endif
		!copycount #= 0
		while !copycount+3 < $78
			dd read4(pctosnes($DD308+!copycount))
			!copycount #= !copycount+4
		endif
		dd read4(pctosnes($DEDF5))
		!spritescopied #= !spritescopied+1
		!spritesoffset #= !spritesoffset+$10000
	endif
endmacro
%copysprite()
org EndOfRandSprite

