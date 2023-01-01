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

        # Drawing the first sprite at 30,30
        mov     r8, 30
        mov     r9, 30
        mov     r10, 1
        # Call draw_sprite
        call    draw_sprite

        mov     rsp, rbp
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
  *      r8  : sprite x offset
  *      r9  : sprite y offset
  *      r10 : sprite index
  ***************/
        push    rbp
        mov     rbp, rsp

        /* Save registers */
        push    rdi
        push    rsi
        push    rax
        push    rbx
        push    rcx
        push    rdx
        push    r8
        push    r9
        push    r10
        push    r11
        push    r12
        push    r13
        push    r14
        push    r15

        /* Load sprite */
        mov     r12, qword ptr [rdx + r10 * 8]  # r12 = ptr
        movzx   r11, word ptr [rsi + r10 * 2]   # r11 = height
        movzx   r10, word ptr [rdi + r10 * 2]   # r10 = width

        /* Load background */
        mov     rdx, qword ptr [rdx]            # rdx = bg_ptr
        movzx   rsi, word ptr [rsi]             # rsi = bg_height
        movzx   rdi, word ptr [rdi]             # rdi = bg_width

        /*
        r8  = offX
        r9  = offY
        r13 = x
        r11 = y
        */

        dec     r11

copy_sprite__for_y_in_range_height:

        /* Reverse iterat line e from width - 1 */
        mov     r13, r10
        dec     r13

copy_sprite__for_x_in_range_width:

        /*
        index_image = (offY + Y) * bg_width + offX + X
        rbx = (r9 + r11) * rdi + r8 + r13
        */
        mov     rbx, r9
        add     rbx, r11
        imul    rbx, rdi
        add     rbx, r8
        add     rbx, r13

        /*
        index_sprite = Y * width + X
        r15 = r11 * r10 + r13
        */
        mov     r15, r11
        imul    r15, r10
        add     r15, r13

        /* Copy red */
        mov     al, byte ptr [r12 + r15 * 4]
        mov     byte ptr [rdx + rbx * 4], al

        /* Copy green */
        mov     al, byte ptr [r12 + r15 * 4 + 1]
        mov     byte ptr [rdx + rbx * 4 + 1], al

        /* Copy blue */
        mov     al, byte ptr [r12 + r15 * 4 + 2]
        mov     byte ptr [rdx + rbx * 4 + 2], al

        /* Copy alpha */
        mov     al, byte ptr [r12 + r15 * 4 + 3]
        mov     byte ptr [rdx + rbx * 4 + 3], al

        sub     r13, 1
        jae     copy_sprite__for_x_in_range_width

        sub     r11, 1
        jae     copy_sprite__for_y_in_range_height

        /* Reload registers */
        pop    r15
        pop    r14
        pop    r13
        pop    r12
        pop    r11
        pop    r10
        pop    r9
        pop    r8
        pop    rdx
        pop    rcx
        pop    rbx
        pop    rax
        pop    rsi
        pop    rdi

        mov     rsp, rbp
        pop     rbp
        ret
