FindFail()
{
    fail_image_path := "clipped\fail_status.bmp"

    x1 = 0
    y1 = 0
    x2 = 3000
    y2 = 3000

	CoordMode Pixel
	ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %fail_image_path%
    if ErrorLevel = 0
    {
        ;ToolTip, Yes
        return 1
    }
    ;ToolTip, No
    return 0
}


FindSuccess()
{
	image_path := "clipped\pass_id_result.bmp"

    x1 = 0
    y1 = 0
    x2 = 3000
    y2 = 3000

	CoordMode Pixel
	ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %image_path%
    if ErrorLevel = 0
    {
        ToolTip, Yes1
        return 1
    }


    image_path := "clipped\pass_id_result2.bmp"

    ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %image_path%
    if ErrorLevel = 0
    {
        ToolTip, Yes2
        return 1
    }


    ;ToolTip, No
    return 0
}


ActivateWindow()
{
	WinWait, Diamond Programmer - Untitled *,, 0.01
	IfWinNotActive, Diamond Programmer - Untitled *, , WinActivate, Diamond Programmer - Untitled *, 
	WinWaitActive, Diamond Programmer - Untitled *,, 0.01
	if ErrorLevel = 0
	{
		return 1
	}
	return 0
}

FindWindow()
{
	WinWait, Diamond Programmer - Untitled *,, 0.01
	if ErrorLevel = 0
	{
		return 1
	}
	return 0	
}

ResizeWindow()
{
	; last two params are width and height
	WinMove, Diamond Programmer - Untitled *,, 100, 100, 1700, 800
}

ChangeOperation()
{
	ActivateWindow()
	MouseClick, left,  172,  118
	MouseClick, left,  172,  118
	Sleep, 100
	WinWait, ECP5U - LFE5U-85F - Device Properties,, 0.01
	IfWinNotActive, ECP5U - LFE5U-85F - Device Properties, , WinActivate, ECP5U - LFE5U-85F - Device Properties, 
	WinWaitActive, ECP5U - LFE5U-85F - Device Properties, 

	if ErrorLevel <> 0
	{
		ToolTip, Problem when changing operation
		Sleep, 1000
		return 0
	}


	Send, {TAB}{ALTDOWN}{DOWN}{ALTUP}p
	Sleep, 300
	Loop, 4
	{
		Send, {UP}
		Sleep, 200
	}
	Sleep, 200
	
	Send, {ENTER}{ENTER}
}

ClearLog()
{
	MouseClick, right,  16,  700
	Sleep, 100
	Send, {UP}{ENTER}
}

DoProgram()
{
	ActivateWindow()
	Send, {TAB}{ALTDOWN}d{ALTUP}p
}

; returns 0 for success
; 1 for failure
; 2 for script failure
ProgramSearchSingle()
{
	DoProgram()

	Loop, 100
	{

		failfound := FindFail()
		winfound := FindSuccess()

		ToolTip, win %winfound% fail %failfound%

		if failfound = 1 && winfound = 1
		{
			MsgBox, Both Success and Failure detected. Script needs rewrite
			return 2
		}

		if failfound = 1
		{
			MsgBox, Chip Failed
			return 1
		}

		if winfound = 1
		{
			MsgBox, Pass
			return 0
		}


		Sleep, 100
	}
}



; -------------- Run at Startup stuff --------------
operationchanged = 0
starthotkey = 0


ToolTip, Welcome to SigLabs FPGA tester.`nTo get started you need to start with a GOOD FPGA open Diamond Programmer`nand press OK
Sleep, 200


Loop,
{
	winfound := FindWindow()	

	if winfound
	{
		if operationchanged = 0
		{
			ToolTip, Changing Operation
			ChangeOperation()
			operationchanged = 1
		}
		else
		{
			ToolTip, waiting for control+g  to go
			;ToolTip, blah %operationchanged% %starthotkey%
		}

		if starthotkey = 1
		{
			ToolTip, Starting...
			ActivateWindow()
			ResizeWindow()
			ClearLog()
			ProgramSearchSingle()



			starthotkey = 0
		}


	}
	else
	{
		ToolTip, not ready
		operationchanged = 0
		starthotkey = 0
	}
	Sleep, 10
}


ToolTip % Var
; FindFail()
; ToolTip, result

Sleep, 1000



^g::
	starthotkey = 1
	Sleep, 1000
return