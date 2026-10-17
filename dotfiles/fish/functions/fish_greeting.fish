function fish_greeting
    if not command -v fastfetch &> /dev/null
        return
    end

    if test -n "$COLUMNS"; and test "$COLUMNS" -lt 72
        fastfetch --logo none
    else
        fastfetch
    end
end
