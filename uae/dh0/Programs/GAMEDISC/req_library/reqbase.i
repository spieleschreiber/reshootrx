
; reqlibrary.i © 1988/1989 reserved by Colin Fox and Bruce Dawson */

	IFND	REQ_LIBRARY_I

REQ_LIBRARY_I	SET	1

		INCLUDE	"intuition/intuition.i"

		INCLUDE	"libraries/dos.i"
		INCLUDE	"libraries/dosextens.i"

		INCLUDE	"exec/memory.i"
		INCLUDE	"exec/initializers.i"
		INCLUDE	"exec/alerts.i"

ReqVersion	EQU	1


PairsSize	EQU	20

 STRUCTURE	GadgetBlock.,0		;a boolean button style text gadget
	STRUCT	gb_Gadget,gg_SIZEOF
	STRUCT	gb_Border,bd_SIZEOF
	STRUCT	gb_Pairs,PairsSize
	STRUCT	gb_Text,it_SIZEOF
	LABEL	gb_SIZEOF

 STRUCTURE	StringBlock.,0		;a string gadget
	STRUCT	sb_Gadget,gg_SIZEOF
	STRUCT	sb_Info,si_SIZEOF
	STRUCT	sb_Border,bd_SIZEOF
	STRUCT	sb_Pairs,PairsSize
	LABEL	sb_SIZEOF

 STRUCTURE	PropBlock.,0		;a prop gadget
	STRUCT	pb_Gadget,gg_SIZEOF
	STRUCT	pb_Info,pi_SIZEOF
	STRUCT	pb_Image,ig_SIZEOF
	LABEL	pb_SIZEOF

 STRUCTURE	SliderBlock.,0		;a slider (two arrows & a prop)
	STRUCT	slb_ArrowUpLt,gg_SIZEOF
	STRUCT	slb_ImageUpLt,ig_SIZEOF
	STRUCT	slb_ArrowDnRt,gg_SIZEOF
	STRUCT	slb_ImageDnRt,ig_SIZEOF
	STRUCT	slb_Prop,pb_SIZEOF	;this is at the end for REFRESH GLIST purposes
	LABEL	slb_SIZEOF

 STRUCTURE	TwoImageBlock,0
	STRUCT	tib_Gadget,gg_SIZEOF
	STRUCT	tib_Image1,ig_SIZEOF
	STRUCT	tib_Image2,ig_SIZEOF
	LABEL	tib_SIZEOF

ATTITUDEB	EQU	16	;Bit# of the attitude bit.

HorizSlider	EQU	0<<ATTITUDEB	;which way the slider stands
VertSlider	EQU	1<<ATTITUDEB	;This is so that it bypasses all gadget flags.



;         This structure is use with the TextRequester function.

 STRUCTURE TRStructure,0
	APTR	TR_Text			;This is the message text, including printf() style formatting if desired.
	APTR	TR_Controls		;This is the address of the parameter list, if printf() style formatting is used.
	APTR	TR_Window		;This is an optional (zero if not used) pointer to a window on the screen you 
					;would like the requester to show up on.
	APTR	TR_MiddleText		;If non-zero, this is the text for the gadget in the lower middle (returns 2).
	APTR	TR_PositiveText		;If non-zero, this is the text for the gadget in the lower left hand corner (returns 1).
	APTR	TR_NegativeText		;If non-zero, this is the text for the gadget in the lower right (returns 0).
	APTR	TR_Title		;This is the title for the window.
	WORD	TR_KeyMask		;This is the qualifier mask for the keyboard shortcuts.
					;Use $FFFF to allow any qualifiers (or none).
					;Zero means that no keyboard shortcuts are allowed.
	WORD	TR_textcolor		;Color of the text.  Uses Color 1 if no Color specified.
	WORD	TR_detailcolor		;Detail and block color, as in a NewWindow structure.  If
	WORD	TR_blockcolor		;both are left zero, block pen will be set to 1.
	WORD	TR_versionnumber	;Make SURE this is set to zero.
	LONG	TR_rfu1			;Make SURE you leave these two zeroed also.
	LONG	TR_rfu2			;Make SURE you leave these two zeroed also.
	LABEL	TR_SIZEOF

;/* NOTE:
;
;    The  control  values  mentioned above are used if you choose to insert
;printf  style directives in your strings and should contain the address of
;a list of control parameters, usually on the stack.
;    */



;         This structure is for use with the GetLong function.

GLNODEFAULTB	EQU	0	;Set this bit in the flags if you don't want a default
				;value to show up in the get long string gadget.  For
				;some things this is much better than having a zero
				;show up.

GLNODEFAULTM	EQU	1<<GLNODEFAULTB

 STRUCTURE	GetLongStruct,0
	APTR	gl_titlebar
	LONG	gl_defaultval
	LONG	gl_minlimit
	LONG	gl_maxlimit
	LONG	gl_result
	APTR	gl_window
	WORD	gl_versionnumber;	;Make SURE this is set to zero.
	LONG	gl_flags;		;Some, uh flags.  See above for bit definitions.
	LONG	gl_rfu2;		;Make SURE you leave these two zeroed also.
	LABEL	gl_SIZEOF


 STRUCTURE	GetStringStruct,0
	APTR	gs_titlebar
	APTR	gs_stringbuffer
	APTR	gs_window
	WORD	gs_stringsize
	WORD	gs_visiblesize
	WORD	gs_versionnumber
	LONG	gs_flags
	LONG	gs_rfu1
	LONG	gs_rfu2
	LONG	gs_rfu3
	LABEL	gs_SIZEOF



;         Remember,   if  you  don't  want  to  go  through  the  hassle  of
; initializing a ExtendedColorRequester structure, you can always just call
; ColorRequester  (as opposed to ExtendedColorRequester).  ColorRequester
; just  takes  a  single  parameter, in D0, the color that should start out
; being highlit.  It returns a single value, the color that was selected at
; the end.

;         This structure is for use with the ExtendedColorRequester (_not_,
; the ColorRequester) function.

 STRUCTURE	ExtendedColorRequesterStruct,0
	LONG	ecr_defcolor		;The color that is initially highlit.
	APTR	ecr_window		;The window the 'requester' opens up in (zero normally).
	LONG	ecr_rfu1			;Who knows what these will be used for,
	LONG	ecr_rfu2			;but I'm sure we'll think of something.
	LONG	ecr_rfu3			;Until then, just keep these zeroed.
	LONG	ecr_rfu4			;Okay?
	LONG	ecr_rfu5
	LABEL	ecr_SIZEOF



	IFND	DSIZE
DSIZE		EQU	130
FCHARS		EQU	30
	ENDC
WILDLENGTH	EQU	30

FRQSHOWINFOB	EQU	0	;Set this in Flags if you want .info files to show.  They default to hidden.
FRQEXTSELECTB	EQU	1	;Set this in Flags if you want extended select.  Default is not.
FRQCACHINGB	EQU	2	;Set this in Flags if you want directory caching.  Default is not.
FRQGETFONTSB	EQU	3	;Set this in Flags if you want a font requester rather than a file requester.
FRQINFOGADGETB	EQU	4	;Set this in Flags if you want a hide-info files gadget.
FRQHIDEWILDSB	EQU	5	;Set this in Flags if you DON'T want 'show' and 'hide' string gadgets.
FRQABSOLUTEXYB	EQU	6	;Use absolute x,y positions rather than centering on mouse.
FRQCACHEPURGEB	EQU	7	;Purge the cache whenever the directory date stamp changes if this is set.
FRQNOHALFCACHEB	EQU	8	;Don't cache a directory unless it is completely read in when this is set.
FRQNOSORTB	EQU	9	;Set this in Flags if you DON'T want sorted directories.
FRQNODRAGB	EQU	10	;Set this in Flags if you DON'T want a drag bar and depth gadgets.
FRQSAVINGB	EQU	11	;Set this bit if you are selecting a file to save to.
FRQLOADINGB	EQU	12	;Set this bit if you are selecting a file(s) to load from.
				;These two bits (save and load) aren't currently used for
				;anything, but they may be in the future, so you should
				;remember to set them.  Also, these bits make it easier if
				;somebody wants to customize the file requester for their
				;machine.  They can make it behave differently for loading
				;vs saving.
FRQDIRONLYB	EQU	13	;Allow the user to select a directory, rather than a file.

FRQSHOWINFOM	EQU	1<<FRQSHOWINFOB
FRQEXTSELECTM	EQU	1<<FRQEXTSELECTB
FRQCACHINGM	EQU	1<<FRQCACHINGB
FRQGETFONTSM	EQU	1<<FRQGETFONTSB
FRQINFOGADGETM	EQU	1<<FRQINFOGADGETB
FRQHIDEWILDSM	EQU	1<<FRQHIDEWILDSB
FRQABSOLUTEXYM	EQU	1<<FRQABSOLUTEXYB
FRQCACHEPURGEM	EQU	1<<FRQCACHEPURGEB
FRQNOHALFCACHEM	EQU	1<<FRQNOHALFCACHEB
FRQNOSORTM	EQU	1<<FRQNOSORTB
FRQNODRAGM	EQU	1<<FRQNODRAGB
FRQSAVINGM	EQU	1<<FRQSAVINGB
FRQLOADINGM	EQU	1<<FRQLOADINGB
FRQDIRONLYM	EQU	1<<FRQDIRONLYB


 STRUCTURE	ESStructure,0		;ExtendedSelectStructure
		LONG	es_NextFile	;This must be the first element!
		WORD	es_NameLength	;File name length, not including the terminating zero.
		WORD	es_Pad
		APTR	es_Node		;Node that the user has extended selected.
		LABEL	es_SIZEOF

;         When  using  extended  select,  the  directory pointer is required
; since  only  the  file  names  are stored in the frq_ExtendedSelect linked
; list.   When  not  using  extended select, you can either have frq_Dir and
; frq_File  point  be initialized, or you can have frq_PathName initialized,
; or  both.   frq_PathName will contain the concatenation of the file and
; directory chosen.

 STRUCTURE	.FileRequester,0
	UWORD	frq_VersionNumber		;MUST BE ZERO!!!!!!!!!!!!!!!!!!

	;You will probably want to initialize these three variables.
	APTR	frq_Title			; Hailing text
	APTR	frq_Dir				; Directory array (must be DSIZE+1 characters long)
	APTR	frq_File			; Filename array (must be FCHARS+1 characters long)
	;If you initialize this variable then the file requester will place the complete path name in here on exit.
	APTR	frq_PathName			; Complete path name array - (must be DSIZE+FCHARS+2 long)
	;If you want the file requester to pop up on your custom screen, put one of your window pointers here.
	;Or better yet, you can leave this field zeroed and put a pointer to one of your windows in the
	;pr_WindowPtr field in your process structure.
	APTR	frq_Window			; Window requesting or NULL
	;Initialize these to the number of lines and columns you want to appear in the inner window that
	;displays the file names.  If you leave these set to zero then default values will be used.
	UWORD	frq_MaxExtendedSelect		; Zero implies a maximum of 65535, as long as FRQEXTSELECT is set.
	UWORD	frq_numlines			; Number of lines in file window.
	UWORD	frq_numcolumns			; Number of columns in file window.
	UWORD	frq_devcolumns			; Number of columns in device window.
	ULONG	frq_Flags			; Various - umm - flags.  See above for more info.
	UWORD	frq_dirnamescolor	;These five colors will all default
	UWORD	frq_filenamescolor	;to color one if you don't specify
	UWORD	frq_devicenamescolor	;a color (ie; if you specify color zero).
	UWORD	frq_fontnamescolor	;If you want color zero to be used, specify
	UWORD	frq_fontsizescolor	;color 32, or some other too large number
					;which mods down to zero.

	UWORD	frq_detailcolor		;If both of these colors are specified as
	UWORD	frq_blockcolor		;zero then the block pen will be set to one.

	UWORD	frq_gadgettextcolor	;The color for the text of the five boolean gadgets.  Defaults to 1.
	UWORD	frq_textmessagecolor	;The color for the message at the screen top.  Defaults to 1.
	UWORD	frq_stringnamecolor	;The color for the words Drawer, File, Hide and Show.  Defaults to 3.
	UWORD	frq_stringgadgetcolor	;The color for the borders of the string gadgets.  Defaults to 3.
					;Unfortunately it is not possible to specify
					;the color of the actual text in an Intuition
					;string gadget.
	UWORD	frq_boxbordercolor	;The color for the boxes around the file and directory areas.  Defaults to 3.
	UWORD	frq_gadgetboxcolor	;The color for the boxes around the five boolean gadgets.  Defaults to 3.

	STRUCT	frq_RFU_Stuff,36		;This area, which is reserved for
						;future use, should all be zero.

	STRUCT	frq_DirDateStamp,ds_SIZEOF	; A copy of the cached directories date stamp.
						; There should never be any need to change this.

	UWORD	frq_WindowLeftEdge;		;These two fields are only used when the
	UWORD	frq_WindowTopEdge;		;FRQABSOLUTEXY flag is set.  They specify
						;the location of the upper left hand
						;corner of the window.

	UWORD	frq_FontYSize			;These fields are used to return the selected
	UWORD	frq_FontStyle			;font size and style, only applicable when the
						;font bit is set.

	;If you set the extended select bit and the user extended selects, the list of filenames will start from here.
	APTR	frq_ExtendedSelect		; Linked list of ESStructures if more than one filename is chosen.
	;All of the following variables you shouldn't need to touch.  They contain fields that the file
	;requester sets and likes to preserve over calls, just to make life easier for the user.
	STRUCT	frq_Hide,WILDLENGTH+2		; Wildcards for files to hide.
	STRUCT	frq_Show,WILDLENGTH+2		; Wildcards for files to show.
	WORD	frq_FileBufferPos		; Cursor's  position  and first
	WORD	frq_FileDispPos			; displayed character number in
	WORD	frq_DirBufferPos		; the three string gadgets.  No
	WORD	frq_DirDispPos			; need  to initialized these if
	WORD	frq_HideBufferPos		; you don't want to.
	WORD	frq_HideDispPos
	WORD	frq_ShowBufferPos
	WORD	frq_ShowDispPos

;         The  following  fields are PRIVATE!  Don't go messing with them or
; wierd  things may/will happen.  If this isn't enough of a warning, go read
; the one in intuition.h, that should scare you off.

	APTR	frq_Memory			; Memory allocated for dir entries.
	APTR	frq_Memory2			; Used for currently hidden files.
	APTR	frq_Lock			; Contains lock on directories being read across calls.
	STRUCT	frq_PrivateDirBuffer,DSIZE+2	; Used for keeping a record of which
						; directory we have file names for.
	APTR	frq_FileInfoBlock
	WORD	frq_NumEntries
	WORD	frq_NumHiddenEntries
	WORD	frq_filestartnumber
	WORD	frq_devicestartnumber
	LABEL	frq_SIZEOF







;         This is used with the RealTimeScroll function.

 STRUCTURE	ScrollStruct,0
	ULONG	ss_TopEntryNumber	;This is the ordinal number of the first
					;displayed entry.
	ULONG	ss_NumEntries		;This is the total number of entries in
					;the list.
	UWORD	ss_LineSpacing		;This is how many pixels high each entry is.
	ULONG	ss_NumLines		;This is how many entries can be displayed simultaneously.
	APTR	ss_PropGadget		;This is a pointer to the prop gadget being monitored.

	APTR	ss_RedrawAll		;This routine is used to redraw all of the
					;entries when the user moves far enough
					;that scrolling will take too long.

	APTR	ss_ReadMore		;An optional routine that is called when
					;the scroll routine is waiting for movement.
					;This allows reading of new data while real
					;time scrolling.
	APTR	ss_ScrollAndDraw	;This routine is called when the data needs
					;to be scrolled and updated.  This routine is
					;passed four long parameters (on the stack and
					;in D0-D3) which are, respectively:
					;D0 - entry number of first line to be drawn.
					;D1 - pixel offset to draw first line at.
					;D2 - amount to scroll before doing any drawing.
					;D3 - number of lines of data to draw.
	WORD	versionnumber		;Make SURE this is set to zero.
	LONG	rfu1			;Make SURE you leave these two zeroed also.
	LONG	rfu2			;Make SURE you leave these two zeroed also.
	LABEL	ss_SIZEOF





 STRUCTURE	Arrows,0
	STRUCT	ArrowUp,20
	STRUCT	ArrowDown,20
	STRUCT	ArrowLeft,18
	STRUCT	ArrowRight,18
	STRUCT	Letter_R,20
	STRUCT	Letter_G,20
	STRUCT	Letter_B,20
	STRUCT	Letter_H,20
	STRUCT	Letter_S,20
	STRUCT	Letter_V,20
	LABEL	chipstuff_SIZEOF

; These are the positions relative to the rl_Images pointer.
;ie
;	MOVE.L	rl_Images(A6),A0
;	ADD.L	#ArrowLeft,A0		;A0 now points at the left arrow.


 STRUCTURE	ReqLib,LIB_SIZE
	APTR	rl_SysLib
	APTR	rl_DosLib		;These must be kept in the same order,
	APTR	rl_IntuiLib		;the library expunge code depends on it.
	APTR	rl_GfxLib		;
	APTR	rl_SegList
	APTR	rl_Images		;pointer to the arrow images.
	BYTE	rl_Flags
	BYTE	rl_Pad
	APTR	rl_ConsoleDev		;for RawKeyToAscii
	APTR	rl_ConsoleHandle	;so we can close the device later
	LABEL	MyLib_Sizeof






	LIBINIT
	LIBDEF	_LVOCenter		;1e

	LIBDEF	_LVOSetSize		;24
	LIBDEF	_LVOSetLocation		;2a
	LIBDEF	_LVOReadLocation	;30

	LIBDEF	_LVOFormat		;36

	LIBDEF	_LVOFakeFunction1	;3c   Old function.  Don't use.
	LIBDEF	_LVOFakeFunction2	;42   Old function.  Don't use.

	LIBDEF	_LVOFakeFunction3	;48   Old function.  Don't use.
	LIBDEF	_LVOFakeFunction4	;4e   Old function.  Don't use.

	LIBDEF	_LVOFileRequester	;54

	LIBDEF	_LVOColorRequester	;5a

	LIBDEF	_LVODrawBox		;60

	LIBDEF	_LVOMakeButton		;66
	LIBDEF	_LVOMakeScrollBar	;6c

	LIBDEF	_LVOPurgeFiles		;72

	LIBDEF	_LVOGetFontHeightAndWidth ;78

	LIBDEF	_LVOMakeGadget		;7e
	LIBDEF	_LVOMakeString		;84
	LIBDEF	_LVOMakeProp		;8a

	LIBDEF	_LVOLinkGadget		;90
	LIBDEF	_LVOLinkStringGadget	;96
	LIBDEF	_LVOLinkPropGadget	;9c

	LIBDEF	_LVOGetString		;a2

	LIBDEF	_LVORealTimeScroll	;a8

	LIBDEF	_LVOTextRequest		;ae

	LIBDEF	_LVOGetLong		;b4

	LIBDEF	_LVORawKeyToAscii	;ba

	LIBDEF	_LVOExtendedColorRequester ;c0

	LIBDEF	_LVONewGetString	;c6



REQNAME	MACRO
	DC.B	'req.library',0
	ENDM

; This macro will open the RequesterLibrary for you. At the end, A6 will
;contain the library and D0/A0 will be correct. (What dos passed you)

OpenReq	MACRO
	BRA.S	opnrq

dname	DC.B	'dos.library',0
rlibmsg	DC.B	'You need V1+ of '
ReqName	REQNAME
	DC.B	10,13,0
;;;rliblng	EQU	*-rlibmsg
rliblng	EQU	30
	DS.W	0
	EVEN

opnrq:
	MOVEM.L	d0/a0,-(sp)
	MOVE.L	4,A6
	LEA.L	ReqName,a1
	MOVEQ.L	#ReqVersion,d0
	SYS	OpenLibrary
	TST.L	d0
	BNE.S	itsokay
	LEA	dname,A1
	SYS	OpenLibrary
	TST.L	D0
	BEQ.S	1$
	MOVE.L	D0,A6
	SYS	Output
	MOVE.L	d0,d1
	BEQ.S	1$			;No output. Phooey.
	MOVE.L	#rlibmsg,d2		;Tell user he needs to find library.
	MOVE.L	#rliblng,D3
	SYS	Write
1$:	ADDQ	#8,sp
	RTS

itsokay:
	MOVE.L	D0,A6
	MOVEM.L	(SP)+,D0/A0
	ENDM



	ENDC
