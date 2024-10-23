#Requires AutoHotkey v2
#include Utils.ahk
#include ..\UIA-v2-main\Lib\UIA.ahk

config := LoadConfig('config.ini')
entries := LoadDates('dates.txt')

if !config.Has("windowTitle") {
    MsgBox "Missing config: windowTitle"
    ExitApp
}

NavigateToPatient(app) {
    app.FindElement({ Type: "MenuItem", Name: "Afspraken" }).Click()
    app.WaitElement({ Name: "Overzicht OK andere dag", mm: 2 }).Click()

    ; To-do: Select Date

    app.FindElement({ Type: "Button", Name: "Selecteer" }).Click()

    ; To-do: Select which operation

    app.WaitElement({ Name: "Selecteer patiënt", mm: 2 }).Click()
    app.FindElement({ Type: "MenuItem", Name: "Dossier" }).Click()
    app.WaitElement({ Name: "Volledig dossier", mm: 2 }).Click()

    interventions := app.WaitElement({ Name: "Ingrepen", mm: 2 })
    interventions.Click()
    ; dd/mm/yyyy Orthopedie
    orthopedics := interventions.FindElement({ Type: "TreeItem", Name: "Orthopedie" })
    orthopedics.Click()

    ; dd/mm/yyyy <description>
    orthopedics.WaitElement({ Type: "TreeItem", Name: "dd/mm/yyyy", mm: 2 }).Click()
}

Main() {
    app := GetWindow(config["windowTitle"])
    if !app {
        MsgBox "Window not found: " . config['windowTitle']
        ExitApp
    }

    fileName := 0
    toolbar := app.FindFirst("ControlType", "ToolBar")
    staticTextItems := toolbar.FindAll("ControlType", "Text")
    for item in staticTextItems {
        patient := GetPatientData(item.Current.Name)
        if (patient) {
            fileName := patient.name . " " . patient.dob
            break
        }
    }

    app.FindElement({ Type: "MenuItem", Name: "Afdrukken" }).Click()
    app.WaitElement({ Name: "Nota view", mm: 2 }).Click()

    WinWait("Print")
    printEl := GetWindow("Print")
    printEl.FindElement({ Type: "Button", Name: "Print" }).Click()

    WinWait("Printeruitvoer opslaan als")
    printEl := GetWindow("Printeruitvoer opslaan als")
    if fileName {
        printEl.FindElement({ Type: "Edit", Name: "Bestandsnaam" }).Valuee := fileName
        printEl.FindElement({ Type: "Button", Name: "Opslaan" }).Click()
    } else {
        MsgBox "Patient info not found"
    }
}

Main()