#Requires AutoHotkey v2
#include ..\UIA-v2-main\Lib\UIA.ahk

GetWindow(searchHandleSubstring) {
    windowList := WinGetList()

    foundHandle := 0
    for hwnd in windowList {
        windowTitle := WinGetTitle(hwnd)
        if InStr(windowTitle, searchHandleSubstring) {
            foundHandle := hwnd
            break
        }
    }

    return foundHandle ? UIA.ElementFromHandle(foundHandle) : 0
}

CapitalizeName(name) {
    name := StrReplace(name, "  ", " ")  ; Replace multiple spaces with a single space
    words := StrSplit(name, " ")
    capitalized := ""
    for index, word in words {
        capitalized .= StrUpper(SubStr(word, 1, 1)) . StrLower(SubStr(word, 2)) . " "
    }
    return RTrim(capitalized)
}

LoadConfig(filename) {
    configFilePath := A_ScriptDir . "\" . filename

    if !FileExist(configFilePath) {
        MsgBox "Config file not found!"
        ExitApp
    }

    configContent := FileRead(configFilePath)

    config := Map()
    for line in StrSplit(configContent, "`r`n") {
        line := Trim(line)

        if line = "" || SubStr(line, 1, 1) = ";" {
            continue
        }

        ; Expected format: <key>=<value>
        parts := StrSplit(line, "=")
        if parts.Length = 2 {
            key := Trim(parts[1])
            value := Trim(parts[2])
            config[key] := value
        }
    }

    return config
}

LoadDates(filename) {
    filePath := A_ScriptDir . "\" . filename
    if !FileExist(filePath) {
        MsgBox "Dates not found!".filePath
        ExitApp
    }

    content := FileRead(filePath)
    lines := StrSplit(content, "`r`n")
    dates := []

    for index, line in lines
    {
        if not line {
            continue
        }

        fields := StrSplit(line, "`t")
        date := StrSplit(fields[1], ".")
        dates.Push({
            day: date[1],
            month: date[2],
            year: date[3],
            name: fields[2]
        })
    }

    return dates
}

GetPatientData(text) {
    ; Format: (<age>) (DD/MM/YYY) Last Name, First Name (<country>)
    if (RegExMatch(text, "(\d{1,2}j) \((\d{1,2})/(\d{1,2})/(\d{4})\) ([\w\s,]+) \((\w+)\)", &match)) {
        return {
            age: match[1],
            dob: match[2] . "." . match[3] . "." . match[4],
            name: CapitalizeName(Trim(match[5])),
            country: match[6]
        }
    }
    return 0
}