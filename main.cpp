// taken from http://www.andrewewhite.net/wordpress/2010/04/07/simple-cc-jpeg-writer-part-2-write-to-buffer-in-memory/
#include "SDL2/SDL.h"
#include "SDL2/SDL_image.h"
#include "jpeglib.h"
 
#include <iostream>
#include <exception>
#include <stdexcept>
 
using namespace std;
 
/* setup the buffer but we did that in the main function */
void init_buffer(jpeg_compress_struct* cinfo) {}
 
/* what to do when the buffer is full; this should almost never
 * happen since we allocated our buffer to be big to start with
 */
boolean empty_buffer(jpeg_compress_struct* cinfo) {
	return TRUE;
}
 
/* finalize the buffer and do any cleanup stuff */
void term_buffer(jpeg_compress_struct* cinfo) {}
 
int main() {
	/* load the image and note I assume this is a RGB 24 bit image
	 * you should do more checking/conversion if possible
	 */
	SDL_Surface *image    = IMG_Load("bazel.bmp");
	FILE        *outfile  = fopen("test.jpeg", "wb");
 
	if (!image)   throw runtime_error("Problem opening input file");
	if (!outfile) throw runtime_error("Problem opening output file");
 
	struct jpeg_compress_struct cinfo;
	struct jpeg_error_mgr       jerr;
	struct jpeg_destination_mgr dmgr;
 
	/* create our in-memory output buffer to hold the jpeg */
	JOCTET * out_buffer   = new JOCTET[image->w * image->h *3];
 
	/* here is the magic */
	dmgr.init_destination    = init_buffer;
	dmgr.empty_output_buffer = empty_buffer;
	dmgr.term_destination    = term_buffer;
	dmgr.next_output_byte    = out_buffer;
	dmgr.free_in_buffer      = image->w * image->h *3;
 
	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo);
 
	/* make sure we tell it about our manager */
	cinfo.dest = &dmgr;
 
	cinfo.image_width      = image->w;
	cinfo.image_height     = image->h;
	cinfo.input_components = 3;
	cinfo.in_color_space   = JCS_RGB;
 
	jpeg_set_defaults(&cinfo);
	jpeg_set_quality (&cinfo, 75, true);
	jpeg_start_compress(&cinfo, true);
 
	JSAMPROW row_pointer;
	Uint8 *buffer    = (Uint8*) image->pixels;
 
	/* silly bit of code to get the RGB in the correct order */
	for (int x = 0; x < image->w; x++) {
		for (int y = 0; y < image->h; y++) {
			Uint8 *p    = (Uint8 *) image->pixels + y * image->pitch + x * image->format->BytesPerPixel;
			swap (p[0], p[2]);
		}
	}
 
	/* main code to write jpeg data */
	while (cinfo.next_scanline < cinfo.image_height) { 		
		row_pointer = (JSAMPROW) &buffer[cinfo.next_scanline * image->pitch];
		jpeg_write_scanlines(&cinfo, &row_pointer, 1);
	}
	jpeg_finish_compress(&cinfo);
 
	/* write the buffer to disk so you can see the image */
	fwrite(out_buffer, cinfo.dest->next_output_byte - out_buffer,1 ,outfile);
	return 0;
}
