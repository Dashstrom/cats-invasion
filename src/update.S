.file "update.S"
.intel_syntax noprefix

.data

/* Configuration */
DEFAULT_SEED = 168168761
CAT_SHOT_INTERVAL = 0x1ff
CAT_SPEED = 2
CAT_SHOT_SPEED = 16
SPACESHIP_SPEED = 2
SPACESHIP_SHOT_SPEED = 16
SPACESHIP_LIFE = 3
WIDTH_SCREEN = 800
HEIGHT_SCREEN = 600

/* Image indexes */
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
HEART_IMAGE = 13
EMPTY_HEART_IMAGE = 14

/* Types */
SPACESHIP_TYPE = 0
CAT_TYPE = 1
KENNEL_TYPE = 2
FOOD_TYPE = 3
MOUSE_TYPE = 4

/* Properties relative address */
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

/* Relative addresses to rcx */
ADDR_START = 0
ADDR_STOP = 8
ADDR_SEED = 16
ADDR_SPRITE_COUNT = 24
ADDR_TICK = 32
ADDR_SPRITE_LIST = 40
ADDR_SPACESHIP = ADDR_SPRITE_LIST

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

.global update
update:
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

        /* Check if init */
        mov     r8, qword ptr [rcx + ADDR_START]
        cmp     r8, 0
        jne     _already_initialized

        /* Initialization */
        mov     qword ptr [rcx + ADDR_START], 1
        mov     qword ptr [rcx + ADDR_STOP], 0
        mov     qword ptr [rcx + ADDR_SEED], DEFAULT_SEED
        mov     qword ptr [rcx + ADDR_SPRITE_COUNT], 0
        mov     qword ptr [rcx + ADDR_TICK], 0

        /* Create spaceship */
        mov     r9, 364
        mov     r10, 512                # y
        mov     r11, SPACESHIP1_IMAGE   # image
        mov     r12, SPACESHIP_TYPE     # image
        mov     r13, SPACESHIP_LIFE     # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data
        call    create_sprite

        /* Create cats */
        mov     r10, 48                 # y
        mov     r11, CAT_IMAGE          # image
        mov     r12, CAT_TYPE           # type
        mov     r13, 1                  # life
        mov     r14, 0                  # timeout
        mov     r15, 1 # data

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 16
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 82
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 148
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 214
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 280
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 346
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 412
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 478
        call    create_sprite

        add     r10, 80                 # next line

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 16
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 82
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 148
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 214
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 280
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 346
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 412
        call    create_sprite

        call    lcg_randint
        and     r14, CAT_SHOT_INTERVAL
        mov     r9, 478
        call    create_sprite

        /* Create kennel */
        mov     r10, 432                # y
        mov     r11, KENNEL4_IMAGE      # image
        mov     r12, KENNEL_TYPE        # image
        mov     r13, 4                  # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data

        mov     r9, 128
        call    create_sprite

        mov     r9, 288
        call    create_sprite

        mov     r9, 448
        call    create_sprite

        mov     r9, 608
        call    create_sprite


_already_initialized:

/***********************************************************************
  Spaceship animation
***********************************************************************/
_spaceship_animation:
        mov     r8b, byte ptr [rcx + ADDR_TICK]
        and     r8b, 1
        cmp     r8b, 0
        jne     _spaceship_animation__else
_spaceship_animation__if_tick_modulo_2_is_0:
        mov     word ptr [rcx + ADDR_SPACESHIP + SPRITE_IMAGE], SPACESHIP1_IMAGE
        jmp     _spaceship_animation__endif
_spaceship_animation__else:
        mov     word ptr [rcx + ADDR_SPACESHIP + SPRITE_IMAGE], SPACESHIP2_IMAGE
_spaceship_animation__endif:


/***********************************************************************
  Find min and max position of cats
***********************************************************************/
_max_min_cat:
        mov     r12w, WIDTH_SCREEN
        mov     r13w, 0
        lea     r10, [rip + _callback_max_min_cat]
        mov     r11, CAT_TYPE
        call    apply_sprites
        jmp     _end_callback_max_min_cat
_callback_max_min_cat:
        mov     r9w, word ptr [r8 + SPRITE_X]
        cmp     r12w, r9w
        cmovg   r12w, r9w
        add     r9w, word ptr [r8 + SPRITE_W]
        cmp     r13w, r9w
        cmovl   r13w, r9w
        ret
_end_callback_max_min_cat:
        

/***********************************************************************
  Update cats
***********************************************************************/
_update_cat:
        lea     r10, [rip + _callback_update_cat]
        mov     r11, CAT_TYPE
        call    apply_sprites
        jmp     _end_callback_update_cat
_callback_update_cat:

        mov     r14, qword ptr [r8 + SPRITE_TIMEOUT]
        cmp     r14, 0
        jg      _callback_update_cat__not_shooting
        mov     qword ptr [r8 + SPRITE_TIMEOUT], CAT_SHOT_INTERVAL

        push    r8
        push    r9
        push    r10
        push    r11
        push    r12
        push    r13
        push    r14
        push    r15

        mov     r9w, word ptr [r8 + SPRITE_W]            # x
        ror     r9w, 1
        add     r9w, word ptr [r8 + SPRITE_X]

        mov     r10w, word ptr [r8 + SPRITE_H]                # y
        ror     r10w, 1
        add     r10w, word ptr [r8 + SPRITE_Y]                # y


        mov     r11, MOUSE_IMAGE        # image
        mov     r12, MOUSE_TYPE         # type
        mov     r13, 1                  # life
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

_callback_update_cat__not_shooting:
        sub     qword ptr [r8 + SPRITE_TIMEOUT], 1

        cmp     r12w, 8
        jb      _callback_update_cat__turn_right
        cmp     r13w, WIDTH_SCREEN - 8
        ja      _callback_update_cat__turn_left
        jmp     _callback_update_cat__end_turn
_callback_update_cat__turn_left:
        mov    byte ptr [r8 + SPRITE_DATA], -1
        add    word ptr [r8 + SPRITE_Y], 10
        jmp     _callback_update_cat__end_turn
_callback_update_cat__turn_right:
        mov    byte ptr [r8 + SPRITE_DATA], 1
        add    word ptr [r8 + SPRITE_Y], 10
_callback_update_cat__end_turn:
        movsx   r9w, byte ptr [r8 + SPRITE_DATA]
        add     word ptr [r8 + SPRITE_X], r9w
        ret
_end_callback_update_cat:

/***********************************************************************
  Update mouse
***********************************************************************/
_update_mouse:
        lea     r10, [rip + _callback_update_mouse]
        mov     r11, MOUSE_TYPE
        call    apply_sprites
        jmp     _end_callback_update_mouse
_callback_update_mouse:
        add     word ptr [r8 + SPRITE_Y], CAT_SHOT_SPEED
        mov     r10w, word ptr [r8 + SPRITE_Y]
        add     r10w, word ptr [r8 + SPRITE_H]
        cmp     r10w, HEIGHT_SCREEN
        jl      _callback_update_mouse__not_outside
        call    delete_sprite
_callback_update_mouse__not_outside:
        ret
_end_callback_update_mouse:

/***********************************************************************
  Interaction
***********************************************************************/

        mov     r8, SPRITE_SIZE
        mov     r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
        dec     r9
        imul    r8, r9
        mov     r9, rcx
        add     r9, ADDR_SPRITE_LIST
        add     r8, r9
_for_sprite_in_sprites:

        /*perfrom action*/
        mov     r10, SPRITE_SIZE
        mov     r11, qword ptr [rcx + ADDR_SPRITE_COUNT]
        dec     r11
        imul    r10, r11
        mov     r11, rcx
        add     r11, ADDR_SPRITE_LIST
        add     r10, r11
_for_contact_in_sprites:

        /* No self interaction */
        cmp     r8, r10
        je      _no_intersect

        /* Dead dont act */
        cmp     word ptr [r8 + SPRITE_LIFE], 0
        jle     _no_intersect
        cmp     word ptr [r10 + SPRITE_LIFE], 0
        jle     _no_intersect

        /* x1 < x2 + w2 */
        mov     r12w, word ptr [r8 + SPRITE_X]
        mov     r13w, word ptr [r10 + SPRITE_X]
        add     r13w, word ptr [r10 + SPRITE_W]
        cmp     r12w, r13w
        jge     _no_intersect

        /* x2 < x1 + w1 */
        mov     r13w, word ptr [r10 + SPRITE_X]
        add     r12w, word ptr [r8 + SPRITE_W]
        cmp     r13w, r12w
        jge     _no_intersect

        /* y1 < y2 + h2 */
        mov     r12w, word ptr [r8 + SPRITE_Y]
        mov     r13w, word ptr [r10 + SPRITE_Y]
        add     r13w, word ptr [r10 + SPRITE_H]
        cmp     r12w, r13w
        jge     _no_intersect

        /* y2 < y1 + h1 */
        mov     r13w, word ptr [r10 + SPRITE_Y]
        add     r12w, word ptr [r8 + SPRITE_H]
        cmp     r13w, r12w
        jge     _no_intersect

        push    r8
        push    r9
        push    r10
        push    r11


/***********************************************************************
  Interaction sprite by sprite, r8 for sprite, r10 for contact, no deletion here
***********************************************************************/
_interact_kennel_mouse:
        cmp     word ptr [r8 + SPRITE_TYPE], MOUSE_TYPE
        jne     _end_interact_kennel_mouse
        cmp     word ptr [r10 + SPRITE_TYPE], KENNEL_TYPE
        jne     _end_interact_kennel_mouse

        sub     word ptr [r8 + SPRITE_LIFE],  1
        sub     word ptr [r10 + SPRITE_LIFE], 1
_end_interact_kennel_mouse:

_interact_spaceship_mouse:
        cmp     word ptr [r8 + SPRITE_TYPE], MOUSE_TYPE
        jne     _end_interact_spaceship_mouse
        cmp     word ptr [r10 + SPRITE_TYPE], SPACESHIP_TYPE
        jne     _end_interact_spaceship_mouse

        sub     word ptr [r8 + SPRITE_LIFE],  1
        sub     word ptr [r10 + SPRITE_LIFE], 1

_end_interact_spaceship_mouse:

/***********************************************************************
  End interaction sprite by sprite
***********************************************************************/

        pop     r11
        pop     r10
        pop     r9
        pop     r8
_no_intersect:

        sub     r10, SPRITE_SIZE
        cmp     r10, r11
        jge      _for_contact_in_sprites
        /*end perfrom action*/

        sub     r8, SPRITE_SIZE
        cmp     r8, r9
        jge      _for_sprite_in_sprites

/***********************************************************************
  Update kennel
***********************************************************************/
        lea     r10, [rip + _callback_update_kennel]
        mov     r11, KENNEL_TYPE
        call    apply_sprites
        jmp     _end_callback_update_kennel
_callback_update_kennel:
        cmp     word ptr [r8 + SPRITE_LIFE], 1
        jg     _n1
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL1_IMAGE
        jmp     _nend
_n1:
        cmp     word ptr [r8 + SPRITE_LIFE], 2
        jg      _n2
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL2_IMAGE
        jmp     _nend
_n2:
        cmp     word ptr [r8 + SPRITE_LIFE], 3
        jg      _n3
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL3_IMAGE
        jmp     _nend
_n3:
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL4_IMAGE
_nend:
        ret
_end_callback_update_kennel:

/***********************************************************************
  Loop for deletion
***********************************************************************/

        mov     r8, SPRITE_SIZE
        mov     r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
        dec     r9
        imul    r8, r9

        mov     r9, rcx
        add     r9, ADDR_SPRITE_LIST

        add     r8, r9

_garbage_death_loop:
        cmp     word ptr [r8 + SPRITE_LIFE], 0
        jg      _no_garbage
        call    delete_sprite
_no_garbage:
        sub     r8, SPRITE_SIZE
        cmp     r8, r9
        jg      _garbage_death_loop

/***********************************************************************
  Draw background
***********************************************************************/
        /* Draw all sprite ! */
        # Drawing the void
        mov     r8, 0
        mov     r9, 0
        mov     r10, VOID_IMAGE
        call    draw_image

/***********************************************************************
  Draw all sprites
***********************************************************************/
        mov     r8, rcx
        add     r8, ADDR_SPRITE_LIST
        mov     r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
_loop_draw:

        call    draw_sprite
        add     r8, SPRITE_SIZE
        sub     r9, 1
        jae     _loop_draw

/***********************************************************************
  Draw heart
***********************************************************************/
        movzx   r11, word ptr [rcx + ADDR_SPACESHIP + SPRITE_LIFE]
        mov     r12, SPACESHIP_LIFE
        sub     r12, r11
        mov     r8, 8
        mov     r9, 8
        mov     r10, HEART_IMAGE
_loop_heart:
        cmp     r11, 0
        je      _end_loop_heart
        call    draw_image
        add     r8, 40
        dec     r11
        jmp     _loop_heart
_end_loop_heart:
        mov     r10, EMPTY_HEART_IMAGE
_loop_empty_heart:
        cmp     r12, 0
        je      _end_loop_empty_heart
        call    draw_image
        add     r8, 40
        dec     r12
        jmp     _loop_empty_heart
_end_loop_empty_heart:

        /* Update tick */
        add     qword ptr [rcx + ADDR_TICK], 1

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
        jge     _apply_sprites__for_sprite_in_sprites

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