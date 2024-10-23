#Requires AutoHotkey v2
#include ..\SavePdf.ahk
#include ..\..\UIA-v2-main\Lib\UIA.ahk

entries := LoadDates('..\dates.txt')

Assert(result, test) {
    if (result) {
        OutputDebug("Pass`t" . test . '`r`n')
    } else {
        OutputDebug("Fail`t" . test . '`r`n')
    }
}

TestGetApplication() {
    app := GetApplication('..\config.ini')
    Assert(app, A_ThisFunc)
    return app
}

TestDownloadFile(app) {
    Assert(DownloadFile(app, 1), A_ThisFunc)
}

TestGoToReport(app) {
    Assert(GoToReport(app, entries[1].fullDate), A_ThisFunc)
}

TestGoToCalendar(app) {
    Assert(GoToCalendar(app, entries[1]), A_ThisFunc)
}

TestGoToPatient(app) {
    Assert(GoToPatient(app), A_ThisFunc)
}

Test() {
    app := TestGetApplication()

    if (app) {
        TestGoToCalendar(app)
        TestGoToPatient(app)
        TestGoToReport(app)
        TestDownloadFile(app)
    } else {
        OutputDebug("Testing interrupted'`r`n")
    }
}

Test()