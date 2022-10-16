S Addr  Instr   Source code
------------------------------------------------------------------------------------------------
                DEF SW   0x81                   ; DIP kapcsoló adatregiszter (csak olvasható)
                DEF COL0 0x94                   ; Kijelzõ COL0 adatregiszter (írható/olvasható)
                DEF COL1 0x95                   ; Kijelzõ COL1 adatregiszter (írható/olvasható)
                DEF COL2 0x96                   ; Kijelzõ COL2 adatregiszter (írható/olvasható)
                DEF COL3 0x97                   ; Kijelzõ COL3 adatregiszter (írható/olvasható)
                DEF COL4 0x98                   ; Kijelzõ COL4 adatregiszter (írható/olvasható)

                ;r0 az 5x7 mátrix egy oszlopának az adatregiszter címét tárolja
                ;r1 megjelenítendõ értéket tárolja
                ;r2 tárolja mennyi értéket kell még megjeleníteni
                ;r3 a kapcsoló(SW) állapotát tárolja
                ;r4 azt tárolja, hogy a mátrix utolsó sorában, melyik oszlopban kell megjeleníteni az értéket
                ;r5 az utolsó sorban a megjelenítendõ adatot tartalmazza
                ;munkaregiszterek r6-r15

C 00            start:
C 00    C094        mov     r0, #0x94           ;balra fog mutatni a nyíl vége r0=COL0
C 01    C104        mov     r1, #0x04           ;r1 kezdeti értéke
C 02    C205        mov     r2, #0x05           ;számláló beállítása
C 03    D381        mov     r3, SW[81]          ;kapcsoló állapotának beolvasása
C 04    4307        and     r3, #0x07           ;felesleges bitek maszkolása
C 05    8302        tst     r3, #0x02           ;SW[1] megadja balra vagy jobbra mutasson
C 06    B108        jz      atlo[08]            ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
C 07    C098        mov     r0, #0x98           ;jobbra fog mutatni a nyíl vége r0=COL4

C 08            atlo:                           ;a nyíl szárának megjelenítése
C 08    8304        tst     r3, #0x04           ;SW[2] egyszerû vagy pontoként növekvõ legyen
C 09    B10B        jz      nowait[0B]          ;ha SW[2] = 0 akkor egyszerû nyíl lesz, nem lesz idõzítés
C 0A    B933        jsr     wait[33]            ;ellenkezõ esetben pontonként növekvõ
C 0B            nowait:
C 0B    F190        mov     (r0), r1            ;r1 megjelenítése
C 0C    8301        tst     r3, #0x01           ;SW[0] villogjon vagy statikus legyen
C 0D    B20F        jnz     novil[0F]           ;ha SW[0] = 1 akkor statikus lesz
C 0E    B942        jsr     villog[42]          ;ellenkezõ esetben villog subroutine meghívása
C 0F            novil:
C 0F    F170        sl0     r1                  ;r1 shiftelése balra
C 10    8302        tst     r3, #0x02           ;SW[1] balra vagy jobbra mutasson
C 11    B213        jnz     jobbra[13]          ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
C 12    0002        add     r0, #0x02           ;oszlop növelése 1-gyel, alsó kivonás miatt
C 13            jobbra:
C 13    2001        sub     r0, #0x01           ;oszlop csökkentése 1-gyel
C 14    2201        sub     r2, #0x01           ;számláló csökkentése
C 15    B208        jnz     atlo[08]            ;ha r2 nem nulla addig ismétlés

C 16    C098        mov     r0, #0x98           ;balra fog mutatni a nyíl vége r0=COL4
C 17    C1E0        mov     r1, #0xE0           ;(1)1100000 r1 kezdõ értéke
C 18    C203        mov     r2, #0x03           ;számláló beállítása
C 19    C497        mov     r4, #0x97           ;alsó rész oszlopa r4=COL3, ha balra mutat a nyíl
C 1A    C560        mov     r5, #0x60           ;alsó rész kezdeti értéke
C 1B    8302        tst     r3, #0x02           ;SW[1] balra vagy jobbra mutasson
C 1C    B11F        jz      hegye[1F]           ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
C 1D    C094        mov     r0, #0x94           ;jobbra fog mutatni a nyíl vége r0=COL0
C 1E    C495        mov     r4, #0x95           ;alsó rész oszlopa r4=COL1, ha jobbra mutat a nyíl

C 1F            hegye:                          ;nyíl hegyének megjelenítése
C 1F    8304        tst     r3, #0x04           ;SW[2] egyszerû vagy pontoként növekvõ legyen
C 20    B122        jz      nowait2[22]         ;ha SW[2] = 0 akkor egyszerû nyíl lesz, nem lesz idõzítés
C 21    B933        jsr     wait[33]            ;ellenkezõ esetben pontonként növekvõ
C 22            nowait2:
C 22    F190        mov     (r0), r1            ;r1 megjelenítése, COL4 vagy COL0-án
C 23    F175        sr1     r1                  ;r1 shiftelése jobbra 1 berakásával
C 24    F594        mov     (r4), r5            ;r5 megjelenítése, COLX-en balról vagy jobbról
C 25    8301        tst     r3, #0x01           ;SW[0] villogjon vagy statikus legyen
C 26    B228        jnz     novil2[28]          ;ha SW[0] = 1 akkor statikus lesz
C 27    B942        jsr     villog[42]          ;ellenkezõ esetben villog subroutine meghívása
C 28            novil2:
C 28    8302        tst     r3, #0x02           ;SW[1] balra vagy jobbra mutasson
C 29    B22B        jnz     jobbra2[2B]         ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
C 2A    2402        sub     r4, #0x02           ;oszlop csökkentése 1-gyel, alsó összeadás miatt
C 2B            jobbra2:
C 2B    0401        add     r4, #0x01           ;oszlop növelése 1-gyel
C 2C    F5D4        mov     r5, (r4)            ;a jelenlegi oszlop értékének másolása 
C 2D    5540        or      r5, #0x40           ;r5 maszkolása (0)1000000
C 2E    2201        sub     r2, #0x01           ;számláló csökkentése
C 2F    B21F        jnz     hegye[1F]           ;ha r2 nem nulla addig ismétlés

C 30            end:
C 30    B933        jsr     wait[33]            ;törlés elõtt várás
C 31    B93B        jsr     torol[3B]           ;torol subroutine meghívása
C 32    B000        jmp     start[00]           ;kezdés elõröl

C 33            wait:                           ;szoftveres idõzítés 24-bittel
C 33    CF00        mov     r15, #0x00
C 34    CE00        mov     r14, #0x00
C 35    CD00        mov     r13, #0x00
C 36            wait_loop:
C 36    0F46        add     r15, #0x72
C 37    1E00        adc     r14, #0x00
C 38    1D00        adc     r13, #0x00
C 39    B436        jnc     wait_loop[36]
C 3A    BA00        rts     

C 3B            torol:                          ;5x7 kijelzõ törlése
C 3B    CF00        mov     r15, #0x00
C 3C    9F94        mov     COL0[94], r15
C 3D    9F95        mov     COL1[95], r15
C 3E    9F96        mov     COL2[96], r15
C 3F    9F97        mov     COL3[97], r15
C 40    9F98        mov     COL4[98], r15
C 41    BA00        rts     
C 42            villog:                         ;villog subroutine
C 42    D694        mov     r6, COL0[94]
C 43    D795        mov     r7, COL1[95]
C 44    D896        mov     r8, COL2[96]
C 45    D997        mov     r9, COL3[97]
C 46    DA98        mov     r10, COL4[98]
C 47    B93B        jsr     torol[3B]
C 48    B933        jsr     wait[33]
C 49    9694        mov     COL0[94], r6
C 4A    9795        mov     COL1[95], r7
C 4B    9896        mov     COL2[96], r8
C 4C    9997        mov     COL3[97], r9
C 4D    9A98        mov     COL4[98], r10
C 4E    BA00        rts     
