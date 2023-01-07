#include <glib/gprintf.h>
#include <gtk/gtk.h>
#include <sys/time.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* App settings */
#define SPRITE_COUNT 16
#define BACKGROUD_INDEX 0
#define ICON_INDEX 7
#define APP_NAME "Space Invaders"
#define APP_WIDTH 800
#define APP_HEIGHT 600
#define APP_MEMORY 32000
#define FPS_MAX 60
#define IMAGE_PATH "/sprites/data/images/"

/* Pointer to the memory area */
void *memory;

/* Pointers to image data */
uint16_t widths[SPRITE_COUNT];
uint16_t heights[SPRITE_COUNT];
uint8_t *pixels[SPRITE_COUNT];

/* Main window of application */
GtkWidget *main_window;

/* Actual image widget */
GtkWidget *image;

typedef struct _image
{
    gchar *path;
    GdkPixbuf *pixbuf;
} image_t;
image_t images[] = {{IMAGE_PATH "base.bmp", NULL},
                    {IMAGE_PATH "debug.bmp", NULL},
                    {IMAGE_PATH "void.bmp", NULL},
                    {IMAGE_PATH "cat.png", NULL},
                    {IMAGE_PATH "cat-explode.png", NULL},
                    {IMAGE_PATH "food.png", NULL},
                    {IMAGE_PATH "spaceship1.png", NULL},
                    {IMAGE_PATH "spaceship2.png", NULL},
                    {IMAGE_PATH "kennel4.png", NULL},
                    {IMAGE_PATH "kennel3.png", NULL},
                    {IMAGE_PATH "kennel2.png", NULL},
                    {IMAGE_PATH "kennel1.png", NULL},
                    {IMAGE_PATH "mouse.png", NULL},
                    {IMAGE_PATH "heart.png", NULL},
                    {IMAGE_PATH "empty_heart.png", NULL},
                    {IMAGE_PATH "gameover.png", NULL}};

/* 0 If all is OK else 1 when application is destroying the main window */
gboolean is_shutting_down = 0;

/* Assembly function */
void update(uint16_t *img_width, uint16_t *img_height,
            uint8_t **img_src, void *Donnees_ptr);

/* Print a simple message dialog */
void message_dialog(const gchar *title, GtkMessageType type,
                    const gchar *format, ...)
{
    va_list ap;

    va_start(ap, format);

    gchar *message;
    g_vasprintf(&message, format, ap);

    GtkWidget *dialog = gtk_message_dialog_new(
        GTK_WINDOW(main_window), GTK_DIALOG_DESTROY_WITH_PARENT,
        type, GTK_BUTTONS_CLOSE, "%s", message);
    gtk_dialog_run(GTK_DIALOG(dialog));
    gtk_widget_destroy(dialog);
    g_free(message);
}

/* Load all images from resources */
void setup_images()
{
    GError *error = NULL;
    for (size_t i = 0; i < SPRITE_COUNT; i++)
    {
        GdkPixbuf *pixbuf = gdk_pixbuf_new_from_resource(images[i].path, &error);
        if (error != NULL)
        {
            message_dialog("Error", GTK_MESSAGE_ERROR,
                           "Can't load image %s: %s",
                           images[i].path, error->message);
            g_error_free(error);
            /* TODO : Dirty wait to shutdown here*/
            exit(1);
        }
        images[i].pixbuf = gdk_pixbuf_add_alpha(pixbuf, FALSE, 0, 0, 0);
        widths[i] = gdk_pixbuf_get_width(images[i].pixbuf);
        heights[i] = gdk_pixbuf_get_height(images[i].pixbuf);
        pixels[i] = gdk_pixbuf_get_pixels(images[i].pixbuf);
    }
}

/* Wrapper for update loop in assembly */
void update_loop()
{
    if (!is_shutting_down)
    {
        g_timeout_add(1000 / FPS_MAX, (GSourceFunc)update_loop, NULL);
        update(widths, heights, pixels, memory);
        gtk_image_set_from_pixbuf(GTK_IMAGE(image), images[BACKGROUD_INDEX].pixbuf);
        while (gtk_events_pending())
            gtk_main_iteration_do(FALSE);
    }
}

/* Called when window is destroy, free all objects */
static void shutdown(GApplication *app)
{
    is_shutting_down = 1;
    free(memory);
    for (size_t i = 0; i < SPRITE_COUNT; i++)
        if (images[i].pixbuf != NULL)
            g_object_unref(images[i].pixbuf);
}

/* Called when application is created */
static void activate(GApplication *app)
{
    memory = calloc(1, APP_MEMORY);

    /* Create main window */
    main_window = gtk_application_window_new(GTK_APPLICATION(app));
    gtk_window_set_default_size(GTK_WINDOW(main_window), APP_WIDTH, APP_HEIGHT);
    gtk_window_set_title(GTK_WINDOW(main_window), APP_NAME);

    /* Add callback for window deletion */
    g_signal_connect(GTK_WINDOW(main_window), "destroy", G_CALLBACK(shutdown), NULL);

    /* Add box for image */
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
    gtk_container_add(GTK_CONTAINER(main_window), box);

    /* Create and add image  */
    image = gtk_image_new();
    gtk_box_pack_start(GTK_BOX(box), image, TRUE, TRUE, 0);

    /* Update display of windows */
    gtk_widget_show_all(main_window);

    /* Load all images */
    setup_images();

    /* Resive window to image size */
    gtk_window_resize(GTK_WINDOW(main_window), 1, 1);

    /* Set  the icon */
    gtk_window_set_icon(GTK_WINDOW(main_window), images[ICON_INDEX].pixbuf);

    /* Run mainloop */
    update_loop();
}

/* Entry point */
int main(int argc, char *argv[])
{
    GtkApplication *app = gtk_application_new(
        "fr.dashstrom.space-invaders-asm", 0);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
