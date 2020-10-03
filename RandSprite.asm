;================================================================================
org $008A01
LDA $BC


org $1BEDF9
JSL Palette_ArmorAndGlovesRandSprite ;4bytes
RTL ;1byte 
NOP #$01


org $1BEE1B
JSL Palette_ArmorAndGlovesRandSprite_part_two
RTL


org $24FF00
print "Rand Srpite Start: ", pc

macro ChangeSpriteOnEvent(event)
    LDA RandomSpriteOnEvent : AND <event> : BEQ .continue
	JSR change_sprite
	.continue
endmacro

OnInitFileSelectRandSprite:
{
    %ChangeSpriteOnEvent(#$FF)
    JSL OnInitFileSelect
    RTL
}

Palette_ArmorAndGlovesRandSprite:
{
    ;DEDF9
     LDA RandomSpriteOnEvent : BNE .continue
        LDA.b #$10 : STA $BC ; Load Original Sprite Location
        REP #$21
        LDA $7EF35B
        JSL $1BEDFF;Read Original Palette Code
    RTL
    .part_two
    SEP #$30
    LDA RandomSpriteOnEvent : BNE .continue
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

change_sprite_damage:
{
	%ChangeSpriteOnEvent(#$01)
	LDA $0E20, X : CMP.b #$61 ; Restored Code Bank06.asm(5967) ; LDA $0E20, X : CMP.b #$61 : BNE .not_beamos_laser
    RTL
}

change_sprite_enter:
{
    %ChangeSpriteOnEvent(#$02)
    LDA.b #$01 : STA $1B
    RTL
}

change_sprite_exit:
{
    %ChangeSpriteOnEvent(#$04)
    STZ $1B : STZ $0458
    RTL
}

change_sprite_slash:
{
    %ChangeSpriteOnEvent(#$08)
    JSL $0DBB67
    RTL
}

change_sprite_item:
{
    %ChangeSpriteOnEvent(#$10)
    JSL AddReceivedItemExpandedGetItem
    RTL
}

print "Rand Srpite End: ", pc
