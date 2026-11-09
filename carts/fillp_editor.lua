local pattern        = 0
local grid           = {}
local cursor         = {}

local n_rows, n_cols = 4, 4
local cell_size, gap = 20, 2

local grid_width     = n_cols * cell_size + (n_cols - 1) * gap
local grid_height    = n_rows * cell_size + (n_rows - 1) * gap

local left           = floor((W - grid_width) / 2)
local top            = floor((H - grid_height) / 2)

local function cell_coords(row, col)
    local x0 = left + col * (cell_size + gap)
    local y0 = top + row * (cell_size + gap)
    local x1 = x0 + cell_size - 1
    local y1 = y0 + cell_size - 1

    return x0, y0, x1, y1
end

local function create_grid()
    grid = {
        data = {},
        draw = function(self)
            for row = 0, (n_rows - 1) do
                for col = 0, (n_cols - 1) do
                    local x0, y0, x1, y1 = cell_coords(row, col)

                    if self.data[row + 1][col + 1] then
                        rect_fill(x0, y0, x1, y1, WHITE)
                    else
                        rect(x0, y0, x1, y1, LIGHT_GRAY)
                        rect_fill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, BLACK)
                    end
                end
            end
        end,
        _update_pattern = function(self)
            for row = 0, (n_rows - 1) do
                for col = 0, (n_cols - 1) do
                    local r = n_rows - row - 1
                    local c = n_cols - col - 1
                    local i = (n_rows * r + c)

                    local mask = shl(1, i)

                    if self.data[row + 1][col + 1] then
                        pattern = bor(pattern, mask)
                    else
                        pattern = band(pattern, bnot(mask))
                    end
                end
            end
        end,
        toggle_cell = function(self, row, col)
            self.data[row + 1][col + 1] = not self.data[row + 1][col + 1]
            self:_update_pattern()
        end,
    }

    for row = 0, (n_rows - 1) do
        grid.data[row + 1] = {}
        for col = 0, (n_cols - 1) do
            grid.data[row + 1][col + 1] = false
        end
    end
end

local function create_cursor()
    cursor = {
        row = 0,
        col = 0,
        draw = function(self)
            local x0, y0, x1, y1 = cell_coords(self.row, self.col)

            rect(x0, y0, x1, y1, RED)
        end,
        update = function(self, dr, dc)
            self.row = (self.row + dr) % n_rows
            self.col = (self.col + dc) % n_cols
        end
    }
end

local function render_ui()
    cls(DARK_BLUE)

    fillp(pattern)
    rect_fill(4, 4, W - 5, 40, bor(shl(BLUE, 4), LAVENDER)) -- pattern preview screen
    fillp()

    line(3, 45, W - 4, 45, DARK_GRAY) -- divider
end

local function render_text()
    local text = "PATTERN: " .. format("0x%X", pattern)
    print(text, 5, 50, BLUE)
end

function Init()
    create_grid()
    create_cursor()
end

function Update()
    if btnp(UP) then cursor:update(-1, 0) end
    if btnp(LEFT) then cursor:update(0, -1) end
    if btnp(DOWN) then cursor:update(1, 0) end
    if btnp(RIGHT) then cursor:update(0, 1) end

    if btnp(A) then grid:toggle_cell(cursor.row, cursor.col) end
end

function Draw()
    render_ui()
    render_text()
    grid:draw()
    cursor:draw()
end
