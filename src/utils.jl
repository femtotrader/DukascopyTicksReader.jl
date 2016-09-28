function price_digits(symb)
    if symb[4:end] == "JPY"
        3
    else
        5
    end
end
