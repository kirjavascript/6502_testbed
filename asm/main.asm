        .setcpu "6502"


.segment    "PRG_chunk1": absolute

.repeat $400
    .byte $00
.endrep

.include "rng.asm"

.code
