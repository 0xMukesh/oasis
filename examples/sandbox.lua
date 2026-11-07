local grid              = { {} }
local fire_strength     = { {} }
local cursor            = {}

local cell_size         = 4
local cols              = floor(W / cell_size)
local rows              = floor(H / cell_size)
local max_fire_strength = 10

local dirs              = { UP, LEFT, DOWN, RIGHT }

local CELL_TYPE_CURSOR  = "cursor"
local CELL_TYPE_ELEMENT = "element"


-- elements
local EMPTY, SAND, WATER, WOOD, FIRE, STEAM = 0, 1, 2, 3, 4, 5
local elements                              = {
    { id = SAND,  color = YELLOW },
    { id = WATER, color = BLUE },
    { id = WOOD,  color = BROWN },
    { id = FIRE,  color = RED,       palette = { RED, ORANGE, YELLOW } },
    { id = STEAM, color = LIGHT_GRAY },
}

-- utils
local function draw_cell(i, j, type, color)
    local x0 = (i - 1) * cell_size
    local y0 = (j - 1) * cell_size
    local x1 = x0 + cell_size - 1
    local y1 = y0 + cell_size - 1

    if type == CELL_TYPE_CURSOR then
        rect(x0, y0, x1, y1, color)
    elseif type == CELL_TYPE_ELEMENT then
        rect_fill(x0, y0, x1, y1, color)
    end
end

local function get_element_cell_color(i, j)
    local cell = grid[i][j]

    if cell == FIRE then
        local strength = fire_strength[i][j]

        if strength > max_fire_strength * 0.7 then
            return elements[FIRE].palette[1]
        elseif strength > max_fire_strength * 0.4 then
            return elements[FIRE].palette[2]
        else
            return elements[FIRE].palette[3]
        end
    else
        return elements[cell].color
    end
end

-- grid
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

local function update_fire(i, j)
    if fire_strength[i][j] <= 0 then
        grid[i][j] = EMPTY
    end

    for dx = -1, 1 do
        for dy = -1, 1 do
            local next_i = i + dx
            local next_j = j + dy

            if next_i >= 1 and next_i <= cols and next_j >= 1 and next_j <= rows then
                if grid[i + dx][j + dy] == WATER then
                    grid[i + dx][j + dy] = STEAM
                elseif grid[i + dx][j + dy] == WOOD then
                    grid[i + dx][j + dy] = FIRE
                    fire_strength[i + dx][j + dy] = max_fire_strength
                end
            end
        end
    end

    fire_strength[i][j] = fire_strength[i][j] - 1
end

local function update_steam(i, j)
    local choice = rnd({ -1, 1 })
    local next_i = i + choice

    if j < 2 then
        local random = rnd()
        if random < 0.02 then -- 2% chance of the steam cell to be converted into water in this frame
            grid[i][j] = WATER
        end
    end

    if next_i >= 1 and next_i <= cols and j - 1 >= 1 and grid[next_i][j - 1] == EMPTY then
        grid_swap(i, j, next_i, j - 1)
    end
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
            elseif particle == FIRE then
                update_fire(i, j)
            elseif particle == STEAM then
                update_steam(i, j)
            end
        end
    end
end

local function draw_grid()
    for i = 1, cols do
        for j = 1, rows do
            local particle = grid[i][j]
            if particle ~= 0 then
                draw_cell(i, j, CELL_TYPE_ELEMENT, get_element_cell_color(i, j))
            end
        end
    end
end

-- cursor
local function create_cursor()
    cursor = {
        i = floor(cols / 2),
        j = floor(rows / 2),
        selected_element = nil,
        draw = function(self)
            if self.selected_element == nil then
                draw_cell(self.i, self.j, CELL_TYPE_CURSOR, LAVENDER)
            else
                local color = elements[self.selected_element].color
                draw_cell(self.i, self.j, CELL_TYPE_ELEMENT, color)
            end
        end,
        _advance = function(self, move)
            -- move the cursor
            if move == UP then
                self.j = self.j - 1
            elseif move == LEFT then
                self.i = self.i - 1
            elseif move == DOWN then
                self.j = self.j + 1
            else
                self.i = self.i + 1
            end

            -- place particles
            if self.i < 1 then self.i = 1 end
            if self.i > cols then self.i = cols end
            if self.j < 1 then self.j = 1 end
            if self.j > rows then self.j = rows end

            if self.selected_element ~= nil and self.j < rows then
                if grid[self.i][self.j] == EMPTY then
                    grid[self.i][self.j] = self.selected_element
                end
            end
        end,
        update = function(self)
            if btnp(A) then
                if self.selected_element == nil then
                    self.selected_element = 1
                else
                    self.selected_element = (self.selected_element + 1) % (#elements + 1)
                    if self.selected_element == 0 then
                        self.selected_element = nil
                    end
                end
            elseif btnp(B) then
                self.selected_element = nil
            end

            for i = 1, #dirs do
                if btn(dirs[i]) then
                    self:_advance(dirs[i])
                    break
                end
            end
        end
    }
end

-- oasis callbacks
function Init()
    rnd(time())

    setup_grid(grid)
    setup_grid(fire_strength)
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
