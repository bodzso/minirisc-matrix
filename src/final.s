DEF SW   0x81                ; DIP kapcsoló adatregiszter (csak olvasható)
DEF COL0 0x94                ; Kijelzõ COL0 adatregiszter (írható/olvasható)
DEF COL1 0x95                ; Kijelzõ COL1 adatregiszter (írható/olvasható)
DEF COL2 0x96                ; Kijelzõ COL2 adatregiszter (írható/olvasható)
DEF COL3 0x97                ; Kijelzõ COL3 adatregiszter (írható/olvasható)
DEF COL4 0x98                ; Kijelzõ COL4 adatregiszter (írható/olvasható)

;r0 az 5x7 mátrix egy oszlopának az adatregiszter címét tárolja
;r1 megjelenítendõ értéket tárolja
;r2 tárolja mennyi értéket kell még megjeleníteni
;r3 a kapcsoló(SW) állapotát tárolja
;r4 azt tárolja, hogy a mátrix utolsó sorában, melyik oszlopban kell megjeleníteni az értéket
;r5 az utolsó sorban a megjelenítendõ adatot tartalmazza
;munkaregiszterek r6-r15

start:
    mov r0, #0x94 ;balra fog mutatni a nyíl vége r0=COL0
    mov r1, #4 ;r1 kezdeti értéke
    mov r2, #5 ;számláló beállítása
    mov r3, SW ;kapcsoló állapotának beolvasása
    and r3, #7 ;felesleges bitek maszkolása
    tst r3, #2 ;SW[1] megadja balra vagy jobbra mutasson
    jz atlo ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
    mov r0, #0x98 ;jobbra fog mutatni a nyíl vége r0=COL4

atlo: ;a nyíl szárának megjelenítése
    tst r3, #4 ;SW[2] egyszerû vagy pontoként növekvõ legyen
    jz nowait ;ha SW[2] = 0 akkor egyszerû nyíl lesz, nem lesz idõzítés
    jsr wait ;ellenkezõ esetben pontonként növekvõ
nowait:
    mov (r0), r1 ;r1 megjelenítése
    tst r3, #1 ;SW[0] villogjon vagy statikus legyen
    jnz novil ;ha SW[0] = 1 akkor statikus lesz
    jsr villog ;ellenkezõ esetben villog subroutine meghívása
novil:
    sl0 r1 ;r1 shiftelése balra
    tst r3, #2 ;SW[1] balra vagy jobbra mutasson
    jnz jobbra ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
    add r0, #2 ;oszlop növelése 1-gyel, alsó kivonás miatt
jobbra:
    sub r0, #1 ;oszlop csökkentése 1-gyel
    sub r2, #1 ;számláló csökkentése
    jnz atlo ;ha r2 nem nulla addig ismétlés

mov r0, #0x98 ;balra fog mutatni a nyíl vége r0=COL4
mov r1, #0xE0 ;(1)1100000 r1 kezdõ értéke
mov r2, #3 ;számláló beállítása
mov r4, #0x97 ;alsó rész oszlopa r4=COL3, ha balra mutat a nyíl
mov r5, #0x60 ;alsó rész kezdeti értéke
tst r3, #2 ;SW[1] balra vagy jobbra mutasson
jz hegye ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
mov r0, #0x94 ;jobbra fog mutatni a nyíl vége r0=COL0
mov r4, #0x95 ;alsó rész oszlopa r4=COL1, ha jobbra mutat a nyíl

hegye: ;nyíl hegyének megjelenítése
    tst r3, #4 ;SW[2] egyszerû vagy pontoként növekvõ legyen
    jz nowait2 ;ha SW[2] = 0 akkor egyszerû nyíl lesz, nem lesz idõzítés
    jsr wait ;ellenkezõ esetben pontonként növekvõ
nowait2:
    mov (r0), r1 ;r1 megjelenítése, COL4 vagy COL0-án
    sr1 r1 ;r1 shiftelése jobbra 1 berakásával
    mov (r4), r5 ;r5 megjelenítése, COLX-en balról vagy jobbról
    tst r3, #1 ;SW[0] villogjon vagy statikus legyen
    jnz novil2 ;ha SW[0] = 1 akkor statikus lesz
    jsr villog ;ellenkezõ esetben villog subroutine meghívása
novil2:
    tst r3, #2 ;SW[1] balra vagy jobbra mutasson
    jnz jobbra2 ;ha SW[1] = 0 akkor balra fog mutatni a nyíl vége
    sub r4, #2 ;oszlop csökkentése 1-gyel, alsó összeadás miatt
jobbra2:
    add r4, #1 ;oszlop növelése 1-gyel
    mov r5, (r4) ;a jelenlegi oszlop értékének másolása 
    or r5, #0x40 ;r5 maszkolása (0)1000000
    sub r2, #1 ;számláló csökkentése
    jnz hegye ;ha r2 nem nulla addig ismétlés

end:
    jsr wait ;törlés elõtt várás
    jsr torol ;torol subroutine meghívása
    jmp start ;kezdés elõröl

wait: ;szoftveres idõzítés 24-bittel
    mov r15, #0
    mov r14, #0
    mov r13, #0
wait_loop:  
    add r15, #72
    adc r14, #0
    adc r13, #0
    jnc wait_loop
    rts

torol: ;5x7 kijelzõ törlése
    mov r15, #0
    mov COL0, r15
    mov COL1, r15
    mov COL2, r15
    mov COL3, r15
    mov COL4, r15
    rts
villog: ;villog subroutine
    mov r6, COL0
    mov r7, COL1
    mov r8, COL2
    mov r9, COL3
    mov r10, COL4
    jsr torol
    jsr wait
    mov COL0, r6
    mov COL1, r7
    mov COL2, r8
    mov COL3, r9
    mov COL4, r10
    rts