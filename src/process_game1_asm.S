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
        push    r14
        push    rdi
        push    rsi
        push    rdx
        push    rcx
        push    r8
        push    r9
        # Call draw_sprite
        mov     r14, 1
        mov     r9, [rdx]
        add     rdx, 8 # rdx = rdx + 8 because an address is 8 bytes long
        mov     rdx, [rdx]
        mov     rcx, 0
        mov     r8, 0
        # Call draw_sprite
        call    draw_sprite
        # Restore registers
        pop     r9
        pop     r8
        pop     rcx
        pop     rdx
        pop     rsi
        pop     rdi
        pop     r14


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
  *      rdi : images widths (set at call time)
  *      rsi : images heights (set at call time)
  *      rdx : images data (set at call time)
  *      r14 : sprite index
  *      rcx : sprite x offset
  *      r8 : sprite y offset
  *      r9 : destination data
  *
  * Calling procedure :
  *     # Save registers
  *     push    r14
  *     push    rdi
  *     push    rsi
  *     push    rdx
  *     push    rcx
  *     push    r8
  *     push    r9
  *     # Call draw_sprite
  *     mov     r14, <sprite_index>
  *     mov     rdi, <images_width>
  *     mov     rsi, <images_height>
  *     mov     rdx, <images_data>
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
  *     pop     r14
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
        mov     bx, [rdi + r14 * 2]
        movzx   rax, bx # uint16_t -> uint64_t
        mov     bx, [rsi + r14 * 2]
        movzx   r10, bx # uint16_t -> uint64_t
        imul    rax, r10 # rax = width * height, multiply 2 64-bit integers 

        # Computing offset
        # r11 will contain the x_offset * 4
        # r12 will contain the y_offset * width * 4 
        mov r11, rcx # r11 = x_offset
        mov r12, r8 # r12 = y_offset
        mov r10, 4 # 4 bytes per pixel
        imul r11, r10 # r12 = x_offset * 4
        mov r13w, [rdi] # r13 = &width (of the source image)
        movzx r13, r13w # r13 = width
        imul r12, r13 # r12 = y_offset * width
        imul r12, r10 # r12 = y_offset * width * 4
        add r11, r12 # r11 = x_offset * 4 + y_offset * width * 4

        # add the offset to the destination data
        add r9, r11 # r9 = destination_data + offset

draw_sprite_loop:
        # now we can draw the sprite
        # rax contains the number of pixels in the sprite
        # r9 contains the destination data
        # rdx contains the sprite data
        mov bl, [rdx + rax]
        mov byte ptr [r9 + rax], bl # blue

        mov bl, [rdx + rax + 1]
        mov byte ptr [r9 + rax + 1], bl # green

        mov bl, [rdx + rax * 1 + 2]
        mov byte ptr [r9 + rax * 1 + 2], bl # red

        mov bl, [rdx + rax * 1 + 3]
        mov byte ptr [r9 + rax * 1 + 3], bl # alpha

        sub     rax, 4
        # Skipping a line if needed
        push rax
        push rdx
        mov rdx, 0
        # We will compare rax mod width to 0
        # If it is equal to 0, we will skip a line
        mov r11w, [rdi + r14 * 2] # r11w = width of the sprite (16b)
        movzx r11, r11w # r11 = width of the sprite
        // imul r11, 4 # r11 = width of the sprite * 4
        # so now, we have the number of pixels in a line
        # and r10 contains the number of pixels still to draw
        # we will compare r10 mod r11 to 0
        div r11 # rax = rax / r11, rdx = rax % r11
        cmp rdx, 0
        ja skip_line_end
        # We need to skip a line
        mov r11w, [rdi] # r11 = width (of the source image)
        movzx r11, r11w # r11 = width
        // mov r10, 4 # 8 bytes per pixel
        // imul r11, r10 # r11 = width * 4
        add r9, r11 # r9 = r9 + r11 (we add the width of the source image)

skip_line_end:
        # we restore rdx and rax
        pop rdx
        pop rax
        cmp     rax, 0
        ja      draw_sprite_loop

        
        pop    r12
        pop    r11
        pop    r10
        pop    rbx
        pop    rax

        # stack frame
        mov     rsp, rbp
        pop     rbp
        ret
