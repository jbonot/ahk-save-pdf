#Requires AutoHotkey v2
#include Utils.ahk
#include libs\UIA.ahk


DownloadAllEntries(app, isTest := 0) {
    processed := []
    dates := LoadDates('dates.txt')
    for entry in dates {
        GoToCalendar(entry)

        ; To-do: Narrow scope to calendar instead of app
        calendar := app
        for timeslot in calendar.FindAll({ Name: StrUpper(entry.name), mm: 2 }) {
            if processed.Has(timeslot.Name) {
                continue
            }

            timeslot.Click()
            GoToPatient(app)
            GoToReport(app, entry.fullDate)
            DownloadFile(app, isTest)
            processed.Push(timeslot.Name)

            ; To-do: Go back to calendar view
            GoToCalendar(entry)
        }
    }
}

GoToPatient(app) {
    app.WaitElement({ Name: "Selecteer patiënt", mm: 2 }).Click()
    app.FindElement({ Type: "MenuItem", Name: "Dossier" }).Click()
    app.WaitElement({ Name: "Volledig dossier", mm: 2 }).Click()
}

GoToCalendar(entry) {
    Click(283, 33) ; "Afspraken"
    Sleep(500)
    Click(360, 140) ; "Overzich OK andere dag"
    Sleep(500)

    if WinExist("Selecteer een datum") {
        WinActivate
        Sleep(100)
    } else {
        return 0
    }

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

GoToReport(app, date) {
    interventions := app.WaitElement({ Name: "Ingrepen", mm: 2 })
    interventions.Click()

    ; dd/mm/yyyy Orthopedie
    orthopedics := interventions.FindElement({ Type: "TreeItem", Name: date . " Orthopedie" })
    orthopedics.Click()

    ; dd/mm/yyyy <description>
    orthopedics.WaitElement({ Type: "TreeItem", Name: date, mm: 2 }).Click()
    return 1
}

DownloadFile(app, isTest := 0) {
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
        saveBtn := printEl.FindElement({ Type: "Button", Name: "Opslaan" })
        if (isTest) {
            saveBtn.Highlight()
            printEl.FindElement({ Type: "Button", Name: "Close" }).Click()
        } else {
            saveBtn.Click()
        }
    } else {
        MsgBox "Patient info not found"
        return 0
    }

    return 1
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
