#Requires AutoHotkey v2.0

; Mock PixelGetColor for benchmarking
PixelGetColor(x, y, mode) {
    return (x * y) & 0xFFFFFF ; Return a pseudo-random color based on coords
}

; Function to get the name of a color based on its RGB value (Mocked for dependency)
GetColorName(RGBColor) {
    return "Color"
}

IsGrayish(color) {
    return false
}

; OLD METHOD
GetProminentColorOld(centerX, centerY, size := 11) {
    colors := Map()
    offset := (size - 1) // 2
    Loop size {
        y := A_Index - 1 - offset + centerY
        Loop size {
            x := A_Index - 1 - offset + centerX
            color := PixelGetColor(x, y, "RGB")
            if (colors.Has(color))
                colors[color]++
            else
                colors[color] := 1
        }
    }
    maxCount := 0
    prominentColor := 0
    for color, count in colors {
        if (count > maxCount && !IsGrayish(color)) {
            maxCount := count
            prominentColor := color
        }
    }
    if (prominentColor)
        return prominentColor
    return 0
}

; NEW METHOD
GetProminentColorNew(centerX, centerY, size := 11) {
    static colors := Map()
    colors.Default := 0
    colors.Clear()

    offset := (size - 1) // 2
    Loop size {
        y := A_Index - 1 - offset + centerY
        Loop size {
            x := A_Index - 1 - offset + centerX
            color := PixelGetColor(x, y, "RGB")
            colors[color]++
        }
    }
    maxCount := 0
    prominentColor := 0
    for color, count in colors {
        if (count > maxCount && !IsGrayish(color)) {
            maxCount := count
            prominentColor := color
        }
    }
    if (prominentColor)
        return prominentColor
    return 0
}

; Benchmark
RunBenchmark() {
    iterations := 10000
    startTime := A_TickCount
    Loop iterations {
        GetProminentColorOld(100, 100, 5)
    }
    timeOld := A_TickCount - startTime

    startTime := A_TickCount
    Loop iterations {
        GetProminentColorNew(100, 100, 5)
    }
    timeNew := A_TickCount - startTime

    MsgBox("Iterations: " . iterations . "`n"
        . "Old Method: " . timeOld . " ms`n"
        . "New Method: " . timeNew . " ms`n"
        . "Improvement: " . Round((timeOld - timeNew) / timeOld * 100, 2) . "%")
}

RunBenchmark()
