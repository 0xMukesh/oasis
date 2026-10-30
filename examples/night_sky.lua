local horizon = 200
local frame = 0

local stars = {}

function Init()
    for i = 1, 120 do
        stars[i] = {
            x  = rnd() * W,
            y  = rnd() * horizon,
            ph = rnd() * 2 * PI,
        }
    end
end

function Update()
    frame = frame + 1
end

function Draw()
    -- the ocean
    rect_fill(0, horizon, W - 1, H - 1, DARK_BLUE)

    -- the stars
    local t = frame * 0.05
    for i = 1, #stars do
        local s = stars[i]
        local c = sin(t + s.ph) > 0 and WHITE or BLACK
        pset(floor(s.x), floor(s.y), c)
    end

    -- kinda like a moon?
    circ_fill(220, 40, 30, LIGHT_GRAY)
end
