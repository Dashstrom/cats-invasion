/*  vintage game - Travaux Pratiques UV AI24
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

#include <stdlib.h>
#include <stdint.h>

#include "definitions.h"
#include "utils.h"

#define TAILLEBALLE   (30)

void plot_balle(uint32_t x, uint32_t y, uint32_t img_width, uint8_t *img_src, uint32_t color){
	uint32_t* ptr;

	for (int i = 0; i < TAILLEBALLE ; i++)
		for (int j = 0; j < TAILLEBALLE ; j++ ){
			ptr = ((uint32_t*)img_src + (y + i)*img_width + (x + j));
			//ptr = (uint32_t*)(img_src);
			*ptr = color;
	}


}

/* process_image_c
 *
 * Implémentation en C de l'algorithme de traitement
 *
 */
void process_game1_c(uint32_t img_width, uint32_t img_height,
        uint8_t *img_src, void *Data)
{


	struct game_elements *elements_ptr;

	elements_ptr = (struct game_elements *) Data;

	if (elements_ptr->flag_start == 0) {
		elements_ptr->flag_start = 1;
		elements_ptr->flag_stop = 0;
		elements_ptr->x = 1;
		elements_ptr->y = 1;
		elements_ptr->var_x = 1;
		elements_ptr->var_y = 1;
		elements_ptr->color = 0xFF0F0F0F;

	} else {
		// attente pour fluidiser le déplacement
		for (uint64_t j = 0; j < 1000000; ++j);

		// conserver la balle dans la fenetre graphique
		if (elements_ptr->x >= img_width-TAILLEBALLE){
			elements_ptr->var_x = -1;
			elements_ptr->color = leftRotate(elements_ptr->color, 3);
			elements_ptr->bounce ++;
		}else if (elements_ptr->x <= 0) {
			elements_ptr->var_x = 1;
			elements_ptr->color = leftRotate(elements_ptr->color, 3);
			elements_ptr->bounce ++;
		}
		if (elements_ptr->y >= img_height-TAILLEBALLE){
			elements_ptr->var_y = -1;
			elements_ptr->color = leftRotate(elements_ptr->color, 3);
			elements_ptr->bounce ++;
		}else if (elements_ptr->y <= 0) {
			elements_ptr->var_y = 1;
			elements_ptr->color = leftRotate(elements_ptr->color, 3);
			elements_ptr->bounce ++;
		}

		// Effacer l'écran
		plot_balle(elements_ptr->x, elements_ptr->y, img_width, img_src, 0XFF000000);

		// décaler les éléments
		elements_ptr->x = elements_ptr->x + elements_ptr->var_x;
		elements_ptr->y = elements_ptr->y + elements_ptr->var_y;
		//elements_ptr->color = leftRotate(elements_ptr->color, 1);

		// on trace les éléments aux nouveaux emplacements
		plot_balle(elements_ptr->x, elements_ptr->y, img_width, img_src, elements_ptr->color | 0XFF000000);

		if (elements_ptr->bounce >= 10){
			elements_ptr->flag_stop = 1;
		}

	}



}


