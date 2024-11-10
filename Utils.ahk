#Requires AutoHotkey v2

tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"

ActvateWindow(windowTitleStart) {
    if WinExist(windowTitleStart) {
        WinActivate
        return 1
    }

    return 0
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
        MsgBox "Dates not found!" . filePath
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
        date := StrSplit(fields[1], "/")
        dates.Push({
            fullDate: fields[1],
            day: date[1],
            month: date[2],
            year: date[3],
            name: fields[2]
        })
    }

    return dates
}

GetPatientData(text) {
    ; Format: (<age>) (DD/MM/YYY) Last Name, First Name (<lang>)
    if (RegExMatch(text, "(\d{1,2}j) \((\d{1,2})/(\d{1,2})/(\d{4})\) ([\w\s,]+) \((\w+)\)", &match)) {
        return {
            age: match[1],
            dob: match[2] . "." . match[3] . "." . match[4],
            name: CapitalizeName(Trim(match[5])),
        }
    }
    return 0
}

GetHocrContent(bbox) {
    filePath := ".\tmp.png"

    pBitmap := Gdip_BitmapFrombbox(bbox.x "|" bbox.y "|" bbox.width "|" bbox.height)
    Gdip_SaveBitmapToFile(pBitmap, filePath)
    Gdip_DisposeImage(pBitmap)


    outputPath := ".\output"
    RunWait(tesseractPath . " " "" filePath "" " " "" outputPath "" " -c tessedit_create_hocr=1 --oem 3 -l nld+fra")

    return FileRead(outputPath . ".hocr")
}

ReadTextAtPosition(bbox) {
    filePath := ".\tmp.png"

    pBitmap := Gdip_BitmapFrombbox(bbox.x "|" bbox.y "|" bbox.width "|" bbox.height)
    Gdip_SaveBitmapToFile(pBitmap, filePath)
    Gdip_DisposeImage(pBitmap)

    outputPath := ".\output"
    RunWait(tesseractPath . " " "" filePath "" " " "" outputPath "" " --oem 3 -l nld+fra")

    return FileRead(outputPath . ".txt")
}

LocateTextAtPosition(targetText, bbox := application) {
    matches := []  ; Array to store all found coordinates
    position := 1  ; Starting position for RegExMatch

    hocrContent := GetHocrContent(bbox)

    while position := RegExMatch(hocrContent, "bbox\\W(\d+)\\W(\d+)\\W(\d+)\\W(\d+).*?" . targetText, &bbox, position + StrLen(bbox))
    {
        x1 := bbox[1]
        y1 := bbox[2]
        x2 := bbox[3]
        y2 := bbox[4]
        centerX := bbox.x + x1 + ((x2 - x1) / 2)
        centerY := bbox.y + y1 + ((y2 - y1) / 2)
        matches.Push({ x: centerX, y: centerY })
    }

    return matches
}