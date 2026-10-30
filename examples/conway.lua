local cells = {}
local frame = 0
local cell_size = 4
local cols = floor(W / cell_size)
local rows = floor(H / cell_size)
local initial_num_cells = floor(30 * cols * rows / 100)

local function count_neighbours(row, col)
    local count = 0

    for dr = -1, 1 do
        for dc = -1, 1 do
            if dr ~= 0 or dc ~= 0 then
                local r = row + dr
                local c = col + dc

                if r >= 1 and r <= rows and c >= 1 and c <= cols then
                    if cells[r][c] then
                        count = count + 1
                    end
                end
            end
        end
    end

    return count
end


function Init()
    srnd(time())
    set_fps(15)

    for i = 1, rows do
        cells[i] = {}

        for j = 1, cols do
            cells[i][j] = false
        end
    end

    for _ = 1, initial_num_cells do
        local row = floor(rnd(rows)) + 1
        local col = floor(rnd(cols)) + 1
        cells[row][col] = rnd(1) < 0.5
    end
end

function Update()
    for i = 1, rows do
        for j = 1, cols do
            local is_alive = cells[i][j]
            local neighbours = count_neighbours(i, j)

            if is_alive then
                if neighbours < 2 or neighbours > 3 then
                    cells[i][j] = false
                end
            else
                if neighbours == 3 then
                    cells[i][j] = true
                end
            end
        end
    end
end

function Draw()
    cls()

    for i = 1, rows do
        for j = 1, cols do
            local x = j * cell_size
            local y = i * cell_size

            if cells[i][j] then
                rect_fill(x, y, x + cell_size - 1, y + cell_size - 1, LAVENDER)
            end
        end
    end
end
