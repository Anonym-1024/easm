
func multiply { //(a: int, b: int) -> result: int

    loada $a; lbl start = $$
    loadb $sum
    addab $sum
    
    loada $one
    loadb $count
    addab $count
    loada $b
    jmpe $end
    jmp $start
    
    loada $sum
    storea $result
    ret
}

func divide { //(a: int, b: int) -> result: int
    
}

func mod { //(a: int, b: int) -> result: int
    
}

func pow { //(a: int, exp: int) -> result: int
    
}
