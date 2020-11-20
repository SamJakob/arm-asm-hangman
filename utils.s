/*
    Hangman - by Sam Jakob Mearns
    Unpublished Work (c) 2020 Sam Jakob Mearns - All Rights Reserved
 */

/**
 * BNR - Branch Not in Range - branches to [label] if the value of [reg] is not
 * in the range [min] to [max].
 */
.macro BNR reg:req, min:req, max:req, label:req
    CMP \reg, \min
    BLT \label
    CMP \reg, \max
    BGT \label
.endm
