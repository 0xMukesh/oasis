local horizon = 200
local frame = 0

local BLACK, DARK_BLUE, LIGHT_GRAY, WHITE = 0, 1, 6, 7

local stars = {}

function _init()
    math.randomseed(os.time())
    for i = 1, 120 do
        stars[i] = {
            x  = math.random() * 256,
            y  = math.random() * horizon,
            ph = math.random() * 2 * math.pi,
        }
    end
end

function _update()
    frame = frame + 1
end

function _draw()
    -- the ocean
    rect_fill(0, horizon, 256 - 1, 256 - 1, DARK_BLUE)

    -- the stars
    local t = frame * 0.05
    for _, s in ipairs(stars) do
        local c = math.sin(t + s.ph) > 0 and WHITE or BLACK
        pset(math.floor(s.x), math.floor(s.y), c)
    end

    -- kinda like a moon?
    circ_fill(220, 40, 30, LIGHT_GRAY)
end
