FindFail()
{
    fail_image_path := "clipped\fail_status.bmp"

    x1 = 0
    y1 = 0
    x2 = 2000
    y2 = 2000

	CoordMode Pixel
	ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %fail_image_path%
    if ErrorLevel = 0
    {
        VolPos := (FoundY + 1)
        ToolTip, Yes
        return 1
    }
    ToolTip, No
    return 0
}


ActivateWindow()
{
	WinWait, Diamond Programmer - Untitled *, 
	IfWinNotActive, Diamond Programmer - Untitled *, , WinActivate, Diamond Programmer - Untitled *, 
	WinWaitActive, Diamond Programmer - Untitled *, 
}

ToolTip, Welcome to SigLabs FPGA tester

ActivateWindow()
FindFail()
; ToolTip, result

Sleep, 1000