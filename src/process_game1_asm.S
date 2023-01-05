/*  process_game1_asm.S
 
    MI01 - TP Assembleur 2 à 5

    Réalise le traitement d'une image bitmap 32 bits par pixel.
*/

.file "process_game1_asm.S"
.intel_syntax noprefix

.data

BASE_IMAGE = 0
DEBUG_IMAGE = 1
VOID_IMAGE = 2
CAT_IMAGE = 3
CAT_EXPLODE_IMAGE = 4
FOOD_IMAGE = 5
SPACESHIP1_IMAGE = 6
SPACESHIP2_IMAGE = 7
KENNEL4_IMAGE = 8
KENNEL3_IMAGE = 9
KENNEL2_IMAGE = 10
KENNEL1_IMAGE = 11
MOUSE_IMAGE = 12


SPACESHIP_TYPE = 0
CAT_TYPE = 1
KENNEL_TYPE = 2
FOOD_TYPE = 3
MOUSE_TYPE = 4

# https://stackoverflow.com/questions/3062746/special-simple-random-number-generator
DEFAULT_SEED = 16816761

SPRITE_X = 0
SPRITE_Y = 2
SPRITE_W = 4
SPRITE_H = 6
SPRITE_IMAGE = 8
SPRITE_TYPE = 10
SPRITE_LIFE = 12
SPRITE_DAMAGE = 14
SPRITE_TIMEOUT = 16
SPRITE_DATA = 24
SPRITE_SIZE = 32

ADDR_START = 0
ADDR_STOP = 8
ADDR_SEED = 16
ADDR_SPRITE_COUNT = 24
ADDR_SPRITE_LIST = 32

CAT_SHOT_INTERVAL = 0x1ff
CAT_SPEED = 1
CAT_SHOT_SPEED = 8
SPACESHIP_SPEED = 2
SPACESHIP_SHOT_SPEED = 16
SPACESHIP_LIFE = 3
WIDTH_SCREEN = 800
HEIGHT_SCREEN = 600

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

        # Check if init
        mov     r8, qword ptr [rcx]
        cmp     r8, 0
        jne     _already_initialize

        /* Initialization */
        mov     qword ptr [rcx + ADDR_START], 1
        mov     qword ptr [rcx + ADDR_STOP], 0
        mov     qword ptr [rcx + ADDR_SEED], DEFAULT_SEED
        mov     qword ptr [rcx + ADDR_SPRITE_COUNT], 0

        /* Create spaceship */
        mov     r9, 364                 # x
        mov     r10, 512                # y
        mov     r11, SPACESHIP1_IMAGE   # image
        mov     r12, SPACESHIP_TYPE     # image
        mov     r13, SPACESHIP_LIFE     # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data
        call    create_sprite

        /* Create cats */
        mov     r10, 16                 # y
        mov     r11, CAT_IMAGE          # image
        mov     r12, CAT_TYPE           # type
        mov     r13, 1                  # life
        mov     r14, 0                  # timeout
        mov     r15, 1 # data

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 16                  # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 82                  # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 148                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 214                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 280                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 346                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 412                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 478                 # x
        call    create_sprite

        add     r10, 80                 # next line

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 16                  # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 82                  # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 148                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 214                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 280                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 346                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 412                 # x
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 478                 # x
        call    create_sprite

        /* Create kennel */
        mov     r10, 432                # y
        mov     r11, KENNEL4_IMAGE       # image
        mov     r12, KENNEL_TYPE        # image
        mov     r13, 4                  # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data

        mov     r9, 128                 # x
        call    create_sprite

        mov     r9, 288                 # x
        call    create_sprite

        mov     r9, 448                 # x
        call    create_sprite

        mov     r9, 608                 # x
        call    create_sprite


_already_initialize:


/* Find min and max value x for cat*/
        mov     r12w, WIDTH_SCREEN
        mov     r13w, 0
        lea     r10, [rip + _callback_max_and_min]
        mov     r11, CAT_TYPE
        call    apply_sprites
        jmp     _end_callback_max_and_min
_callback_max_and_min:
        mov     r9w, word ptr [r8 + SPRITE_X]
        cmp     r12w, r9w
        cmovg   r12w, r9w
        add     r9w, word ptr [r8 + SPRITE_W]
        cmp     r13w, r9w
        cmovl   r13w, r9w
        ret
_end_callback_max_and_min:
        

/* Update cat */
        lea     r10, [rip + _update_cat]
        mov     r11, CAT_TYPE
        call    apply_sprites
        jmp     _end_update_cat
_update_cat:

        mov     r14, qword ptr [r8 + SPRITE_TIMEOUT]
        cmp     r14, 0
        jg      _not_cat_shoot
        mov     qword ptr [r8 + SPRITE_TIMEOUT], CAT_SHOT_INTERVAL

        push    r8
        push    r9
        push    r10
        push    r11
        push    r12
        push    r13
        push    r14
        push    r15

        movzx   r9, word ptr [r8 + SPRITE_W]            # x
        ror     r9, 1
        add     r9w, word ptr [r8 + SPRITE_X]

        movzx   r10, word ptr [r8 + SPRITE_Y]                # y
        add     r10w, word ptr [r8 + SPRITE_H]                # y


        mov     r11, MOUSE_IMAGE        # image
        mov     r12, MOUSE_TYPE         # type
        mov     r13, -1                 # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data
        call    create_sprite
        
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     r11
        pop     r10
        pop     r9
        pop     r8

_not_cat_shoot:
        sub     qword ptr [r8 + SPRITE_TIMEOUT], 1

        cmp     r12w, 8
        jb      _right
        cmp     r13w, WIDTH_SCREEN - 8
        ja      _left
        jmp     _end_direction
_left:
        mov    byte ptr [r8 + SPRITE_DATA], -1
        add    word ptr [r8 + SPRITE_Y], 10
        jmp _end_direction
_right:
        mov    byte ptr [r8 + SPRITE_DATA], 1
        add    word ptr [r8 + SPRITE_Y], 10
        jmp _end_direction
_end_direction:

        movsx   r9w, byte ptr [r8 + SPRITE_DATA]
        add     word ptr [r8 + SPRITE_X], r9w
        ret
_end_update_cat:



        lea     r10, [rip + _update_projectile]
        mov     r11, MOUSE_TYPE
        call    apply_sprites
        jmp     _end_update_projectile
_update_projectile:
        add     word ptr [r8 + SPRITE_Y], CAT_SHOT_SPEED

        mov     r10w, word ptr [r8 + SPRITE_Y]
        add     r10w, word ptr [r8 + SPRITE_H]
        cmp     r10w, HEIGHT_SCREEN
        jl      _not_outside
        call    delete_sprite

_not_outside:
        ret
_end_update_projectile:

        /* Draw all sprite ! */
        # Drawing the void
        mov     r8, 0
        mov     r9, 0
        mov     r10, VOID_IMAGE
        call    draw_image

        # Draw spaceship
        mov     r8, rcx
        add     r8, ADDR_SPRITE_LIST

        mov     r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
_loop_draw:

        call    draw_sprite
        add     r8, SPRITE_SIZE
        sub     r9, 1
        jae     _loop_draw

        # Sleep
        mov     r8, 1000000
        call    sleep

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
_sleep__for_each_iteration:
        sub     r8, 1
        jae     _sleep__for_each_iteration

        pop     r8
        mov     rsp, rbp
        pop     rbp
        ret

 /***************
  * Create a sprite
  * Needed registers :
  *     r10 : callback (r8 : actual sprite, dont touch to r9)
  *     r11 : type
  */
apply_sprites:
        push    rbp
        mov     rbp, rsp

        push    r8
        push    r9

        mov     r8, SPRITE_SIZE
        mov     r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
        dec     r9
        imul    r8, r9
        
        mov     r9, rcx
        add     r9, ADDR_SPRITE_LIST

        add     r8, r9

_apply_sprites__for_sprite_in_sprites:
        cmp     word ptr [r8 + SPRITE_TYPE], r11w
        jne      _apply_sprites__if_type_not_match


        push    r8
        push    r9
        push    r10
        call    r10
        pop     r10
        pop     r9
        pop     r8

_apply_sprites__if_type_not_match:
        sub     r8, SPRITE_SIZE
        cmp     r8, r9
        jg      _apply_sprites__for_sprite_in_sprites

        pop     r9
        pop     r8

        mov     rsp, rbp
        pop     rbp
        ret




lcg_randint:
 /***************
  *  Generate random number between 0 and 2^31
  * From https://www.javamex.com/tutorials/random_numbers/ThreadLocalRandom.shtml
  * Needed registers :
  *      rcx : data memory
  * Return registers :
  *      r14 : the new seed
  ***************/
        push    rax
        push    rdx

        mov     rax, qword ptr [rcx + ADDR_SEED]
        mov     r14, 1103515245
        mul     r14
        add     rax, 12345
        and     rax, 0x7fffffff
        mov     qword ptr [rcx + ADDR_SEED], rax
        mov     r14, rax

        pop     rdx
        pop     rax
        ret


create_sprite:
 /***************
  * Create a sprite
  * Needed registers :
  *      rdi : images widths
  *      rsi : images heights
  *      rcx : data memory
  *      r9  : x
  *      r10 : y
  *      r11 : image
  *      r12 : type
  *      r13 : life
  *      r14 : timeout
  *      r15 : 8 bytes embed data
  * Return registers :
  *      r8  : new data pointer
  ***************/
        push    rax

        mov     r8, SPRITE_SIZE
        imul    r8, qword ptr [rcx + ADDR_SPRITE_COUNT]
        add     r8, rcx
        add     r8, ADDR_SPRITE_LIST

        mov     word  ptr [r8 + SPRITE_X], r9w          # sprite x
        mov     word  ptr [r8 + SPRITE_Y], r10w         # sprite y
        mov     ax, word ptr [rdi + r11 * 2]
        mov     word  ptr [r8 + SPRITE_W], ax           # sprite w
        mov     ax, word ptr [rsi + r11 * 2]
        mov     word  ptr [r8 + SPRITE_H], ax           # sprite h
        mov     word  ptr [r8 + SPRITE_IMAGE], r11w     # sprite image
        mov     word  ptr [r8 + SPRITE_TYPE], r12w      # sprite type
        mov     word  ptr [r8 + SPRITE_LIFE], r13w      # sprite life
        mov     qword ptr [r8 + SPRITE_TIMEOUT], r14    # sprite timeout
        mov     qword ptr [r8 + SPRITE_DATA], r15       # sprite data
        add     qword ptr [rcx + ADDR_SPRITE_COUNT], 1

        pop     rax
        ret


delete_sprite:
 /***************
  * Create a sprite
  * Needed registers :
  *      rcx : data memory
  *      r8  : sprite to delete
  ***************/

        sub     qword ptr [rcx + ADDR_SPRITE_COUNT], 1
        mov     r9, SPRITE_SIZE
        imul    r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
        add     r9, rcx
        add     r9, ADDR_SPRITE_LIST

_delete_loop:
        cmp     r8, r9
        jg      _end_delete_loop

        # move block
        mov     r10, qword  ptr [r8 + SPRITE_SIZE]
        mov     qword  ptr [r8], r10
        mov     r10, qword  ptr [r8 + SPRITE_SIZE + 8]
        mov     qword  ptr [r8 + 8], r10
        mov     r10, qword ptr [r8 + SPRITE_SIZE + 16]
        mov     qword  ptr [r8 + 16], r10
        mov     r10, qword  ptr [r8 + SPRITE_SIZE + 24]
        mov     qword  ptr [r8 + 24], r10
        add     r8, SPRITE_SIZE
        jmp     _delete_loop
_end_delete_loop:
        ret


draw_sprite:
 /***************
  * Draw a image
  * Needed registers :
  *      rdi : images widths (set at call time)
  *      rsi : images heights (set at call time)
  *      rdx : images data (set at call time)
  *      r8  : sprite pointer
  * Template :
        mov r8, 24
        call draw_sprite
  ***************/
        push    rbp
        mov     rbp, rsp
        push    r8
        push    r9
        push    r10

        movzx   r10, word ptr [r8 + SPRITE_IMAGE]
        movzx   r9, word ptr [r8 + SPRITE_Y]
        movzx   r8, word ptr [r8 + SPRITE_X]
        call draw_image

        pop     r10
        pop     r9
        pop     r8

        mov     rsp, rbp
        pop     rbp
        ret


draw_image:
 /***************
  * Draw a image
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

_draw_image__for_y_in_range_height:

        /* Reverse iterat line e from width - 1 */
        mov     r13, r10
        dec     r13

_draw_image__for_x_in_range_width:

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
        jae     _draw_image__for_x_in_range_width

        sub     r11, 1
        jae     _draw_image__for_y_in_range_height

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
