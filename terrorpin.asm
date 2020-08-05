;================================================================================
; Terrorpin AI Fixes
;================================================================================
FixTerrorpin:
{
    PHA ;save A so that checking the option doesn't smoke A
    LDA.b Enable_TerrorPin_AI_Fix : BNE .new ; check if option is on
        PLA ;restore A
        ; do the old code that smokes A
        AND.b #$03 : STA $0DE0, X
    RTL

    .new
        PLA ; Restore A
        PHA ; save A so the orignal code doesn't kill it
        AND.b #$03 : STA $0DE0, X ; restore what we overwrote
        PLA ; restore A so the AND/BNE in the original code actually does something
	RTL
}
