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

        # Check if init
        mov     r8b, byte ptr [rcx]
        cmp     r8b, 0
        jne     already_initialize

        mov     byte ptr [rcx], 1
        mov     qword ptr [rcx + 1], 400
        mov     qword ptr [rcx + 9], 1

already_initialize:

        cmp     qword ptr [rcx + 1], 726
        jb      not_change
        mov   qword ptr [rcx + 9], -1
not_change:

        cmp     qword ptr [rcx + 1], 4
        ja      not_change2
        mov     qword ptr [rcx + 9], 1
not_change2:

        mov     r8, qword ptr [rcx + 9]
        add     qword ptr [rcx + 1], r8

        # Update sprite

        # Drawing the void
        mov     r8, 0
        mov     r9, 0
        mov     r10, 2
        call    draw_sprite

        # Drawing the cat at 10,10
        mov     r8, 10
        mov     r9, 10
        mov     r10, 3
        call    draw_sprite

        # Drawing the cat-explode
        mov     r8, 74
        mov     r9, 10
        mov     r10, 4
        call    draw_sprite

        # Drawing the food
        mov     r8, 138
        mov     r9, 10
        mov     r10, 5
        call    draw_sprite

        # Drawing the spaceship
        mov     r8, qword ptr [rcx + 1]
        mov     r9, 526
        mov     r10, 6
        call    draw_sprite

        # Drawing the kennel
        mov     r8, 300
        mov     r9, 10
        mov     r10, 7
        call    draw_sprite

        # Sleep
        mov     r8, 1000000
        call    sleep

        mov     rsp, rbp
        pop     rbp
        ret
        # End of process_image_asm


sleep:
 /***************
  * Sleep time
  * Needed registers :
  *      r8  : nanoseonds
  ***************/
        push    rbp
        mov     rbp, rsp
        push    r8
loop_sleep:
        sub     r8, 1
        jae     loop_sleep

        pop     r8
        mov     rsp, rbp
        pop     rbp
        ret




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
        Make check about size at same moment
        */
        mov     rbx, r9
        add     rbx, r11
        imul    rbx, rdi
        add     rbx, r8
        add     rbx, r13
        imul    rbx, 4
        add     rbx, rdx

        /*
        index_sprite = Y * width + X
        r14 = r11 * r10 + r13
        */
        mov     r14, r11
        imul    r14, r10
        add     r14, r13
        imul    r14, 4
        add     r14, r12

        /* Load alpha */
        mov     r15b, byte ptr [r14 + 3]
        mov     cl, 0xff
        sub     cl, r15b

        /* Compute red with alpha */
        mov     al, byte ptr [r14]
        mul     r15b
        mov     al, byte ptr [rbx]
        mov     byte ptr [rbx], ah
        mul     cl
        add     byte ptr [rbx], ah

        /* Compute green with alpha */
        mov     al, byte ptr [r14 + 1]
        mul     r15b
        mov     al, byte ptr [rbx + 1]
        mov     byte ptr [rbx + 1], ah
        mul     cl
        add     byte ptr [rbx + 1], ah

        /* Compute blue with alpha */
        mov     al, byte ptr [r14 + 2]
        mul     r15b
        mov     al, byte ptr [rbx + 2]
        mov     byte ptr [rbx + 2], ah
        mul     cl
        add     byte ptr [rbx + 2], ah

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
