#Requires AutoHotkey v2
#include Utils.ahk
#include ..\UIA-v2-main\Lib\UIA.ahk

config := LoadConfig('config.ini')

if !config.Has("windowTitle") {
    MsgBox "Missing config: windowTitle"
    ExitApp
}

Main() {
    app := GetWindow(config["windowTitle"])
    if !app {
        MsgBox "Window not found: " . config['windowTitle']
        ExitApp
    }

    ; Fetch patient info
    patient := Map()
    fileName := 0
    toolbar := app.FindFirst("ControlType", "ToolBar")
    staticTextItems := toolbar.FindAll("ControlType", "Text")
    for item in staticTextItems {
        ; Format: (<age>) (DD/MM/YYY) Last Name, First Name (<country>)
        if (RegExMatch(item.Current.Name, "(\d{1,2}j) \((\d{1,2})/(\d{1,2})/(\d{4})\) ([\w\s,]+) \((\w+)\)", &match)) {
            patient["age"] := match[1]
            patient["dob"] := match[2] . "." . match[3] . "." . match[4]
            patient["name"] := CapitalizeName(Trim(match[5]))
            patient["country"] := match[6]
            fileName := patient["name"] . " " . patient["dob"]
            break
        }
    }
    
    app.FindElement({Type:"MenuItem", Name:"Afdrukken"}).Click()
    app.WaitElement({Name:"Nota view", mm:2}).Click()

    WinWait("Print")
    printEl := GetWindow("Print")
    printEl.FindElement({Type:"Button", Name:"Print"}).Click()
    
    WinWait("Printeruitvoer opslaan als")
    printEl := GetWindow("Printeruitvoer opslaan als")
    if fileName {
        printEl.FindElement({Type:"Edit", Name:"Bestandsnaam"}).Valuee := fileName
        printEl.FindElement({Type:"Button", Name:"Opslaan"}).Click()
    } else {
        MsgBox "Patient info not found"
    }
}

Main()