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
            Largeur de l'image : rdi
            Hauteur de l'image : rsi
            Pointeur sur l'image source : rdx
            Pointeur sur la zone de données : rcx

  
  Les registes rbx, rbp, r12, r13, r14, et r15 doivent être sauvegardés
  si vous les utilisez (sauvegarde par l'appelé). Les autres registres 
  peuvent être modifiés sans risque (sauvegardés par l'appelant).
***********************************************************************/

.global process_game1_asm
process_game1_asm:
  push    rbp
  mov     rbp, rsp
  push    rdi
  push    rsi
  push    rdx
  push    r12
  push	  rbx
  push    r14
  push    r15

  /***********************************************************
    Ajoutez votre code ici
  **********************************************************/




  pop   r15
  pop   r14
  pop   rbx
  pop   r12
  pop   rdx
  pop   rsi
  pop   rdi
  pop   rbp
  ret









