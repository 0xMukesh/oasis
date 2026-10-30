-- inspo: https://www.lexaloffle.com/bbs/?pid=194045

local elapsed_time = 0

local ramps = {
    { DARK_BLUE, DARK_BLUE, DARK_GREEN,  DARK_GREEN,  GREEN,    GREEN,    YELLOW, YELLOW },
    { DARK_BLUE, DARK_BLUE, DARK_GRAY,   DARK_GRAY,   LAVENDER, LAVENDER, BLUE,   BLUE },
    { DARK_BLUE, DARK_BLUE, DARK_PURPLE, DARK_PURPLE, RED,      RED,      PINK,   PINK },
}

function Update()
    local speed = 2
    elapsed_time = elapsed_time + speed / 60
end

local function double_line(x0, y0, x1, y1, c)
    line(x0, y0, x1, y1, c)
    line(x0 + 1, y0, x1 + 1, y1, c)
end

local function draw_ribbon(t, y_offset, phase_offset, ramp, waves)
    for p = -21, 149 do
        local l  = sin(2 * PI * (waves * p / 100 + t / 4 + phase_offset))
        local v  = 8 - l * 6.9

        local x0 = floor(p - (p - 64) / 4)
        local y0 = floor(l * 10 + 48 + y_offset)
        local y1 = floor(l * 10 + 80 + y_offset)

        local k  = ceil(v / 2)
        local hi = ramp[k]
        local lo = ramp[k + floor(v % 2)]

        double_line(x0, y0, p, y1, hi * 16 + lo)
    end
end

function Draw()
    cls(BLACK)
    fillp(0x5a5a) -- checkboard pattern

    draw_ribbon(elapsed_time, 0, 0, ramps[1], 1)
    draw_ribbon(elapsed_time, 72, 0.5, ramps[2], 1)
    draw_ribbon(elapsed_time, 144, 1, ramps[3], 1)

    fillp(0)
end
