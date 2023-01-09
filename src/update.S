.file "update.S"
.intel_syntax noprefix

.data

/* Configuration */
DEFAULT_SEED = 625726124
CAT_SHOT_INTERVAL = 0x1ff
CAT_SHOT_SPEED = 16
PADDING_X = 8
PADDING_Y = 8
CAT_LINES = 5
CAT_COLUMNS = 12
CAT_SPACE_X = 46
CAT_SPACE_Y = 54
SPACESHIP_SPEED = 6
SPACESHIP_SHOT_SPEED = 32
SPACESHIP_SHOT_INTERVAL = 16
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
GAMEOVER_IMAGE = 15

/* Types */
SPACESHIP_TYPE = 0
CAT_TYPE = 1
KENNEL_TYPE = 2
FOOD_TYPE = 3
MOUSE_TYPE = 4

/* Relatives addresses to sprite  */
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

/* Relatives addresses to rcx */
ADDR_START = 0
ADDR_STOP = 8
ADDR_SEED = 16
ADDR_MOVE_LEFT = 24
ADDR_MOVE_RIGHT = 25
ADDR_SHOOT = 26
ADDR_SPRITE_COUNT = 27
ADDR_TICK = 35
ADDR_CATS_COUNT = 43
ADDR_CATS_MOVE = 51
ADDR_CATS_DOWN = 52
ADDR_SPRITE_LIST = 53
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


/***********************************************************************
  Save registers
***********************************************************************/

_save_registers:
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


/***********************************************************************
  Initialization
***********************************************************************/

_initialization:
        /* Check if init */
        mov     r8, qword ptr [rcx + ADDR_START]
        cmp     r8, 0
        jne     _initialization__end

        /* Initialization */
        mov     qword ptr [rcx + ADDR_START], 1
        mov     qword ptr [rcx + ADDR_STOP], 0
        mov     qword ptr [rcx + ADDR_SEED], DEFAULT_SEED
        mov     byte ptr [rcx + ADDR_MOVE_LEFT], 1
        mov     byte ptr [rcx + ADDR_MOVE_RIGHT], 1
        mov     byte ptr [rcx + ADDR_SHOOT], 1
        mov     qword ptr [rcx + ADDR_SPRITE_COUNT], 0
        mov     qword ptr [rcx + ADDR_TICK], 0
        mov     qword ptr [rcx + ADDR_CATS_COUNT], 0
        mov     byte ptr [rcx + ADDR_CATS_MOVE], 1
        mov     byte ptr [rcx + ADDR_CATS_DOWN], 0

        /* Create spaceship */
        mov     r9, 364                 # x
        mov     r10, 528                # y
        mov     r11, SPACESHIP1_IMAGE   # image
        mov     r12, SPACESHIP_TYPE     # image
        mov     r13, SPACESHIP_LIFE     # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data
        call    create_sprite

        /* Create kennel */
        mov     r10, 448                # y
        mov     r11, KENNEL4_IMAGE      # image
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

        /* Create cats */
        mov     r11, CAT_IMAGE          # image
        mov     r12, CAT_TYPE           # type
        mov     r13, 1                  # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data

        mov     r10, (CAT_LINES - 1) * CAT_SPACE_Y + PADDING_Y + 40

_initialization__create_cat_lines:
        mov     r9, (CAT_COLUMNS - 1) * CAT_SPACE_X + PADDING_X + 1

_initialization__create_cat_columns:
        call    randint
        and     r14, CAT_SHOT_INTERVAL
        call    create_sprite

        sub     r9, CAT_SPACE_X
        cmp     r9, PADDING_X + 1
        jge     _initialization__create_cat_columns

        sub     r10, CAT_SPACE_Y
        cmp     r10, PADDING_Y + 40
        jge     _initialization__create_cat_lines

_initialization__end:


/***********************************************************************
  Game over
***********************************************************************/

_gameover:
        cmp     word ptr [rcx + ADDR_SPACESHIP + SPRITE_LIFE], 0
        jg      _gameover__end

        mov     r8, 0
        mov     r9, 0
        mov     r10, GAMEOVER_IMAGE
        call    draw_image

        jmp     _update__end

_gameover__end:


/***********************************************************************
  Spaceship animation
***********************************************************************/

_spaceship_animation:
        mov     r8b, byte ptr [rcx + ADDR_TICK]
        and     r8b, 2
        cmp     r8b, 0
        jne     _spaceship_animation__else

_spaceship_animation__if_tick_modulo_2_is_0:
        mov     word ptr [rcx + ADDR_SPACESHIP + SPRITE_IMAGE], SPACESHIP1_IMAGE
        jmp     _spaceship_animation__end

_spaceship_animation__else:
        mov     word ptr [rcx + ADDR_SPACESHIP + SPRITE_IMAGE], SPACESHIP2_IMAGE

_spaceship_animation__end:


/***********************************************************************
  Spaceship shoot
***********************************************************************/

_spaceship_shoot:
        cmp     qword ptr[rcx + ADDR_SPACESHIP + SPRITE_TIMEOUT], 0
        jg      _spaceship_shoot__elif_not_shooting_and_cooldown_ne_0
        cmp     byte ptr [rcx + ADDR_SHOOT], 0
        je      _spaceship_shoot__end

_spaceship_shoot__if_shoot_cooldown_eq_0:
        mov     qword ptr[rcx + ADDR_SPACESHIP + SPRITE_TIMEOUT], SPACESHIP_SHOT_INTERVAL

        mov     r9w, word ptr[rcx + ADDR_SPACESHIP + SPRITE_W]
        shr     r9w, 1
        add     r9w, word ptr[rcx + ADDR_SPACESHIP + SPRITE_X]
        mov     bx, word ptr[rdi + FOOD_IMAGE * 2]
        shr     bx, 1
        sub     r9w, bx

        mov     r10w, word ptr[rcx + ADDR_SPACESHIP + SPRITE_Y]
        sub     r10w, word ptr[rsi + FOOD_IMAGE * 2]

        mov     r11, FOOD_IMAGE         # image
        mov     r12, FOOD_TYPE          # type
        mov     r13, 1                  # life
        mov     r14, 0                  # timeout
        mov     r15, 0                  # data
        call    create_sprite

_spaceship_shoot__elif_not_shooting_and_cooldown_ne_0:
        sub qword ptr[rcx + ADDR_SPACESHIP + SPRITE_TIMEOUT], 1

_spaceship_shoot__end:


/***********************************************************************
  Spaceship move
***********************************************************************/

_spaceship_move:
        cmp     byte ptr [rcx + ADDR_MOVE_LEFT], 0
        je      __spaceship_move__right
        cmp     byte ptr [rcx + ADDR_MOVE_RIGHT], 0
        jne      _spaceship_move__end

__spaceship_move__left:
        sub     word ptr [rcx + ADDR_SPACESHIP + SPRITE_X], SPACESHIP_SPEED
        cmp     word ptr [rcx + ADDR_SPACESHIP + SPRITE_X], PADDING_X
        jge     _spaceship_move__end
        mov     word ptr [rcx + ADDR_SPACESHIP + SPRITE_X], PADDING_X
        jmp     _spaceship_move__end

__spaceship_move__right:
        cmp     byte ptr [rcx + ADDR_MOVE_RIGHT], 0
        je      _spaceship_move__end
        add     word ptr [rcx + ADDR_SPACESHIP + SPRITE_X], SPACESHIP_SPEED
        mov     ax, word ptr [rcx + ADDR_SPACESHIP + SPRITE_X]
        add     ax, word ptr [rcx + ADDR_SPACESHIP + SPRITE_W]
        cmp     ax, WIDTH_SCREEN - PADDING_X
        jl      _spaceship_move__end
        mov     ax, WIDTH_SCREEN - PADDING_X
        sub     ax, word ptr [rcx + ADDR_SPACESHIP + SPRITE_W]
        mov     word ptr [rcx + ADDR_SPACESHIP + SPRITE_X], ax

_spaceship_move__end:


/***********************************************************************
  Find min and max position of cats
***********************************************************************/

_max_min_cat:
        mov     r12w, WIDTH_SCREEN
        mov     r13w, 0
        mov     r14w, 0
        lea     r10, [rip + _max_min_cat__callback]
        mov     r11, CAT_TYPE
        call    apply_sprites
        jmp     __max_min_cat__end

_max_min_cat__callback:
        mov     r9w, word ptr [r8 + SPRITE_X]
        cmp     r12w, r9w
        cmovg   r12w, r9w
        add     r9w, word ptr [r8 + SPRITE_W]
        cmp     r13w, r9w
        cmovl   r13w, r9w
        inc     r14w
        ret

__max_min_cat__end:


/***********************************************************************
  Update move cats
***********************************************************************/

_update_cat_move:
        mov     r15w, 0
        cmp     r12w, PADDING_X
        jle     _update_cat_move__right
        cmp     r13w, WIDTH_SCREEN - PADDING_X
        jge     _update_cat_move__left
        jmp     _update_cat_move__end_turn

_update_cat_move__left:
        mov    byte ptr [rcx + ADDR_CATS_MOVE], - 1
        mov    r15w, CAT_SPACE_Y
        jmp     _update_cat_move__end_turn

_update_cat_move__right:
        mov    byte ptr [rcx + ADDR_CATS_MOVE], 1
        mov    r15w, CAT_SPACE_Y

_update_cat_move__end_turn:
        cmp     r14w, 2
        jge     _update_cat_move__elif_cat_count_ge_2

_update_cat_move__if_cat_count_eq_1:
        mov     rbx, 16
        jmp     _update_cat_move__endif

_update_cat_move__elif_cat_count_ge_2:
        cmp     r14w, 4
        jge     _update_cat_move__elif_cat_count_ge_4
        mov     rbx, 12
        jmp     _update_cat_move__endif

_update_cat_move__elif_cat_count_ge_4:
        cmp     r14w, 8
        jge     _update_cat_move__elif_cat_count_ge_8
        mov     rbx, 8
        jmp     _update_cat_move__endif

_update_cat_move__elif_cat_count_ge_8:
        cmp     r14w, 16
        jge     _update_cat_move__elif_cat_count_ge_16
        mov     rbx, 4
        jmp     _update_cat_move__endif

_update_cat_move__elif_cat_count_ge_16:
        cmp     r14w, 32
        jge     _update_cat_move__elif_cat_count_ge_32
        mov     rbx, 2
        jmp     _update_cat_move__endif

_update_cat_move__elif_cat_count_ge_32:
        mov     rbx, 1

_update_cat_move__endif:
        movsx   rax, byte ptr [rcx + ADDR_CATS_MOVE]
        imul    rax, rbx

        add     r12w, ax
        cmp     r12w, PADDING_X
        jl      _update_cat_move__if_cat_overflow_on_left
        add     r13w, ax
        cmp     r13w, WIDTH_SCREEN - PADDING_X
        jge     _update_cat_move__if_cat_overflow_on_right
        jmp     _update_cat_move__end

_update_cat_move__if_cat_overflow_on_left:
        sub     r12w, ax
        mov     ax, PADDING_X
        sub     ax, r12w
        jmp     _update_cat_move__end

_update_cat_move__if_cat_overflow_on_right:
        sub     r13w, ax
        mov     ax, WIDTH_SCREEN - PADDING_X
        sub     ax, r13w

_update_cat_move__end:


/***********************************************************************
  Update cats
***********************************************************************/

_update_cat:
        lea     r10, [rip + _update_cat__callback]
        mov     r11, CAT_TYPE
        call    apply_sprites
        jmp     _update_cat__end

_update_cat__callback:
        mov     r14, qword ptr [r8 + SPRITE_TIMEOUT]
        cmp     r14, 0
        jg      _update_cat__callback_not_shooting
        mov     qword ptr [r8 + SPRITE_TIMEOUT], CAT_SHOT_INTERVAL

        push    r8
        push    r9
        push    r10
        push    r11
        push    r12
        push    r13
        push    r14
        push    r15

        mov     r9w, word ptr [r8 + SPRITE_W]   # x
        ror     r9w, 1
        add     r9w, word ptr [r8 + SPRITE_X]

        mov     r10w, word ptr [r8 + SPRITE_H]  # y
        ror     r10w, 1
        add     r10w, word ptr [r8 + SPRITE_Y]  # y


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

_update_cat__callback_not_shooting:
        sub     qword ptr [r8 + SPRITE_TIMEOUT], 1

        cmp     r15w, 0
        je      _update_cat__callback_move
        add     word ptr [r8 + SPRITE_Y], r15w
        movsx   bx, byte ptr [rcx + ADDR_CATS_MOVE]
        add     word ptr [r8 + SPRITE_X], bx
        jmp     _update_cat__callback_go_down

_update_cat__callback_move:
        add     word ptr [r8 + SPRITE_X], ax

_update_cat__callback_go_down:
        mov     r14w, word ptr [r8 + SPRITE_Y]
        add     r14w, word ptr [r8 + SPRITE_H]
        cmp     r14w, HEIGHT_SCREEN
        jl      _update_cat__callback_not_ouside

        mov    word ptr [r8 + SPRITE_LIFE], 0
        sub    word ptr [rcx + ADDR_SPACESHIP + SPRITE_LIFE], 1

_update_cat__callback_not_ouside:
        ret

_update_cat__end:


/***********************************************************************
  Update mouse
***********************************************************************/

_update_mouse:
        lea     r10, [rip + _update_mouse__callback]
        mov     r11, MOUSE_TYPE
        call    apply_sprites
        jmp     _update_mouse__end

_update_mouse__callback:
        add     word ptr [r8 + SPRITE_Y], CAT_SHOT_SPEED
        mov     r10w, word ptr [r8 + SPRITE_Y]
        add     r10w, word ptr [r8 + SPRITE_H]
        cmp     r10w, HEIGHT_SCREEN
        jl      _update_mouse__callback__else

_update_mouse__callback__if_ouside:
        call    delete_sprite

_update_mouse__callback__else:
        ret

_update_mouse__end:


/***********************************************************************
  Update food
***********************************************************************/

_update_food:
        lea     r10, [rip + _update_food__callback]
        mov     r11, FOOD_TYPE
        call    apply_sprites
        jmp     _update_food__end

_update_food__callback:
        sub     word ptr [r8 + SPRITE_Y], SPACESHIP_SHOT_SPEED
        cmp     word ptr [r8 + SPRITE_Y], 0
        jge     _update_food__callback__else

_update_food__callback__if_ouside:
        call    delete_sprite

_update_food__callback__else:
        ret

_update_food__end:


/***********************************************************************
  Interaction
***********************************************************************/

_interaction:
        mov     r8, SPRITE_SIZE
        mov     r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
        dec     r9
        imul    r8, r9
        mov     r9, rcx
        add     r9, ADDR_SPRITE_LIST
        add     r8, r9

_interaction__for_sprite_in_sprites:
        mov     r10, SPRITE_SIZE
        mov     r11, qword ptr [rcx + ADDR_SPRITE_COUNT]
        dec     r11
        imul    r10, r11
        mov     r11, rcx
        add     r11, ADDR_SPRITE_LIST
        add     r10, r11

_interaction__for_contact_in_sprites:
        /* No self interaction */
        cmp     r8, r10
        je      _interaction__if_not_intersect

        /* Dead sprite dont act */
        cmp     word ptr [r8 + SPRITE_LIFE], 0
        jle     _interaction__if_not_intersect
        cmp     word ptr [r10 + SPRITE_LIFE], 0
        jle     _interaction__if_not_intersect

        /* x1 < x2 + w2 */
        mov     r12w, word ptr [r8 + SPRITE_X]
        mov     r13w, word ptr [r10 + SPRITE_X]
        add     r13w, word ptr [r10 + SPRITE_W]
        cmp     r12w, r13w
        jge     _interaction__if_not_intersect

        /* x2 < x1 + w1 */
        mov     r13w, word ptr [r10 + SPRITE_X]
        add     r12w, word ptr [r8 + SPRITE_W]
        cmp     r13w, r12w
        jge     _interaction__if_not_intersect

        /* y1 < y2 + h2 */
        mov     r12w, word ptr [r8 + SPRITE_Y]
        mov     r13w, word ptr [r10 + SPRITE_Y]
        add     r13w, word ptr [r10 + SPRITE_H]
        cmp     r12w, r13w
        jge     _interaction__if_not_intersect

        /* y2 < y1 + h1 */
        mov     r13w, word ptr [r10 + SPRITE_Y]
        add     r12w, word ptr [r8 + SPRITE_H]
        cmp     r13w, r12w
        jge     _interaction__if_not_intersect
	
        /* Save local registers */
        push    r8
        push    r9
        push    r10
        push    r11


/***********************************************************************
  Interaction sprite by sprite, r8 for sprite, r10 for contact, no deletion
***********************************************************************/

_interaction__kennel_mouse:
        cmp     word ptr [r8 + SPRITE_TYPE], MOUSE_TYPE
        jne     _interaction__kennel_mouse_end
        cmp     word ptr [r10 + SPRITE_TYPE], KENNEL_TYPE
        jne     _interaction__kennel_mouse_end

        sub     word ptr [r8 + SPRITE_LIFE],  1
        sub     word ptr [r10 + SPRITE_LIFE], 1

_interaction__kennel_mouse_end:


_interaction__spaceship_mouse:
        cmp     word ptr [r8 + SPRITE_TYPE], MOUSE_TYPE
        jne     _interaction__spaceship_mouse_end
        cmp     word ptr [r10 + SPRITE_TYPE], SPACESHIP_TYPE
        jne     _interaction__spaceship_mouse_end

        sub     word ptr [r8 + SPRITE_LIFE],  1
        sub     word ptr [r10 + SPRITE_LIFE], 1

_interaction__spaceship_mouse_end:


_interaction__food_cat:
        cmp     word ptr [r8 + SPRITE_TYPE], FOOD_TYPE
        jne     _interaction__food_cat_end
        cmp     word ptr [r10 + SPRITE_TYPE], CAT_TYPE
        jne     _interaction__food_cat_end

        sub     word ptr [r8 + SPRITE_LIFE],  1
        sub     word ptr [r10 + SPRITE_LIFE], 1

_interaction__food_cat_end:


_interaction__food_kennel:
        cmp     word ptr [r8 + SPRITE_TYPE], FOOD_TYPE
        jne     _interaction__food_kennel_end
        cmp     word ptr [r10 + SPRITE_TYPE], KENNEL_TYPE
        jne     _interaction__food_kennel_end

        sub     word ptr [r8 + SPRITE_LIFE],  1

_interaction__food_kennel_end:


_interaction__cat_spaceship:
        cmp     word ptr [r8 + SPRITE_TYPE], CAT_TYPE
        jne     _interaction__cat_spaceship_end
        cmp     word ptr [r10 + SPRITE_TYPE], SPACESHIP_TYPE
        jne     _interaction__cat_spaceship_end

        sub     word ptr [r8 + SPRITE_LIFE], 1
        sub     word ptr [r10 + SPRITE_LIFE], 1

_interaction__cat_spaceship_end:


_interaction__cat_kennel:
        cmp     word ptr [r8 + SPRITE_TYPE], CAT_TYPE
        jne     _interaction__cat_kennel_end
        cmp     word ptr [r10 + SPRITE_TYPE], KENNEL_TYPE
        jne     _interaction__cat_kennel_end

        sub     word ptr [r10 + SPRITE_LIFE], 1

_interaction__cat_kennel_end:


/***********************************************************************
  End interaction sprite by sprite
***********************************************************************/
	/* Reload local registers */
        pop     r11
        pop     r10
        pop     r9
        pop     r8

_interaction__if_not_intersect:
        sub     r10, SPRITE_SIZE
        cmp     r10, r11
        jge     _interaction__for_contact_in_sprites

        sub     r8, SPRITE_SIZE
        cmp     r8, r9
        jge      _interaction__for_sprite_in_sprites


/***********************************************************************
  Update kennel
***********************************************************************/

_update_kennel:
        lea     r10, [rip + _update_kennel__callback]
        mov     r11, KENNEL_TYPE
        call    apply_sprites
        jmp     _update_kennel__end

_update_kennel__callback:
        cmp     word ptr [r8 + SPRITE_LIFE], 1
        jg     _update_kennel__callback_kennel_2

_update_kennel__callback_kennel_1:
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL1_IMAGE
        jmp     _update_kennel__callback_end

_update_kennel__callback_kennel_2:
        cmp     word ptr [r8 + SPRITE_LIFE], 2
        jg      _update_kennel__callback_kennel_3
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL2_IMAGE
        jmp     _update_kennel__callback_end

_update_kennel__callback_kennel_3:
        cmp     word ptr [r8 + SPRITE_LIFE], 3
        jg      _update_kennel__callback_kennel_4
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL3_IMAGE
        jmp     _update_kennel__callback_end

_update_kennel__callback_kennel_4:
        mov     word ptr [r8 + SPRITE_IMAGE], KENNEL4_IMAGE

_update_kennel__callback_end:
        ret

_update_kennel__end:


/***********************************************************************
  Loop for deletion
***********************************************************************/

_deletion:
        mov     r8, SPRITE_SIZE
        mov     r9, qword ptr [rcx + ADDR_SPRITE_COUNT]
        dec     r9
        imul    r8, r9

        mov     r9, rcx
        add     r9, ADDR_SPRITE_LIST

        add     r8, r9

_deletion__for_sprite_in_sprites:
        cmp     word ptr [r8 + SPRITE_LIFE], 0

        jg      _deletion__else

_deletion__if_life_lg_0:
        call    delete_sprite

_deletion__else:
        sub     r8, SPRITE_SIZE
        cmp     r8, r9
        jg      _deletion__for_sprite_in_sprites

_deletion__end:


/***********************************************************************
  Draw background
***********************************************************************/

        mov     r8, 0
        mov     r9, 0
        mov     r10, VOID_IMAGE
        call    draw_image


/***********************************************************************
  Draw all sprites : TODO invert this
***********************************************************************/

_draw_sprites:
        mov     r11, rcx
        add     r11, ADDR_SPRITE_LIST
        mov     r12, qword ptr [rcx + ADDR_SPRITE_COUNT]

_draw_sprites__for_sprite_in_sprites:

        movzx   r8, word ptr [r11 + SPRITE_X]
        movzx   r9, word ptr [r11 + SPRITE_Y]
        movzx   r10, word ptr [r11 + SPRITE_IMAGE]
        call    draw_image

        add     r11, SPRITE_SIZE
        sub     r12, 1
        jae     _draw_sprites__for_sprite_in_sprites


/***********************************************************************
  Draw heart
***********************************************************************/

_draw_hearts:
        movsx   r11, word ptr [rcx + ADDR_SPACESHIP + SPRITE_LIFE]
        cmp     r11, 0
        jg      _draw_hearts__any_case

_draw_hearts__if_life_lt_0:
        mov     r11, 0

_draw_hearts__any_case:
        mov     r12, SPACESHIP_LIFE
        sub     r12, r11
        mov     r8, PADDING_X
        mov     r9, PADDING_Y

        mov     r10, HEART_IMAGE

_draw_hearts__for_heart_in_hearts:
        cmp     r11, 0
        jle      _draw_hearts__end_for_heart_in_hearts
        call    draw_image
        add     r8, 40
        dec     r11
        jmp     _draw_hearts__for_heart_in_hearts

_draw_hearts__end_for_heart_in_hearts:


        mov     r10, EMPTY_HEART_IMAGE
_draw_hearts__for_heart_in_empty_hearts:

        cmp     r12, 0
        jle      _draw_hearts__end_for_heart_in_empty_hearts
        call    draw_image
        add     r8, 40
        dec     r12
        jmp     _draw_hearts__for_heart_in_empty_hearts

_draw_hearts__end_for_heart_in_empty_hearts:

_update__end:


/***********************************************************************
  Update gametick
***********************************************************************/

        add     qword ptr [rcx + ADDR_TICK], 1


/***********************************************************************
  Reload registers
***********************************************************************/

_reload_registers:
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



randint:
 /***************
  * Generate random number between 0 and 2^31.
  * More on https://en.wikipedia.org/wiki/Linear_congruential_generator
  * Needed registers :
  *      rcx : data memory
  * Return registers :
  *      r14 : the generated number
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



apply_sprites:
 /***************
  * Run a callback on every sprite iwth a given type.
  * Needed registers :
  *     r10 : callback (r8 : actual sprite, dont touch to r9)
  *     r11 : type
  ***************/
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
