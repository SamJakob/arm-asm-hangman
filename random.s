.extern random
.extern srand
.extern time

.macro _random_divModDriver numerator:req, denominator:req
    MOV R8, \numerator
    MOV R9, \denominator

    MOV R10, #0         // Q = 0

    div_start\@:
        CMP R8, R9
        BLT div_complete\@
        ADD R10, R10, #1  // Q = Q + 1
        SUB R8, R8, R9    // N = N - D
        B div_start\@
    
    // R10 contains Q (quotient)
    // R8 contains R (remainder)

    div_complete\@:
.endm

.macro division numerator:req, denominator:req
    PUSH {R8, R9, R10}
    _random_divModDriver \numerator, \denominator
    MOV R0, R10
    POP {R8, R9, R10}
.endm

.macro modulo numerator:req, denominator:req
    PUSH {R8, R9, R10}
    _random_divModDriver \numerator, \denominator
    MOV R0, R8
    POP {R8, R9, R10}
.endm

.macro randomNumber max:req
    /*
        From C:
        
        int rand(int max) {
            srand(time(NULL));
            return rand() % max;
        }

    */

    // srand(time(NULL))
    MOV R0, #0
    BL time
    BL srand

    // rand()
    BL rand

    // return <prev> % max
    modulo R0, \max
.endm
