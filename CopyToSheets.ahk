#Requires AutoHotkey v2


; Extract data and paste to Google Sheets

windowTitle := "PDF Report Extraction"

class GoogleSheets {
    __New() {

    }

    FindEmptyRow() {
        ; Activate Google Sheets tab (make sure it's already open)
        WinActivate("Google Sheets")
        Sleep(500)

        ; Go to the top of the first column (usually A1)
        Send("^g")  ; Opens the "Go to range" box in Google Sheets
        Sleep(200)
        Send("A1{Enter}")  ; Goes to cell A1
        Sleep(200)

        ; Move down until an empty cell is found
        Loop {
            ; Copy the cell content
            Send("^c")
            Sleep(100)
            ; Check if clipboard is empty (indicating an empty cell)
            if (Clipboard = "")
            {
                MsgBox("First empty row found at: " . A_Index)
                break
            }
            ; Move down to the next row
            Send("{Down}")
            Sleep(100)
        }

    }
}

Main() {
    WinActivate(windowTitle)
    Sleep(500)

    ; Open files
    ; click on open file
    ; open directory
    ; select all(?) files

    ; sleep

    ; click "Copy"

    ; activate Chrome
    ; Find latest non-filled row
    ; paste

    Send("{Tab 2}")  ; Tab twice to move to the second field (if applicable)
    Send("Hello World{Enter}")  ; Types text and presses Enter

    ; Set the click mode to screen coordinates
    CoordMode("Mouse", "Screen")
    WinActivate("My Tkinter App")
    Sleep(500)

    ; Click on specific coordinates in the Tkinter window
    ControlClick("", windowTitle, , "x200 y150")  ; Coordinates (x200, y150)


    ; Activate the browser window (replace "Google Chrome" with your browser name if different)
    WinActivate("Google Chrome")  ; or "Mozilla Firefox", etc.
    Sleep(500)  ; Wait for the window to activate

    ; Switch to the Google Sheets tab
    ; Use Ctrl+Tab to navigate tabs, or specify the tab by title
    Send("^2")  ; Sends Ctrl+2 to switch to the second tab, assuming Google Sheets is there
    Sleep(500)  ; Adjust the delay as necessary

    ; Paste the clipboard content in Google Sheets
    Send("^v")  ; Sends Ctrl+V to paste
}

Main()