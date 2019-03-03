-- input --
input = {0,0,0,0,0,0}

function btnd(i)
    return btn(i) and not input[i + 1]
end

function btnu(i)
    return not btn(i) and input[i + 1]
end

function late_update_input()
    for i=0, 6 do
        input[i + 1] = btn(i)
    end
end