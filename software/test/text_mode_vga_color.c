/*
 * text_mode_vga_color.c
 * Minimal driver for text mode VGA support
 * This is for Week 2, with color support
 *
 *  Created on: Oct 25, 2021
 *      Author: zuofu
 */

#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alt_types.h>
#include "text_mode_vga_color.h"

void textVGAColorClr()
{
	for (int i = 0; i<(ROWS*COLUMNS) * 2; i++)
	{
		vga_ctrl->VRAM[i] = 0x00;
	}
}

void textVGADrawColorText(char* str, int x, int y, alt_u8 background, alt_u8 foreground)
{
	int i = 0;
	while (str[i]!=0)
	{
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2] = foreground << 4 | background;
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2 + 1] = str[i];
		i++;
	}
}

void setColorPalette (alt_u8 color, alt_u8 red1, alt_u8 green1, alt_u8 blue1, alt_u8 red2, alt_u8 green2, alt_u8 blue2)
{
	//fill in this function to set the color palette starting at offset 0x0000 2000 (from base)
	//vga_ctrl->VRAM[0x2000 + 4 * color] = colors[color*2].blue << 1 | colors[color*2].green << 5;
	//vga_ctrl->VRAM[0x2000 + 4 * color + 1] = (colors[color*2].green >> 3) | colors[color*2].red << 1 | colors[color*2+1].blue << 5 ;
	//vga_ctrl->VRAM[0x2000 + 4 * color + 2] = (colors[color*2+1].blue >> 3) | colors[color*2+1].green << 1 | colors[color*2+1].red << 5;
	//vga_ctrl->VRAM[0x2000 + 4 * color + 3] = (colors[color*2+1].red >> 3);

	vga_ctrl->palette[color] = blue1 << 1 | green1 << 5 | red1 << 9 | blue2 << 13 | green2 << 17 | red2 << 21;


}


void textVGAColorScreenSaver()
{
	//This is the function you call for your week 2 demo
	char color_string[80];
    int fg, bg, x, y;
	textVGAColorClr();
	//initialize palette
	for (int i = 0; i < 8; i++)
	{
		setColorPalette (i, colors[i*2].red, colors[i*2].green, colors[i*2].blue, colors[i*2+1].red, colors[i*2+1].green, colors[i*2+1].blue);
	}
	while (1)
	{
		fg = rand() % 16;
		bg = rand() % 16;
		while (fg == bg)
		{
			fg = rand() % 16;
			bg = rand() % 16;
		}
		sprintf(color_string, "Drawing %s text with %s background", colors[fg].name, colors[bg].name);
		x = rand() % (80-strlen(color_string));
		y = rand() % 30;
		textVGADrawColorText (color_string, x, y, bg, fg);
		usleep (100000);
	}
}
