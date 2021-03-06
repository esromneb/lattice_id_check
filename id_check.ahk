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
        ToolTip, Failyes
        sleep, 300
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
    x2 = 400
    y2 = 400

	CoordMode Pixel
	ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %image_path%
    if ErrorLevel = 0
    {
        ToolTip, Yes1
        sleep, 300
        return 1
    }


    image_path := "clipped\pass_id_result2.bmp"

    ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %image_path%
    if ErrorLevel = 0
    {
        ToolTip, Yes2
        sleep, 300
        return 1
    }

    image_path := "clipped\pass_id_result3.bmp"

    ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %image_path%
    if ErrorLevel = 0
    {
        ToolTip, Yes3
        sleep, 300
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
	MouseClick, left,  172,  125
	MouseClick, left,  172,  125
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

	Loop 100
	{

		failfound := FindFail()
		winfound := FindSuccess()

		; ToolTip, win %winfound% fail %failfound%

		if failfound = 1 && winfound = 1
		{
			MsgBox, Both Success and Failure detected. Script needs rewrite
			return 2
		}

		if failfound = 1
		{
			SoundPlay, damn_it.wav
			MsgBox, Chip Failed
			return 1
		}


		if winfound = 1
		{
			return 0
		}

		; ToolTip, Single number is %A_Index%


		Sleep, 100
	}
}

ProgramMulti()
{
	passes := 0
	fails := 0

	; ToolTip, Program Multi
	; sleep, 1000


	; This number is how many tests to do per ctrl+g

	Loop, 20
	{
		singleres := ProgramSearchSingle()

		if singleres = 0
		{
			passes := passes + 1
		}
		else
		{
			ToolTip, Last Chip Failed. Waiting for control+g  to go
			return 0
		}

		ToolTip, Passes %passes%
		; sleep, 500
	}
	SoundPlay, bitchin.wav
}


; -------------- Run at Startup stuff --------------
operationchanged = 0
starthotkey = 0


ToolTip, Welcome to SigLabs FPGA tester.`nTo get started you need to start with a GOOD FPGA open Diamond Programmer`nand press OK
Sleep, 300


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
			ToolTip, Waiting for control+g  to go
		}
		if starthotkey = 1
		{
			ToolTip, Starting...
			ActivateWindow()
			ResizeWindow()
			ClearLog()
			ProgramMulti()

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


^g::
	starthotkey = 1
	; Sleep, 1000
return
