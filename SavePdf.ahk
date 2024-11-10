#Requires AutoHotkey v2
#include Utils.ahk
#include libs\Gdip_All.ahk


DownloadAllEntries() {
    processed := []
    dates := LoadDates('dates.txt')
    for entry in dates {
        GoToCalendar(entry)

        for coord in LocateText(entry.name) {
            Click(coord.x, coord.y, "right")
            GoToPatient(coord.x, coord.y)
            GoToReport(entry.fullDate)
            DownloadFile()

            ; To-do: Go back to calendar view
            GoToCalendar(entry)
        }
    }
}

ActivateOrExit(title) {
    if !ActvateWindow(title) {
        MsgBox("Could not find window: " . title)
        ExitApp()
    }
}

GoToPatient(startX, startY) {
    Click(startX + 20, startY + 5) ; "Selecteer patiënt ; To-do check distance
    ; Click(0, 0) ; "Dossier"
    ; To-do?: Save name via OCR before proceeding
    ; Click(0, 0) ; "Volledig dossier"
}

GoToCalendar(entry) {
    Click(283, 33) ; "Afspraken"
    Sleep(500)
    Click(360, 140) ; "Overzicht OK andere dag"
    Sleep(500)

    ActivateOrExit("Selecteer een datum")

    ; As soon as a valid input (e.g., day) is entered, the program immediately tabs to the next field
    SendText(entry.day)
    Sleep(500)
    SendText(entry.month)
    Sleep(500)
    SendText(entry.year)
    Sleep(500)
    Send("{Tab}")
    Send("{Space}")
    return 1
}

GoToReport(date) {
    ; Click "Ingrepen"


    ; Click dd/mm/yyyy Orthopedie
    ; Click dd/mm/yyyy <description>
    return 0
}

DownloadFile() {
    fileName := 0
    ; TODO: Fetch name via OCR
    patient := GetPatientData("(<age>) (DD/MM/YYY) Last Name, First Name (<lang>)")
    if (patient) {
        fileName := patient.name . " " . patient.dob
    }

    ; Click "Afdrukken"
    ; Click "Nota view"

    Sleep(1000)
    ActivateOrExit("Print")
    ; printEl.FindElement({ Type: "Button", Name: "Print" }).Click()

    ; ActivateOrExit("Printeruitvoer opslaan als")
    if fileName {
        SendText(fileName) ; "Bestandsnaam"
        Send("{Tab}")
        Send("{Enter}") ; "Opslaan"
    } else {
        MsgBox "Patient info not found"
        return 0
    }

    return 1
}


LocateText(targetText) {
    filePath := ".\tmp.png"
    x := 0
    y := 74
    width := 2560
    height := 1326

    ; Save screenshot to a file
    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" width "|" height)
    Gdip_SaveBitmapToFile(pBitmap, filePath)
    Gdip_DisposeImage(pBitmap)

    tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"
    outputPath := ".\outut"
    RunWait(tesseractPath . " " "" filePath "" " " "" outputPath "" " -c tessedit_create_hocr=1 --oem 3 -l nld+fra")

    hocrContent := FileRead(outputPath . ".hocr")

    matches := []  ; Array to store all found coordinates
    position := 1  ; Starting position for RegExMatch

    while position := RegExMatch(hocrContent, "bbox\\W(\d+)\\W(\d+)\\W(\d+)\\W(\d+)", &bbox, position + StrLen(bbox)) ; Adjust regex as necessary
    {
        x1 := bbox[1]
        y1 := bbox[2]
        x2 := bbox[3]
        y2 := bbox[4]
        centerX := x + x1 + ((x2 - x1) / 2)
        centerY := y + y1 + ((y2 - y1) / 2)
        matches.Push({ x: centerX, y: centerY })
    }

    return matches
}

ActivateApp(filename) {
    config := LoadConfig(filename)
    if !config.Has("windowTitle") {
        MsgBox "Missing config: windowTitle"
        ExitApp
    }

    if WinExist(config["windowTitle"]) {
        WinActivate
        return 1
    } else {
        MsgBox "Window not found: " . config['windowTitle']
        ExitApp
    }
}