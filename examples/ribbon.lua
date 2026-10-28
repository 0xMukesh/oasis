-- inspo: https://www.lexaloffle.com/bbs/?pid=194045#p
-- most of the magic numbers are taken from it as verbatim
-- the example doesn't support the "dithered" effect because oasis doesn't support `fillp` yet

local elapsed_time = 0

function Update()
    elapsed_time = elapsed_time + 1 / 60
end

local function double_line(x0, y0, x1, y1, c)
    line(x0, y0, x1, y1, c)
    line(x0 + 1, y0, x1 + 1, y1, c)
end

local function draw_ribbon(t, y_offset, phase_offset, color_shift)
    for p = -21, 149 do
        local wave = sin(2 * PI * (p / 100 + t / 4 + phase_offset))
        local v = 8 - wave * 6.9

        local x0 = floor(p - (p - 64) / 4)
        local x1 = floor(p)
        local y0 = floor(wave * 10 + 48 + y_offset)
        local y1 = floor(wave * 10 + 80 + y_offset)

        local c = band(ceil(v / 2) * 17 + (v % 2), 15)
        c = band(c + color_shift, 15)

        double_line(x0, y0, x1, y1, c)
    end
end

function Draw()
    cls(DARK_BLUE)

    draw_ribbon(elapsed_time, 0, 0, 0)
    draw_ribbon(elapsed_time, 72, 0.5, 2)
    draw_ribbon(elapsed_time, 144, 1, 4)
end
