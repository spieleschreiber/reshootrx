#include <stdio.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>

#define DEPTH 3

/*

Insert any other image struct below (of any size, but change the DEPTH
define above to get correct depth on your screen). Also remember to insert
the keyword 'chip' between 'ULONG' and 'myData'.

You may also want to change the screens palette according to that of the
image. Do this by inserting a new LoadRGB4 palette below the image struct
data.

This source compiles fine with SAS/C and any other C compiler that has
library autoinitialization code.

*/

/* Start image struct data */

ULONG chip myData[] =
{
	0x000903e9,0x0e7918f9,0x1cf93ef9,0x3bf93de9,0x3f091f08,0x8f9887f8,
	0x87f877f8,0x0ff00700,
	0x00060006,0x03c60f86,0x0f061b06,0x15171297,0x18f709f7,0x07f700ef,
	0x001f01ff,0x03ff03ff,
	0xfff0fc10,0xf3c0ef80,0xef40db40,0xd510d690,0xd8f0e9f0,0x77f078e0,
	0x78000800,0x00000000,
};


struct Image myimage =
{
	0x0,0x0,
	0x0010, 0x0010, 0x0003,
	(UWORD *)myData,
	0x07,0x0,
	NULL
};

/* End image struct data */

/* Start palette data */

UWORD palette[] =
{
	0x0000,0x0225,0x006d,0x0049,0x01a0,0x0fff,0x0ecb,0x0b99,
};

/* End palette data */

void main(void)
{
	struct Screen *myscreen;
	struct Window *mywindow;
	BOOL quit = FALSE;
	struct IntuiMessage *msg;
	int x = 100, y = 100;

	if(myscreen = OpenScreenTags(NULL, SA_Width, 320, SA_Height, 200, SA_Depth, DEPTH, SA_Title, "Hit spacebar to quit", TAG_END))
	{
		if(mywindow = OpenWindowTags(NULL, WA_Top, myscreen->BarHeight + 1, WA_Width, 320, WA_Height, 200 - myscreen->BarHeight - 1, WA_IDCMP, IDCMP_VANILLAKEY, WA_CustomScreen, myscreen, WA_Flags, WFLG_BACKDROP|WFLG_NOCAREREFRESH|WFLG_BORDERLESS|WFLG_ACTIVATE|WFLG_RMBTRAP, TAG_END))
		{
			LoadRGB4(&myscreen->ViewPort, palette, 8);
			DrawImage(mywindow->RPort, &myimage, x, y);

			while(!quit)
			{
				WaitTOF();
				EraseImage(mywindow->RPort, &myimage, x, y);
				x++; if(x > 320) x = 0;
				y++; if(y > 200) y = 0;
				DrawImage(mywindow->RPort, &myimage, x, y);

				msg = (struct IntuiMessage *)GetMsg(mywindow->UserPort);
				if(msg)
				{
					if((msg->Class == IDCMP_VANILLAKEY) && (msg->Code == ' ')) quit = TRUE;
				}
			}
			CloseWindow(mywindow);
		}
		else puts("Couldn't open window.");

        while(!CloseScreen(myscreen)) puts("Can't close screen!");;
	}
	else puts("Couldn't open screen.");

	return;
}
