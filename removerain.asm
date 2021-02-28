Overworld_RemoveRainLong:
{
    LDA $8A : AND.b #$BF : CMP #$03 : BEQ ++ : CMP #$05 : BEQ ++ : CMP #$07 : BNE + : ++ ; any death mountain rooms
        BRA .endNoRain
    +

    LDA $8A : CMP #$70 : BNE + 
        LDA $7EF2F0 : AND.b #$20 : BNE .endNoRainClearOverlay
        LDA $0418 : BNE .endNoRainClearOverlay ; if we're transitioning at a direction
            BRA .endWithRain
    +

    LDA $7EF3C5 : CMP.b #$02 : !BGE .endNoRain
    .endWithRain
    LDA #$FF : RTL
    .endNoRainClearOverlay
    STZ $1D
    .endNoRain
    LDA #$00 : RTL
}
