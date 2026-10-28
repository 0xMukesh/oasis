-- inspo: https://www.lexaloffle.com/bbs/?tid=160053

local elapsed_time = 0
local phase = 0

local SPOKE_COUNT = 55
local BASE_RADIUS = 80
local DOT_SPACING = 3

function Init()
end

function Update()
    elapsed_time = elapsed_time + 0.001
    phase = phase + 0.02
end

function Draw()
    cls(BLACK)

    local scale = min(W, H) / 128
    local center_x = W / 2
    local center_y = H / 2

    for spoke = 1, SPOKE_COUNT do
        local angle = (spoke / SPOKE_COUNT + elapsed_time) * 2 * PI
        local offset_x = cos(angle) * BASE_RADIUS
        local offset_y = sin(angle) * BASE_RADIUS
        local dot_count = floor((abs(offset_x) + abs(offset_y)) / DOT_SPACING)

        for dot = 1, dot_count do
            local distance = dot / dot_count
            local wave = dot * dot * 3.1 * 2 * PI

            local start_distance = distance
                + cos(wave + phase * (distance + 1) / 4 * 2 * PI) / 9
            local end_distance = distance
                + cos(wave + (phase + 0.04) * (distance + 1) / 4 * 2 * PI) / 9

            local start_x = floor(center_x + offset_x * start_distance * scale)
            local start_y = floor(center_y + offset_y * start_distance * scale)
            local end_x = floor(center_x + offset_x * end_distance * scale)
            local end_y = floor(center_y + offset_y * end_distance * scale)

            local line_color = RED
            if band(floor(dot / 4), 1) == 1 then
                line_color = BLUE
            end

            line(start_x, start_y, end_x, end_y, line_color)
            pset(start_x, start_y, YELLOW)
        end
    end
end
