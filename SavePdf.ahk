#Requires AutoHotkey v2
#include Utils.ahk
#include ..\UIA-v2-main\Lib\UIA.ahk

config := LoadConfig('config.ini')
dates := LoadDates('dates.txt')

if !config.Has("windowTitle") {
    MsgBox "Missing config: windowTitle"
    ExitApp
}


DownloadAllEntries(app) {
    for entry in dates {
        app.FindElement({ Type: "MenuItem", Name: "Afspraken" }).Click()
        app.WaitElement({ Name: "Overzicht OK andere dag", mm: 2 }).Click()

        ; Select Date
        dateSelect := GetWindow("Selecteer een datum")
        dateSelect.FindElement({ Type: "Spinner", Name: "day" }).Value := entry.day
        dateSelect.FindElement({ Type: "Spinner", Name: "month" }).Value := entry.month
        dateSelect.FindElement({ Type: "Spinner", Name: "year" }).Value := entry.year
        dateSelect.FindElement({ Type: "Button", Name: "Selecteer" }).Click()

        ; To-do: Select which operation

        app.WaitElement({ Name: "Selecteer patiënt", mm: 2 }).Click()
        app.FindElement({ Type: "MenuItem", Name: "Dossier" }).Click()
        app.WaitElement({ Name: "Volledig dossier", mm: 2 }).Click()

        NavigateToPatient(app, entry.fullDate)
    }
}

NavigateToPatient(app, date) {
    interventions := app.WaitElement({ Name: "Ingrepen", mm: 2 })
    interventions.Click()

    ; dd/mm/yyyy Orthopedie
    orthopedics := interventions.FindElement({ Type: "TreeItem", Name: date . " Orthopedie" })
    orthopedics.Click()

    ; dd/mm/yyyy <description>
    orthopedics.WaitElement({ Type: "TreeItem", Name: date, mm: 2 }).Click()
}

DownloadFile(app) {
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

Main() {
    app := GetWindow(config["windowTitle"])
    if !app {
        MsgBox "Window not found: " . config['windowTitle']
        ExitApp
    }

    DownloadFile(app)
}

Main()