/*  Atelier Photo - Travaux Pratiques UV MI01
 Copyright (C) 2019 S. Bonnet, Université de Technologie de Compiègne

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
#ifndef __PROCESS_FUNCTIONS_H__
#define __PROCESS_FUNCTIONS_H__

#include <stdint.h>


/* 

 Déclarations des fonctions de traitement

*/
void process_game1_asm(uint32_t img_width, uint32_t img_height, uint8_t *img_src, void *Donnees_ptr);
void process_game1_c(uint32_t img_width, uint32_t img_height, uint8_t *img_src, void *Donnees_ptr);

void plot_balle(uint32_t x, uint32_t y, uint32_t img_width, uint8_t *img_src, uint32_t color);


#endif
