#Requires AutoHotkey v2
#include ..\SavePdf.ahk

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

    TestDownloadFile() {
        this.Assert(DownloadFile(), A_ThisFunc)
    }

    TestGoToReport() {
        this.Assert(GoToReport(entries[1].fullDate), A_ThisFunc)
    }

    TestGoToCalendar() {
        this.Assert(GoToCalendar(entries[1]), A_ThisFunc)
    }

    TestGoToPatient() {
        this.Assert(GoToPatient(0, 0), A_ThisFunc)
    }

    TestLocateText() {
        ; TODO: Refine
        locations := LocateText("Test")
        this.Assert(locations.Length > 1, A_ThisFunc)
    }

    Test() {
        if WinExist("Selecteer een datum") {
            WinClose
            Sleep 500
        }

        if WinExist("OK Overzicht") {
            WinClose
            Sleep 500
        }

        this.TestActivateApp()
        this.TestGoToCalendar()

        ;     TestGoToPatient()
        ;     TestGoToReport()
        ;     TestDownloadFile()

    }

}

TestSavePdf().Test()