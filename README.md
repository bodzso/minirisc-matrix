# minirisc-matrix
5x7 dot matrix controlled by a minirisc cpu.

The program is written in SW on MiniRISC.

The basic operation of the program is based on setting the values of the matrix columns one by one, from left or right depending on SW[1].

As this is done quite fast by the card, the arrow can be seen as static on the 5x7 matrix, however, if you add timing before displaying it, it will be displayed point by point, this depends on SW[2].

The flashing is achieved by storing what is currently on the matrix, then clearing the matrix, then writing back the original values. The timing after the erase is required to flash, this depends on SW[0].
The program uses software timing for timing, with a 24 bit counter using 3 registers.
