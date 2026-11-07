local grid = { {} }
local cursor = {}

local cell_size = 4
local cols = floor(W / cell_size)
local rows = floor(H / cell_size)

local dirs = { UP, LEFT, DOWN, RIGHT }

local EMPTY, SAND, WATER, WOOD = 0, 1, 2, 3
local particles = {
    { id = SAND,  color = YELLOW },
    { id = WATER, color = BLUE },
    { id = WOOD,  color = BROWN },
}

local CELL_MODE_OUTLINE = "outline"
local CELL_MODE_FILL = "fill"

local function draw_cell(i, j, color, mode)
    local x0 = (i - 1) * cell_size
    local y0 = (j - 1) * cell_size
    local x1 = x0 + cell_size - 1
    local y1 = y0 + cell_size - 1

    if mode == CELL_MODE_FILL then
        rect_fill(x0, y0, x1, y1, color)
    elseif mode == CELL_MODE_OUTLINE then
        rect(x0, y0, x1, y1, color)
    end
end

local function setup_grid(g)
    for i = 1, cols do
        g[i] = {}
        for j = 1, rows do
            g[i][j] = 0
        end
    end
end

local function grid_swap(i1, j1, i2, j2)
    grid[i1][j1], grid[i2][j2] = grid[i2][j2], grid[i1][j1]
end

local function update_sand(i, j)
    if grid[i][j + 1] == EMPTY or grid[i][j + 1] == WATER then
        grid_swap(i, j, i, j + 1)
        return
    end

    local choice = rnd({ -1, 1 })
    local next_i = i + choice

    if next_i >= 1 and next_i <= cols and grid[next_i][j + 1] == EMPTY then
        grid_swap(i, j, next_i, j + 1)
    end
end

local function update_water(i, j)
    if grid[i][j + 1] == EMPTY then
        grid_swap(i, j, i, j + 1)
        return
    end

    local choice = rnd({ -1, 1 })
    local next_i = i + choice

    if next_i >= 1 and next_i <= cols and grid[next_i][j] == EMPTY then
        grid_swap(i, j, next_i, j)
    end
end

local function update_wood(i, j)
    grid[i][j] = WOOD
end

local function update_grid()
    for i = 1, cols do
        for j = rows - 1, 1, -1 do
            local particle = grid[i][j]

            if particle == SAND then
                update_sand(i, j)
            elseif particle == WATER then
                update_water(i, j)
            elseif particle == WOOD then
                update_wood(i, j)
            end
        end
    end
end

local function draw_grid()
    for i = 1, cols do
        for j = 1, rows do
            local particle = grid[i][j]
            if particle ~= 0 then
                draw_cell(i, j, particles[particle].color, CELL_MODE_FILL)
            end
        end
    end
end

local function create_cursor()
    cursor = {
        i = floor(cols / 2),
        j = floor(rows / 2),
        selected_particle = nil,
        draw = function(self)
            if self.selected_particle == nil then
                draw_cell(self.i, self.j, LAVENDER, CELL_MODE_OUTLINE)
            else
                draw_cell(self.i, self.j, particles[self.selected_particle].color, CELL_MODE_FILL)
            end
        end,
        _advance = function(self, move)
            -- move the cursor
            if move == UP then
                self.j = self.j - 1
            end
            if move == LEFT then
                self.i = self.i - 1
            end
            if move == DOWN then
                self.j = self.j + 1
            end
            if move == RIGHT then
                self.i = self.i + 1
            end

            -- add particles below it
            if self.i < 1 then self.i = 1 end
            if self.i > cols then self.i = cols end
            if self.j < 1 then self.j = 1 end
            if self.j > rows then self.j = rows end

            if self.selected_particle ~= nil and self.j < rows then
                if grid[self.i][self.j + 1] == 0 then
                    grid[self.i][self.j + 1] = self.selected_particle
                end
            end
        end,
        update = function(self)
            if btnp(A) then
                if self.selected_particle == nil then
                    self.selected_particle = 1
                else
                    self.selected_particle = (self.selected_particle + 1) % (#particles + 1)
                    if self.selected_particle == 0 then
                        self.selected_particle = nil
                    end
                end
            elseif btnp(B) then
                self.selected_particle = nil
            end

            for i = 1, #dirs do
                if btn(dirs[i]) then
                    self:_advance(dirs[i])
                end
            end
        end
    }
end

function Init()
    rnd(time())

    setup_grid(grid)
    create_cursor()
end

function Update()
    update_grid()
    cursor:update()
end

function Draw()
    cls(BLACK)
    draw_grid()
    cursor:draw()
end
