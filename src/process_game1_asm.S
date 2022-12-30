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
  *     pop     r8
  *     pop     rcx
  *     pop     rdx
  *     pop     rsi
  *     pop     rdi
  ***************/
  
