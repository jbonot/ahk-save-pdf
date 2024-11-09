#Requires AutoHotkey v2
#include ..\SavePdf.ahk
#include ..\libs\UIA.ahk

entries := LoadDates('TestSavePdf.dates.txt')

class TestSavePdf {

    Assert(result, test) {
        if (result) {
            OutputDebug("Pass`t" . test . '`r`n')
        } else {
            OutputDebug("Fail`t" . test . '`r`n')
        }
    }
    
    TestActivateApp() {
        this.Assert(ActivateApp('..\config.ini'), A_ThisFunc)
    }
    
    TestDownloadFile(app) {
        this.Assert(DownloadFile(app, 1), A_ThisFunc)
    }
    
    TestGoToReport(app) {
        this.Assert(GoToReport(app, entries[1].fullDate), A_ThisFunc)
    }
    
    TestGoToCalendar(app) {
        this.Assert(GoToCalendar(app, entries[1]), A_ThisFunc)
    }
    
    TestGoToPatient(app) {
        this.Assert(GoToPatient(app), A_ThisFunc)
    }
    
    Test() {
        this.TestActivateApp()
    
        ; if (app) {
        ;     TestGoToCalendar(app)
        ;     TestGoToPatient(app)
        ;     TestGoToReport(app)
        ;     TestDownloadFile(app)
        ; } else {
        ;     OutputDebug("Testing interrupted'`r`n")
        ; }
    }
    
}

TestSavePdf().Test()