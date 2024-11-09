#Requires AutoHotkey v2.0
#include .\SavePdf.ahk

Main() {
    app := GetApplication('config.ini')

    ; DownloadAllEntries(app) ; Uncomment when the bottom two work

    ; GoToReport(app, "01/01/2024") ; From the patient page
    ; DownloadFile(app)
}

Main()