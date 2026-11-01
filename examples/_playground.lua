local x = floor(W / 2)
local y = floor(H / 2)
local speed = 2
local patterns = { 0xae4, 0x4a40, 0xa400, 0xaee0, 0x4e40 }
local curr_pat = rnd(patterns)

function Update()
    if btnp(A) or btnp(B) then
        curr_pat = rnd(patterns)
    end

    if btn(UP) then
        y = y - speed
    end
    if btn(LEFT) then
        x = x - speed
    end
    if btn(DOWN) then
        y = y + speed
    end
    if btn(RIGHT) then
        x = x + speed
    end
end

function Draw()
    cls(BLACK)
    fillp(curr_pat)
    circ_fill(x, y, 20, 0xf8)
end
