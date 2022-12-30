/*  process_game1_asm.S
 
    MI01 - TP Assembleur 2 à 5

    Réalise le traitement d'une image bitmap 32 bits par pixel.
*/

.file "process_game1_asm.S"
.intel_syntax noprefix

.text

/***********************************************************************
  Sous-programme process_image_asm 
    
  Réalise le traitement d'une image 32 bits.
  
  Le passage des paramètres respecte les conventions x64 sous Linux
  
  Par registres :
            Largeur des images : rdi
            Hauteur des images : rsi
            Pointeur sur le tableau de pointeurs des images sources : rdx
            Pointeur sur la zone de données : rcx

L'image de fond se trouve dans le premier élément
  
  Les registes rbx, rbp, r12, r13, r14, et r15 doivent être sauvegardés
  si vous les utilisez (sauvegarde par l'appelé). Les autres registres 
  peuvent être modifiés sans risque (sauvegardés par l'appelant).
***********************************************************************/


.global process_game1_asm
process_game1_asm:
        push    rbp
        mov     rbp, rsp
        // push    rdi
        // push    rsi
        // push    rdx
        push    r12
        push    rbx
        push    r14
        push    r15
        // push    rcx

  /***********************************************************
    Ajoutez votre code ici
  **********************************************************/
        # This portion computes the number of pixels in the image
        mov     bx, [rdi]
        movzx   rax, bx # uint16_t -> uint64_t
        mov     bx, [rsi]
        movzx   rcx, bx # uint16_t -> uint64_t
        imul    rax, rcx # rax = width * height, multiply 2 64-bit integers 

test_loop:
        # First we get the ptr to the first image in the array, that we are going to edit
        mov     r12, [rdx]

        mov     byte ptr [r12 + rax * 4 + 0], 0xff
        mov     byte ptr [r12 + rax * 4 + 1], 0x00
        mov     byte ptr [r12 + rax * 4 + 2], 0x00
        mov     byte ptr [r12 + rax * 4 + 3], 0xff

        sub     rax, 1
        ja      test_loop

        # Drawing the first sprite
        # Save registers
        push    rdi
        push    rsi
        push    rdx
        push    rcx
        push    r8
        push    r9
        # Call draw_sprite
        add     rdi, 8
        add     rsi, 8
        mov     r9, rdx
        add     rdx, 8
        mov     rcx, 100
        mov     r8, 100
        # Call draw_sprite
        call    draw_sprite
        # Restore registers
        pop     r9
        pop     r8
        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi


        // pop     rcx
        pop     r15
        pop     r14
        pop     rbx
        pop     r12
        // pop     rdx
        // pop     rsi
        // pop     rdi
        pop     rbp
        ret
        # End of process_image_asm



draw_sprite:
 /***************
  * Draw a sprite
  * Needed registers :
  *      rdi : sprite width
  *      rsi : sprite height
  *      rdx : sprite data
  *      rcx : sprite x offset
  *      r8 : sprite y offset
  *      r9 : destination data
  *
  * Calling procedure :
  *     # Save registers
  *     push    rdi
  *     push    rsi
  *     push    rdx
  *     push    rcx
  *     push    r8
  *     push    r9
  *     # Call draw_sprite
  *     mov     rdi, <sprite_width>
  *     mov     rsi, <sprite_height>
  *     mov     rdx, <sprite_data>
  *     mov     rcx, <sprite_x_offset>
  *     mov     r8, <sprite_y_offset>
  *     mov     r9, <destination_data>
  *     # Call draw_sprite
  *     call    draw_sprite
  *     # Restore registers
  *     pop     r9
  *     pop     r8
  *     pop     rcx
  *     pop     rdx
  *     pop     rsi
  *     pop     rdi
  ***************/
        push    rbp
        mov     rbp, rsp
        # stack frame

        # saving registers we will use as calculation registers
        push    rax
        push    rbx
        push    r10
        push    r11
        push    r12

        # This portion computes the number of pixels in the image
        mov     bx, [rdi]
        movzx   rax, bx # uint16_t -> uint64_t
        mov     bx, [rsi]
        movzx   r10, bx # uint16_t -> uint64_t
        imul    rax, r10 # rax = width * height, multiply 2 64-bit integers 

        # Computing offsets
        # r11 will contain the start address on the destination
        mov r11, rcx
        mov r12, r8
        mov r10, 4 # 4 bytes per pixel
        imul r11, r10 # r12 = x_offset * 4
        imul r12, rdi # r12 = y_offset * width
        add r11, r12 # r11 = x_offset * 4 + y_offset * width

        # add the offset to the destination data
        add r9, r11 # r9 = destination_data + offset

draw_sprite_loop:
        # now we can draw the sprite
        # rax contains the number of pixels in the sprite
        # r9 contains the destination data
        # rdx contains the sprite data
        mov bl, [rdx + rax * 4 + 0]
        mov byte ptr [r9 + rax * 4 + 0], bl # blue

        mov bl, [rdx + rax * 4 + 1]
        mov byte ptr [r9 + rax * 4 + 1], bl # green

        mov bl, [rdx + rax * 4 + 2]
        mov byte ptr [r9 + rax * 4 + 2], bl # red

        mov bl, [rdx + rax * 4 + 3]
        mov byte ptr [r9 + rax * 4 + 3], bl # alpha

        sub     rax, 1
        ja      draw_sprite_loop
        
        pop    r12
        pop    r11
        pop    r10
        pop    rbx
        pop    rax

