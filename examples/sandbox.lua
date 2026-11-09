local grid               = { {} }
local fire_strength      = { {} }
local cursor             = {}

local cell_size          = 4
local text_banner_height = 12
local cols               = floor(W / cell_size)
local rows               = floor((H - text_banner_height) / cell_size)
local max_fire_strength  = 10
local selected_element   = nil

local dirs               = { UP, LEFT, DOWN, RIGHT }

local CELL_TYPE_CURSOR   = "cursor"
local CELL_TYPE_ELEMENT  = "element"


-- elements
local EMPTY, SAND, WATER,
WOOD, WALL, FIRE,
STEAM, ACID    = 0, 1, 2, 3, 4, 5, 6, 7
local elements = {
    { id = SAND,  text = "SAND",  color = YELLOW, },
    { id = WATER, text = "WATER", color = BLUE },
    { id = WOOD,  text = "WOOD",  color = BROWN },
    { id = WALL,  text = "WALL",  color = DARK_GRAY },
    { id = FIRE,  text = "FIRE",  color = RED,       palette = { RED, ORANGE, YELLOW } },
    { id = STEAM, text = "STEAM", color = LIGHT_GRAY },
    { id = ACID,  text = "ACID",  color = GREEN },
}

-- utils
local function draw_cell(i, j, type, color, draw_frame)
    local x0 = (i - 1) * cell_size
    local y0 = text_banner_height + (j - 1) * cell_size
    local x1 = x0 + cell_size - 1
    local y1 = y0 + cell_size - 1

    if type == CELL_TYPE_CURSOR then
        rect(x0, y0, x1, y1, color)
    elseif type == CELL_TYPE_ELEMENT then
        if draw_frame then
            rect(x0, y0, x1, y1, WHITE)
            rect_fill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, color)
        else
            rect_fill(x0, y0, x1, y1, color)
        end
    end
end

local function get_element_cell_color(i, j)
    local cell = grid[i][j]

    if cell == EMPTY then
        return BLACK
    elseif cell == FIRE then
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
    -- if the cell just below is empty / water / acid, move down
    -- else, check the cells at the bottom left and bottom right
    if grid[i][j + 1] == EMPTY or grid[i][j + 1] == WATER or grid[i][i + 1] == ACID then
        grid_swap(i, j, i, j + 1)
        return
    end

    local choice = rnd({ -1, 1 })
    local next_i = i + choice

    if next_i >= 1 and next_i <= cols then
        if grid[next_i][j + 1] == EMPTY then
            grid_swap(i, j, next_i, j + 1)
        end
    end
end

local function update_water(i, j)
    -- if the cell just below is empty, move down
    -- else, check the cells to the left and right
    if grid[i][j + 1] == EMPTY then
        grid_swap(i, j, i, j + 1)
        return
    end

    local choice = rnd({ -1, 1 })
    local next_i = i + choice

    if next_i >= 1 and next_i <= cols then
        if grid[next_i][j] == EMPTY then
            grid_swap(i, j, next_i, j)
        end
    end
end

local function update_wood(i, j)
    -- remains where it was placed
    grid[i][j] = WOOD
end

local function update_wall(i, j)
    -- remains where it was placed
    grid[i][j] = WALL
end

local function update_fire(i, j)
    -- if the fire's strength is 0, change it to an empty cell
    -- otherwise, check its neighbours:
    --   1. if a neighbour is water, change that cell to steam
    --   2. if a neighbour is wood, change that cell to fire and set its fire strength to max
    -- at the end, reduce the fire strength of that specific cell
    if fire_strength[i][j] <= 0 then
        grid[i][j] = EMPTY
    end

    for dx = -1, 1 do
        for dy = -1, 1 do
            local next_i = i + dx
            local next_j = j + dy

            if next_i >= 1 and next_i <= cols and next_j >= 1 and next_j <= rows then
                if grid[next_i][next_j] == WATER then
                    grid[next_i][next_j] = STEAM
                elseif grid[next_i][next_j] == WOOD then
                    grid[next_i][next_j] = FIRE
                    fire_strength[next_i][next_j] = max_fire_strength
                end
            end
        end
    end

    fire_strength[i][j] = fire_strength[i][j] - 1
end

local function update_steam(i, j)
    -- if the cell above it is empty or contains water, move up
    -- if it reaches y = 2, condense and convert back into water with a probability of 2%
    local choice = rnd({ -1, 1 })
    local next_i = i + choice

    if j < 2 then
        local random = rnd()
        if random < 0.02 then
            grid[i][j] = WATER
        end
    else
        if next_i >= 1 and next_i <= cols and j - 1 >= 1 and j - 1 < rows then
            if grid[next_i][j - 1] == EMPTY or grid[next_i][j - 1] == WATER then
                grid_swap(i, j, next_i, j - 1)
            end
        end
    end
end

local function update_acid(i, j)
    -- pick a random wood cell from the neighbouring and react with it
    -- if there are no neighbouring wood cells, check the bottom cell
    -- else, move sideways
    local wood_neighbors = {}

    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local next_i = i + dx
                local next_j = j + dy

                if next_i >= 1 and next_i <= cols
                    and next_j >= 1 and next_j <= rows
                    and grid[next_i][next_j] == WOOD then
                    wood_neighbors[#wood_neighbors + 1] = {
                        next_i, next_j
                    }
                end
            end
        end
    end

    if #wood_neighbors > 0 then
        local target = rnd(wood_neighbors)
        grid[i][j] = EMPTY
        grid[target[1]][target[2]] = ACID
        return
    end

    if j < rows and grid[i][j + 1] == EMPTY then
        grid_swap(i, j, i, j + 1)
        return
    end

    local next_i = i + rnd({ -1, 1 })

    if next_i >= 1 and next_i <= cols
        and grid[next_i][j] == EMPTY then
        grid_swap(i, j, next_i, j)
    end
end

local function update_grid()
    for i = 1, cols do
        for j = rows, 1, -1 do
            local particle = grid[i][j]

            if particle == SAND then
                update_sand(i, j)
            elseif particle == WATER then
                update_water(i, j)
            elseif particle == WOOD then
                update_wood(i, j)
            elseif particle == WALL then
                update_wall(i, j)
            elseif particle == FIRE then
                update_fire(i, j)
            elseif particle == STEAM then
                update_steam(i, j)
            elseif particle == ACID then
                update_acid(i, j)
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
        draw = function(self)
            if selected_element == nil then
                draw_cell(self.i, self.j, CELL_TYPE_CURSOR, LAVENDER)
            else
                local color = elements[selected_element].color
                draw_cell(self.i, self.j, CELL_TYPE_ELEMENT, color, true)
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

            if selected_element ~= nil and self.j < rows then
                if grid[self.i][self.j] == EMPTY or
                    (selected_element == FIRE and grid[self.i][self.j] == WATER) then
                    grid[self.i][self.j] = selected_element
                end
            end
        end,
        update = function(self)
            -- hold a and b: clear out the all the elements in the way
            -- a: cycle through elements
            -- b: exit out of cycle

            if btn(A) and btn(B) then
                grid[self.i][self.j] = EMPTY
                selected_element = nil
            elseif btnp(A) then
                if selected_element == nil then
                    selected_element = 1
                else
                    selected_element = (selected_element + 1) % (#elements + 1)
                    if selected_element == 0 then
                        selected_element = nil
                    end
                end
            elseif btn(B) then
                selected_element = nil
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

-- text banner
local function draw_text_banner()
    local selected_element_text = ""
    if selected_element == nil then
        selected_element_text = "NIL"
    else
        selected_element_text = elements[selected_element].text
    end

    local text = "ELEMENT: " .. selected_element_text
    print(text, 5, 5, WHITE)
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
    draw_text_banner()
end
