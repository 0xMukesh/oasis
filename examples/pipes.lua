-- inspo: https://github.com/pipeseroni/pipes.sh/blob/master/pipes.sh

local initial_num_pipes = 10
local same_dir_prob = 97

local pipes = {}
local palette = { RED, YELLOW, GREEN, DARK_GREEN, BLUE, LAVENDER, PINK, PEACH }
local UP, LEFT, DOWN, RIGHT = 0, 1, 2, 3
local dirs = { UP, LEFT, DOWN, RIGHT }

local function create_pipe()
    pipes[#pipes + 1] = {
        x = floor(rnd(W - 1)),
        y = floor(rnd(H - 1)),
        color = rnd(palette),
        dir = rnd(dirs),
        advance = function(self, dir)
            if dir == UP then
                self.y = self.y - 1
            elseif dir == LEFT then
                self.x = self.x - 1
            elseif dir == DOWN then
                self.y = self.y + 1
            else
                self.x = self.x + 1
            end
        end,
        update = function(self)
            local num = rnd(100)
            local turning_prob = (100 - same_dir_prob) / 2

            -- simple biased rng
            local left_prob_lower = same_dir_prob
            local left_prob_upper = same_dir_prob + turning_prob

            local right_prob_lower = same_dir_prob + turning_prob
            local right_prob_upper = same_dir_prob + (2 * turning_prob)

            if num > left_prob_lower and num <= left_prob_upper then
                self.dir = (self.dir + 1) % 4
            elseif num > right_prob_lower and num <= right_prob_upper then
                self.dir = (self.dir - 1) % 4
            end

            self:advance(self.dir)

            -- handle screen edges
            -- generate a new pipe "emerging" from one of the walls
            --    1
            -- 0     2
            --    3
            if self.x > W or self.x < 0 or self.y > H or self.y < 0 then
                local new_wall = floor(rnd(3))
                if new_wall == 0 then
                    self.x = 0
                    self.y = floor(rnd(H - 1))
                    self.dir = RIGHT
                elseif new_wall == 1 then
                    self.x = floor(rnd(W - 1))
                    self.y = 0
                    self.dir = DOWN
                elseif new_wall == 2 then
                    self.x = W - 1
                    self.y = floor(rnd(H - 1))
                    self.dir = LEFT
                elseif new_wall == 3 then
                    self.x = floor(rnd(W - 1))
                    self.y = H - 1
                    self.dir = UP
                end

                self.color = rnd(palette)
            end
        end,
        draw = function(self)
            pset(self.x, self.y, self.color)
        end
    }
end

function Init()
    srnd(time())

    for _ = 1, initial_num_pipes do
        create_pipe()
    end
end

function Update()
    for i = 1, initial_num_pipes do
        pipes[i]:update()
    end
end

function Draw()
    for i = 1, initial_num_pipes do
        pipes[i]:draw()
    end
end
