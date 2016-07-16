; MP4 Header File

; EXTERN all library functions
	EXTERN	_MP4LibExit
	EXTERN	_libPointInBox
	EXTERN	_libGetPixel
	EXTERN	_libDrawPixel
	EXTERN	_libDrawLine
	EXTERN	_libDrawRect
	EXTERN	_libDrawCircle
	EXTERN	_libDrawText
	EXTERN	_libClearBuffer
	EXTERN	_libCopyBuffer
	EXTERN	_libComposeBuffers
	EXTERN	_libBlurBuffer
	EXTERN	_libFloodFill
	EXTERN	_libInstallKeyboard
	EXTERN	_libRemoveKeyboard
	EXTERN	_libKeyboardISR
	EXTERN	_libInstallMouse
	EXTERN	_libRemoveMouse
	EXTERN	_libMouseCallback

; DEFINE all library function lengths
	_libPointInBox_arglen		EQU	12
	_libGetPixel_arglen		EQU	12
	_libDrawPixel_arglen		EQU	16
	_libDrawLine_arglen		EQU	20
	_libDrawRect_arglen		EQU	24
	_libDrawCircle_arglen		EQU	22
	_libDrawText_arglen		EQU	20
	_libClearBuffer_arglen		EQU	12
	_libCopyBuffer_arglen		EQU	20
	_libComposeBuffers_arglen	EQU	20
	_libBlurBuffer_arglen		EQU	12
	_libFloodFill_arglen		EQU	20
	_libMouseCallback_arglen	EQU	4

; GLOBAL all program functions
    	GLOBAL	_PointInBox
	GLOBAL	_GetPixel
	GLOBAL	_DrawPixel
	GLOBAL	_DrawLine
	GLOBAL	_DrawRect
	GLOBAL	_DrawCircle
	GLOBAL	_DrawText
	GLOBAL	_ClearBuffer
	GLOBAL	_CopyBuffer
	GLOBAL	_ComposeBuffers
	GLOBAL	_FloodFill
	GLOBAL	_InstallKeyboard
	GLOBAL	_RemoveKeyboard
	GLOBAL	_KeyboardISR
	GLOBAL	_InstallMouse
	GLOBAL	_RemoveMouse
	GLOBAL	_MouseCallback
	GLOBAL	_MP4Main
	GLOBAL	_DrawBackground

; GLOBAL all program variables
	GLOBAL	_GraphicsMode
	GLOBAL	_kbINT
	GLOBAL	_kbIRQ
	GLOBAL	_kbPort
	GLOBAL	_MouseSeg
	GLOBAL	_MouseOff
	GLOBAL	_MouseX
	GLOBAL	_MouseY					
	GLOBAL	_ScreenOff
	GLOBAL	_CanvasOff
	GLOBAL	_OverlayOff
	GLOBAL	_FontOff
	GLOBAL	_MenuOff
	GLOBAL	_TitleOff
	GLOBAL	_MPFlags			
	GLOBAL	_MenuItem				
	GLOBAL	_x
	GLOBAL	_y
	GLOBAL	_dx
	GLOBAL	_dy   
	GLOBAL	_lineerror
	GLOBAL	_xhorizinc
	GLOBAL	_xdiaginc
	GLOBAL	_yvertinc
	GLOBAL	_ydiaginc
	GLOBAL	_errordiaginc
	GLOBAL	_errornodiaginc
	GLOBAL	_radius
	GLOBAL	_circleerror
	GLOBAL	_xdist
	GLOBAL	_ydist
	GLOBAL	_PointQueue
	GLOBAL	_QueueHead
	GLOBAL	_QueueTail
	GLOBAL	_key
	GLOBAL	_FontFN
	GLOBAL	_MenuFN
	GLOBAL	_TitleFN
	GLOBAL	_CurrentColor
	GLOBAL	_ColorBlue
	GLOBAL	_ColorWhite
	GLOBAL	_ColorBlack
	GLOBAL	_ColorHalfBlack
	GLOBAL	_buffer
	GLOBAL	_ColorString1
	GLOBAL	_ColorString2
	GLOBAL	_ColorString3
	GLOBAL	_ColorString4
	GLOBAL	_MenuLocations
	GLOBAL	_ProcessMenu
	GLOBAL	_QwertyNames
	GLOBAL	_QwertyNames_end
	GLOBAL	_QwertyShift
	GLOBAL	_QwertyShift_end
	GLOBAL	_TextInputString
	GLOBAL	_ColorInputString
	GLOBAL	_RoundingFactor

