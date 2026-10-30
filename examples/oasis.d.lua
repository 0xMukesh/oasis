--- @meta oasis

-- GLOBAL CONSTANTS --
W = 256
H = 256
PI = 3.141592653589793

-- COLORS --
BLACK = 0
DARK_BLUE = 1
DARK_PURPLE = 2
DARK_GREEN = 3
BROWN = 4
DARK_GRAY = 5
LIGHT_GRAY = 6
WHITE = 7
RED = 8
ORANGE = 9
YELLOW = 10
GREEN = 11
BLUE = 12
LAVENDER = 13
PINK = 14
PEACH = 15

-- DRAW STATE --
--- @param color integer
function color(color) end

--- @param pattern? integer
--- @param transparent? boolean
function fillp(pattern, transparent) end

--- @param fps integer
function set_fps(fps) end

-- GRAPHICS --
--- @param x integer
--- @param y integer
--- @param color? integer
function pset(x, y, color) end

--- @param x integer
--- @param y integer
--- @return integer
function pget(x, y) end

--- @param color? integer
function cls(color) end

--- @param x0 integer
--- @param y0 integer
--- @param x1 integer
--- @param y1 integer
--- @param color? integer
function line(x0, y0, x1, y1, color) end

--- @param x0 integer
--- @param y0 integer
--- @param x1 integer
--- @param y1 integer
--- @param color? integer
function rect(x0, y0, x1, y1, color) end

--- @param x0 integer
--- @param y0 integer
--- @param x1 integer
--- @param y1 integer
--- @param color? integer
function rect_fill(x0, y0, x1, y1, color) end

--- @param x integer
--- @param y integer
--- @param r integer
--- @param color? integer
function circ(x, y, r, color) end

--- @param x integer
--- @param y integer
--- @param r integer
--- @param color? integer
function circ_fill(x, y, r, color) end

-- MATH --
--- @param x number
--- @param y number
--- @return number
function min(x, y) end

--- @param x number
--- @param y number
--- @return number
function max(x, y) end

--- @param x number
--- @param y number
--- @param z number
--- @return number
function mid(x, y, z) end

--- @param x number
--- @return number
function abs(x) end

--- @param x number
--- @return number
function floor(x) end

--- @param x number
--- @return number
function ceil(x) end

--- @param x number
--- @return number
function sin(x) end

--- @param x number
--- @return number
function cos(x) end

--- @param dx number
--- @param dy number
--- @return number
function atan2(dx, dy) end

--- @param value? integer|table
--- @return number
function rnd(value) end

--- @param seed integer
function srnd(seed) end

--- @param x number
--- @return number
function sqrt(x) end

--- @param x number
--- @return number
function sgn(x) end

--- @param x integer
--- @param y integer
--- @return integer
function band(x, y) end

--- @param x integer
--- @param y integer
--- @return integer
function bor(x, y) end

--- @param x integer
--- @param y integer
--- @return integer
function bxor(x, y) end

--- @param x integer
--- @param y integer
--- @return integer
function shl(x, y) end

--- @param x integer
--- @param y integer
--- @return integer
function lshr(x, y) end

--- @param x integer
--- @param y integer
--- @return integer
function ashr(x, y) end

--- @param x integer
--- @param y integer
--- @return integer
function rotl(x, y) end

--- @param x integer
--- @param y integer
--- @return integer
function rotr(x, y) end

-- UTILITIES --
--- @return integer
function time() end
