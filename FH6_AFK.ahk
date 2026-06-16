#Requires AutoHotkey v2.0

; ==========================================
; CONFIGURATION
; ==========================================

Steps := [

    {
        Name: "Open Menu",
        ActionType: "Key",
        ActionValue: "{Esc}",
		DelayAfter: 500
    },

    {
        Name: "Creative Hub",
		X: 955,
		Y: 251,
		Color: 0xCAFF02, ; or 0xC1F90A but should adjust tolerance
        Tolerance: 15,
        ActionType: "LoopKey",
        ActionValue: "{PgUp}",
		Count: 2,
		Interval: 200,
		DelayAfter: 300
    },
	
	{
        Name: "Event Lab",
        ActionType: "Key",
        ActionValue: "{Enter}"
    },
	
	{
        Name: "Play Event",
		X: 912,
		Y: 280,
		Color: 0xC1F90A,
        ActionType: "Key",
        ActionValue: "{Enter}",
		DelayAfter: 500
    },
	
	{
        Name: "My Favorites",
		X: 716,
		Y: 200,
		Color: 0xCAFF02,
        ActionType: "LoopKey",
		DelayBefore: 1000,
        ActionValue: "{PgDn}",
		Count: 7,
		Interval: 600,
		DelayAfter: 1000
    },
	
	/*
	{
        Name: "My History",
		X: 716,
		Y: 200,
		Color: 0xCAFF02,
        ActionType: "Click",
        ClickX: 106,
        ClickY: 178,
        DelayAfter: 2000
    },
	*/
	
	{
        Name: "Select Race",
		X: 716,
		Y: 200,
		Color: 0xCAFF02,
        ActionType: "Key",
        ActionValue: "{Enter}",
		DelayAfter: 1000
    },
	
	{
        Name: "Solo",
		X: 956,
		Y: 530,
		Color: 0xCAFF02,
        ActionType: "Key",
        ActionValue: "{Enter}",
		DelayAfter: 2000
    },
	
	{
        Name: "Select Car",
		X: 564,
		Y: 205,
		Color: 0xCAFF02,
        ActionType: "Key",
        ActionValue: "{Enter}",
		DelayAfter: 15000
    },
	
	{
        Name: "Start Race Event",
		X: 255,
		Y: 650,
		Color: 0xCAFF02,
        ActionType: "Key",
        ActionValue: "{Enter}",
		DelayAfter: 2000
    },
	
	{
        Name: "Driving !!",
        ActionType: "Key",
        ActionValue: "{W Down}",
		DelayAfter: 340000 ; 5 mins 40 secs
    },
	
	{
        Name: "End Race",
		X: 862,
		Y: 245,
		Color: 0xCAFF02,
        ActionType: "Key",
        ActionValue: "{W Up}{Enter}",
		DelayAfter: 5000
    },
	
	{
        Name: "Quit Mission Select Menu",
		X: 276,
		Y: 211,
		Color: 0xCAFF02,
        ActionType: "Key",
        ActionValue: "{Esc}",
		DelayAfter: 6000
    }
	
]

/*
; Example code:
Steps := [

    ; Wait for a button to appear
	; DelayAfter will dela after pressin key
	; Timeout is the time to stop detecting color and exit app
    {
        Name: "Accept Match",
        X: 500,
        Y: 300,
        Color: 0x00FF00,
        Tolerance: 15,
        ActionType: "Key",
        ActionValue: "{Enter}",
        Timeout: 30000,
        DelayAfter: 1000
    },

    ; Execute immediately after previous step
    {
        Name: "Wait 2 Seconds Then Press A",
        ActionType: "Key",
        ActionValue: "a",
        DelayAfter: 2000
    },

    ; Click immediately
    {
        Name: "Click Continue",
        ActionType: "Click",
        ClickX: 800,
        ClickY: 600,
        DelayAfter: 1000
    },

    ; Wait for another color
    {
        Name: "Start Game",
        X: 700,
        Y: 400,
        Color: 0xFF0000,
        Tolerance: 15,
        ActionType: "Key",
        ActionValue: "{Space}",
        Timeout: 30000,
        DelayAfter: 1000
    },
	
	; Press Enter 10 times with interval of 200ms
	{
		Name: "Spam Enter",
		ActionType: "LoopKey",
		ActionValue: "{Enter}",
		Count: 10,
		Interval: 200
	},
	
	{
		Name: "Accept Match",
		X: 500,
		Y: 300,
		Color: 0x00FF00,
		Tolerance: 15,
		SearchRadius: 5,    ; Search in 11×11 area
		ActionType: "Key",
		ActionValue: "{Enter}"
	}
]
*/

; ==========================================
; FUNCTIONS
; ==========================================

ColorMatch(color1, color2, tolerance := 10)
{
    r1 := (color1 >> 16) & 255
    g1 := (color1 >> 8) & 255
    b1 := color1 & 255

    r2 := (color2 >> 16) & 255
    g2 := (color2 >> 8) & 255
    b2 := color2 & 255

    return Abs(r1 - r2) <= tolerance
        && Abs(g1 - g2) <= tolerance
        && Abs(b1 - b2) <= tolerance
}

WaitForColor(step)
{
    startTime := A_TickCount

    tolerance := step.HasOwnProp("Tolerance")
        ? step.Tolerance
        : 10

    timeout := step.HasOwnProp("Timeout")
        ? step.Timeout
        : 300000

    radius := step.HasOwnProp("SearchRadius")
        ? step.SearchRadius
        : 1

    Loop
    {
        if AreaContainsColor(
            step.X,
            step.Y,
            step.Color,
            tolerance,
            radius
        )
            return true

        if (A_TickCount - startTime > timeout)
			ExitApp()
            ;return false

        Sleep(200)
    }
}

AreaContainsColor(centerX, centerY, targetColor, tolerance := 10, radius := 1)
{
    Loop (radius * 2 + 1)
    {
        dx := A_Index - radius - 1

        Loop (radius * 2 + 1)
        {
            dy := A_Index - radius - 1

            currentColor := PixelGetColor(
                centerX + dx,
                centerY + dy
            )

            if ColorMatch(currentColor, targetColor, tolerance)
                return true
        }
    }

    return false
}

PerformAction(step)
{
    switch step.ActionType
    {
        case "Key":
            Send(step.ActionValue)

        case "Click":
            Click(step.ClickX, step.ClickY)

        case "LoopKey":

            count := step.HasOwnProp("Count")
                ? step.Count
                : 1

            interval := step.HasOwnProp("Interval")
                ? step.Interval
                : 100

            Loop count
            {
                Send(step.ActionValue)

                if (A_Index < count)
                    Sleep(interval)
            }

        default:
            MsgBox("Unknown ActionType: " step.ActionType)
    }
}

; ==========================================
; HOTKEYS
; ==========================================

F1::
{
    MouseGetPos(&x, &y)
    color := PixelGetColor(x, y)
	
	result :=
    (
    "X: " x ",`n"
    "Y: " y ",`n"
    "Color: " Format("0x{:06X}", color) ","
    )
	
	A_Clipboard := result
    MsgBox(result)
}

^Q::
{
    ToolTip("Automation Started")

    Loop
    {
        for step in Steps
        {
            ; If Color field is missing, execute immediately
            if !step.HasOwnProp("Color")
            {
                ToolTip("Executing: " step.Name)
				
				if step.HasOwnProp("DelayBefore") ; Added by J1soon
                    Sleep(step.DelayBefore)

                PerformAction(step)

                if step.HasOwnProp("DelayAfter")
                    Sleep(step.DelayAfter)

                continue
            }

            ToolTip("Waiting for: " step.Name)

            if !WaitForColor(step)
            {
                ToolTip("Timeout: " step.Name)
                Sleep(1000)
                continue
            }

            ToolTip("Detected: " step.Name)

            PerformAction(step)

            if step.HasOwnProp("DelayAfter")
                Sleep(step.DelayAfter)
        }

        ToolTip("Sequence Complete - Restarting")
        Sleep(2000)
    }
}

^E::
{
    ToolTip()
    ExitApp()
}