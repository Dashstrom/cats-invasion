/*  Atelier Photo - Travaux Pratiques UV MI01 modifié en mini-projet AI24

 Copyright (C) 2020 Stéphane Bonnet
 Copyright (C) 2021 Noé Amiot
 2022 JDM

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

#include <glib/gprintf.h>
#include <gtk/gtk.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "definitions.h"
#include "process_functions.h"

/*
 * Variables globales
 */

/* Nom de l'application */
const gchar application_name[] = "space-invaders-asm";

/* Chemin de l'image par défaut */
const gchar default_image[] = "data/fond_noir.bmp";

/* Pointeur vers la fenêtre pricipale de l'application */
GtkWidget *main_window;

/* Pointeur vers le widget d'affichage de l'image */
GtkWidget *image;

/* Numéro de l'image visible */
int visible_image = 0;

/* Buffers d'image */
#define N_BITMAPS (2)
#define IMG_SRC (0)

typedef struct _bitmap {
    gchar *name;
    GdkPixbuf *pixbuf;
} bitmap_t;

bitmap_t bitmaps[] = {{"data/fond_noir.bmp", NULL},
                      {"data/cat-explode.bmp", NULL},
                      {"data/projectile.bmp", NULL},
                      {"data/spaceship.bmp", NULL}};

/* Nombre de répétions à réaliser */
int process_repetitions = 50000;

/* Map des fonctions de traitement */
typedef struct _process_task {
    gchar *target;
    void (*process_fun)(uint16_t *, uint16_t *, uint8_t **, void *);
} process_task_t;

process_task_t process_tasks[] = {
    {"c", process_game1_c}, {"asm", process_game1_asm}, {NULL, NULL}};

/* Pointeur vers la fonction de traitement à utiliser */
void *Donnees_ptr;

/*
 * Boîtes de dialogue
 */

/* file_chooser
 *
 * Sélection d'un fichier bitmap.
 *
 * Retourne le nom du fichier ou NULL.
 * La chaine retournée doit être libérée avec g_free.
 *
 */
gchar *file_chooser() {
    GtkWidget *dialog = gtk_file_chooser_dialog_new(
        "Choisissez une image", GTK_WINDOW(main_window),
        GTK_FILE_CHOOSER_ACTION_OPEN, "Ouvrir", GTK_RESPONSE_ACCEPT, "Annuler",
        GTK_RESPONSE_CANCEL, NULL);

    gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(dialog), ".");

    GtkFileFilter *filter = gtk_file_filter_new();
    gtk_file_filter_set_name(filter, "Images");
    gtk_file_filter_add_mime_type(filter, "image/bmp");
    gtk_file_filter_add_mime_type(filter, "image/jpeg");
    gtk_file_filter_add_mime_type(filter, "image/png");
    gtk_file_chooser_add_filter(GTK_FILE_CHOOSER(dialog), filter);

    gtk_widget_show_all(dialog);

    gint response = gtk_dialog_run(GTK_DIALOG(dialog));

    gchar *filename = NULL;
    if (response == GTK_RESPONSE_ACCEPT) {
        filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
    }

    gtk_widget_destroy(dialog);
    return filename;
}

/* message_dialog
 * Affiche un message simple.
 */
void message_dialog(const gchar *title, GtkMessageType type,
                    const gchar *format, ...) {
    va_list ap;

    va_start(ap, format);

    gchar *message;
    g_vasprintf(&message, format, ap);

    GtkWidget *dialog = gtk_message_dialog_new(
        GTK_WINDOW(main_window), GTK_DIALOG_DESTROY_WITH_PARENT, type,
        GTK_BUTTONS_CLOSE, "%s", message);
    gtk_window_set_title(GTK_WINDOW(dialog), title);
    gtk_dialog_run(GTK_DIALOG(dialog));
    gtk_widget_destroy(dialog);
    g_free(message);
}

/*
 * Gestion des images
 */

/* setup_image
 *
 * Crée les bitmaps de travail en fonction de l'image source
 *
 */
void setup_images() {
    GError *error = NULL;

    int i = 0;
    while (bitmaps[i].name != NULL && i < N_BITMAPS) {
        GdkPixbuf *pixbuf = gdk_pixbuf_new_from_file(bitmaps[i].name, &error);
        /* Ajouter le canal alpha s'il n'est pas présent dans l'image */
        if(error != NULL) {
            message_dialog("Erreur", GTK_MESSAGE_ERROR,
                           "Impossible de charger l'image %s: %s",
                           bitmaps[i].name, error->message);
            g_error_free(error);
            error = NULL;
            exit(1);
        }
        GdkPixbuf *pixbuf_with_alpha =
            gdk_pixbuf_add_alpha(pixbuf, FALSE, 0, 0, 0);
        GdkColorspace cs = gdk_pixbuf_get_colorspace(pixbuf_with_alpha);
        int bps = gdk_pixbuf_get_bits_per_sample(pixbuf_with_alpha);
        int w = gdk_pixbuf_get_width(pixbuf_with_alpha);
        int h = gdk_pixbuf_get_height(pixbuf_with_alpha);

        if (bitmaps[i].pixbuf != NULL && i < SPRITE_COUNT) {
            g_object_unref(bitmaps[i].pixbuf);
        }
        bitmaps[i].pixbuf = gdk_pixbuf_new_from_file_at_size(
            bitmaps[i].name, w, h, &error);
        i++;
    }
}

/* refresh_image
 *
 * Rafraîchit l'image courante
 *
 */
void refresh_image() {
    if (bitmaps[visible_image].pixbuf != NULL) {
        gtk_image_set_from_pixbuf(GTK_IMAGE(image),
                                  bitmaps[visible_image].pixbuf);
    }
}

/* clear_images
 *
 * Efface les images de travail
 *
 */
void clear_images() {
    int i = 1;
    while (bitmaps[i].name != NULL) {
        if (bitmaps[i].pixbuf != NULL && i < SPRITE_COUNT) {
            gdk_pixbuf_fill(bitmaps[i].pixbuf, 0xff);
        }
        i++;
    }

    /* Rafraîchir l'image courante */
    refresh_image();
}

/* show_image
 *
 * Affiche une image de travail
 *
 */
void show_image(int i) {
    if (i >= 0) {
        visible_image = i;
    }

    /* Mettre à jour la barre de titre */
    gchar buffer[128];
    g_snprintf(buffer, 128, "%s - %s", application_name,
               bitmaps[visible_image].name);
    gtk_window_set_title(GTK_WINDOW(main_window), buffer);

    /* Afficher l'image */
    refresh_image();
}

/* load_image
 * Charge une image. Retourne le pixbuf associé ou NULL en cas d'erreur
 */
void load_source_image() {
    setup_images();
    show_image(IMG_SRC);
    // clear_images();
    gtk_window_resize(GTK_WINDOW(main_window), 1, 1);
}

/* run_processing_task
 *
 * Réalise le traitement dont le nom est passé en paramètre.
 *
 */
void run_processing_task(const gchar *target, int showtime) {
    struct game_elements *elements_ptr = (struct game_elements *)Donnees_ptr;

    if (bitmaps[IMG_SRC].pixbuf == NULL) {
        message_dialog("Avertissement", GTK_MESSAGE_WARNING,
                       "Pas d'image chargée");
        return;
    }

    /* Récupérer les infos de l'image source */
    // int w = gdk_pixbuf_get_width(bitmaps[IMG_SRC].pixbuf);
    // int h = gdk_pixbuf_get_height(bitmaps[IMG_SRC].pixbuf);

    // those are the width and height of the source image
    uint16_t widths[SPRITE_COUNT + 1];
    uint16_t  heights[SPRITE_COUNT + 1];
    // This is the array of pointers to the images
    uint8_t *images_pointers_to_array[SPRITE_COUNT + 1];

    size_t i;
    for (i = 0; i < SPRITE_COUNT + 1; ++i) {
        widths[i] = gdk_pixbuf_get_width(bitmaps[i].pixbuf);
        heights[i] = gdk_pixbuf_get_height(bitmaps[i].pixbuf);
        // if (bitmaps[i].pixbuf == NULL) {
        //     bitmaps[i].pixbuf = gdk_pixbuf_new(GDK_COLORSPACE_RGB, TRUE, 8,
        //                                        widths[i], heights[i]);
        // }
        images_pointers_to_array[i] = gdk_pixbuf_get_pixels(bitmaps[i].pixbuf);
    }

    /* Effacer les images */
    clear_images();

    /* Récupérer les buffers d'image de chaque bitmap */
    // uint8_t *pixels[N_BITMAPS];
    // for (int i = 0; i < N_BITMAPS; ++i) {
    //     pixels[i] = gdk_pixbuf_get_pixels(bitmaps[i].pixbuf);
    // }

    /* Trouver la fonction de traitement à appeler en fonction de la cible */
    int task_nr = 0;
    do {
        if (strcmp(process_tasks[task_nr].target, target) == 0) break;
    } while (process_tasks[++task_nr].target != NULL);

    /* Réaliser le traitement */
    clock_t start = clock();
    elements_ptr->flag_stop = 0;
    while (elements_ptr->flag_stop == 0) {
        if (process_tasks[task_nr].process_fun != NULL) {
            process_tasks[task_nr].process_fun(
                widths, heights, images_pointers_to_array,
                Donnees_ptr);  // TODO: This is where we will pass
                               // the data to the processing function

            /* Rafraîchir l'image affichée */
            refresh_image();
            /* forcer l'affichage de la nouvelle image dans la fenêtre */
            gtk_main_iteration();
        }
    }
    elements_ptr->flag_stop = 0;
    clock_t end = clock();

    if (showtime) {
        // Afficher le temps écoulé
        double elapsed = (double)(end - start) / CLOCKS_PER_SEC;

        // Rafraîchir l'image affichée
        refresh_image();

        message_dialog("Répétitions", GTK_MESSAGE_INFO,
                       "Temps total (%d répétitions): %f secondes\n\n"
                       "Temps par itération : %f millisecondes",
                       process_repetitions, elapsed,
                       1000 * (elapsed / process_repetitions));
    }
}

/*
 *
 * Fonctions de l'interface graphique principale
 *
 */

/* Définition de l'UI */
static const gchar ui_info[] =
    "<interface>"
    "  <menu id='menubar'>"
    "    <submenu>"
    "      <attribute name='label'>_Fichier</attribute>"
    "      <section>"
    "        <item>"
    "          <attribute name='label'>_Quitter</attribute>"
    "          <attribute name='action'>app.quit</attribute>"
    "          <attribute name='accel'>&lt;Primary&gt;q</attribute>"
    "        </item>"
    "      </section>"
    "    </submenu>"
    "    <submenu>"
    "      <attribute name='label'>_JOUER</attribute>"
    "      <section>"
    "        <item>"
    "          <attribute name='label'>Lancer le jeu en ASM </attribute>"
    "          <attribute name='action'>app.process</attribute>"
    "          <attribute name='target'>asm</attribute>"
    "        </item>"
    "		   <item>"
    "          <attribute name='label'>Lancer le jeu en C </attribute>"
    "          <attribute name='action'>app.process</attribute>"
    "          <attribute name='target'>c</attribute>"
    "        </item>"
    "      </section>"
    "    </submenu>"
    "  </menu>"
    "</interface>";

/* startup
 *
 * Appelé à la création de l'application
 *
 */
static void startup(GApplication *app) {
    Donnees_ptr = malloc(500);
    uint32_t *ptr;

    ptr = (uint32_t *)Donnees_ptr;
    ptr[0] = 0;

    GtkBuilder *builder = gtk_builder_new();
    gtk_builder_add_from_string(builder, ui_info, -1, NULL);

    GMenuModel *menubar =
        (GMenuModel *)gtk_builder_get_object(builder, "menubar");

    gtk_application_set_menubar(GTK_APPLICATION(app), menubar);

    g_object_unref(builder);
}

/* activate
 *
 * Appelée à l'activation de l'application
 *
 */
static void activate(GApplication *app) {
    /* Créer la fenêtre principale */
    main_window = gtk_application_window_new(GTK_APPLICATION(app));
    gtk_window_set_default_size(GTK_WINDOW(main_window), 400, 600);
    gtk_window_set_title(GTK_WINDOW(main_window), application_name);

    /* Créer une boîte pour les widgets */
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
    gtk_container_add(GTK_CONTAINER(main_window), box);

    /* Créer l'image */
    image = gtk_image_new();
    gtk_box_pack_start(GTK_BOX(box), image, TRUE, TRUE, 0);

    gtk_widget_show_all(main_window);

    /* Charger l'image initiale */
    load_source_image();
}

/* shutdown
 *
 * Appelée à la fermeture de l'application
 *
 */
static void shutdown(GApplication *app) {
    free(Donnees_ptr);

    /* Supprimer les images */
    int i = 0;
    while (bitmaps[i].name != NULL) {
        if (bitmaps[i].pixbuf != NULL) {
            g_object_unref(bitmaps[i].pixbuf);
        }
        i++;
    }
}

/* activate_open
 *
 * Appelée sur l'action 'ouvrir'. Ouvre un fichier image.
 *
 */
static void activate_open(GSimpleAction *action, GVariant *parameter,
                          gpointer user_data) {
    gchar *filename = file_chooser();

    if (filename != NULL) {
        load_source_image(filename);
        g_free(filename);
    }
}

/* activate_quit
 *
 * Appelée sur l'action 'quitter'. Termine l'application.
 *
 */
static void activate_quit(GSimpleAction *action, GVariant *parameter,
                          gpointer user_data) {
    g_application_quit(G_APPLICATION(user_data));
}

/* activate_view
 *
 * Appelée sur l'action 'view'. Gère l'affichage des images.
 *
 */
static void activate_view(GSimpleAction *action, GVariant *parameter,
                          gpointer user_data) {
    const gchar *target = g_variant_get_string(parameter, NULL);

    show_image(atoi(target));
}

/* activate_process
 *
 * Appelée sur l'action 'view'. Déclenche le traitement demandé
 *
 */
static void activate_process(GSimpleAction *action, GVariant *parameter,
                             gpointer user_data) {
    const gchar *target = g_variant_get_string(parameter, NULL);

    run_processing_task(target, 1);
}

/* activate_comparaison
 *
 * Appelée sur l'action 'comparaison'. Calcule la ressemblance.
 *
 */

/* Définition des actions de l'interface */
static GActionEntry app_entries[] = {
    {"open", activate_open, NULL, NULL, NULL},
    {"quit", activate_quit, NULL, NULL, NULL},
    {"view", activate_view, "s", NULL, NULL},
    {"process", activate_process, "s", NULL, NULL}};

/* main
 *
 * Fonction principale appelée au démarrage du programme
 *
 */
int main(int argc, char *argv[]) {
    GtkApplication *app = gtk_application_new("fr.utc.mi01.atelier-photo", 0);

    g_action_map_add_action_entries(G_ACTION_MAP(app), app_entries,
                                    G_N_ELEMENTS(app_entries), app);
    g_signal_connect(app, "startup", G_CALLBACK(startup), NULL);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    g_signal_connect(app, "shutdown", G_CALLBACK(shutdown), NULL);

    int status = g_application_run(G_APPLICATION(app), argc, argv);

    g_object_unref(app);
    return status;
}
