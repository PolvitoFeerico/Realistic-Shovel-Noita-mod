-- Realistic Shovel 0.2.4 diagnostic: same projectile, direct local conversion.
local prefix = "[Realistic Shovel 0.2.4] "
local projectile = GetUpdatedEntityID()
local x, y = EntityGetTransform(projectile)
if type(x) ~= "number" or type(y) ~= "number" then
    print(prefix .. "ERROR: invalid projectile coordinates")
    return
end
-- A conservative 9x9 square, wholly within the original seven-pixel radius.
local left, top = math.floor(x + 0.5) - 4, math.floor(y + 0.5) - 4
local frame = GameGetFrameNum()
local key = "realistic_shovel_023_last_log"
local last = tonumber(GlobalsGetValue(key, "-9999")) or -9999
local verbose = frame < last or frame - last >= 30
if verbose then
    GlobalsSetValue(key, tostring(frame))
    print(prefix .. string.format("Projectile %d frame %d at %.2f,%.2f; rectangle %d,%d 9x9", projectile, frame, x, y, left, top))
end
local mappings = {
    {"sand_static", "soil", 9},
    {"sand_static_rainforest", "soil", 9},
    {"snow_static", "snow", 9},
    {"coal_static", "coal", 9},
    {"sand_static_bright", "soil", 9},
    {"sand_static_red", "soil", 9},
    {"rock_static_fungal", "fungisoil", 5},
    -- Last: newly weathered rock is not loosened until a later cast.
    {"rock_static_wet", "sand_static", 3},
}
local calls, failures, core_failures = 0, 0, 0
for index, pair in ipairs(mappings) do
    local ok, err = pcall(function()
        local a, b = CellFactory_GetType(pair[1]), CellFactory_GetType(pair[2])
        if type(a) ~= "number" or type(b) ~= "number" or a <= 0 or b <= 0 or a == b or CellFactory_GetName(a) ~= pair[1] or CellFactory_GetName(b) ~= pair[2] then
            error("invalid or mismatched material IDs: " .. tostring(a) .. "," .. tostring(b))
        end
        local size = pair[3]
        local sx, sy = left + (9-size)/2, top + (9-size)/2
        if verbose then print(prefix .. pair[1] .. " (" .. a .. ") -> " .. pair[2] .. " (" .. b .. "); area " .. size .. "x" .. size) end
        ConvertMaterialOnAreaInstantly(sx, sy, size, size, a, b, false, false)
    end)
    if ok then calls = calls + 1 else
        failures = failures + 1
        if index <= 4 then core_failures = core_failures + 1 end
        if verbose then print(prefix .. "ERROR " .. pair[1] .. ": " .. tostring(err)) end
    end
end
if verbose then print(prefix .. "Conversion calls returned: " .. calls .. "/" .. #mappings .. "; errors: " .. failures .. "; pixel count unknown") end
if not GameHasFlagRun("realistic_shovel_023_report") then
    GameAddFlagRun("realistic_shovel_023_report")
    GamePrint("Realistic Shovel: llamadas " .. calls .. "/" .. #mappings .. "; errores " .. failures .. " (ver logger.txt)")
end

-- Move actual loose terrain through a short-lived native material container.
-- A failed collection must never generate particles. The engine owns the inventory.
if core_failures ~= 0 then return end
local player = EntityGetClosestWithTag(x, y, "player_unit")
if not player or player == 0 then return end
local px, py = EntityGetTransform(player)
if not px or not py then return end
local dx, dy = px-x, py-y
if dx*dx+dy*dy > 40*40 then return end
-- Prefer open space to the side away from the excavation.
local side = dx >= 0 and 1 or -1
local candidates = {
    {px+side*12, py-8}, {px+side*8, py-12},
    {px-side*8, py-10}, {px, py-12}, {px, py-5}
}
local tx, ty
for _, cnd in ipairs(candidates) do
    local cx, cy = cnd[1], cnd[2]
    if not RaytraceSurfaces(px,py-4,cx,cy)
       and not RaytraceSurfaces(cx-2,cy,cx+2,cy)
       and not RaytraceSurfaces(cx,cy-2,cx,cy+2) then
        tx, ty = cx, cy
        break
    end
end
if not tx then
    if verbose then print(prefix.."No clear discharge position; skipped collection") end
    return
end
-- Native helper has no projectile, damage area, lifetime timeout or enemy tag.
local function start_collector(filename)
    local helper = EntityLoad("mods/realistic_shovel/files/" .. filename, x, y)
    if not helper or helper == 0 then
        if verbose then print(prefix.."ERROR: collector not loaded") end
        return
    end
    local setup = {}
    for _, comp in ipairs(EntityGetComponentIncludingDisabled(helper,"VariableStorageComponent") or {}) do
        setup[ComponentGetValue2(comp,"name")] = comp
    end
    if not setup.target_x or not setup.target_y or not setup.start_frame then
        -- Sucker is initially disabled, so this cannot discard collected material.
        EntityKill(helper)
        print(prefix.."ERROR: collector missing storage components")
        return
    end
    local sucker = EntityGetFirstComponentIncludingDisabled(helper,"MaterialSuckerComponent")
    if not sucker then
        EntityKill(helper)
        print(prefix.."ERROR: collector missing sucker")
        return
    end
    ComponentSetValue2(setup.target_x,"value_float",tx)
    ComponentSetValue2(setup.target_y,"value_float",ty)
    ComponentSetValue2(setup.start_frame,"value_int",frame)
    EntitySetComponentIsEnabled(helper,sucker,true)
end
-- Each class has its own inventory; keep native material IDs intact.
dofile_once("mods/realistic_shovel/config.lua")
start_collector("spoil_collector.xml")
if REALISTIC_SHOVEL_MOVE_LIQUIDS ~= false then
    start_collector("liquid_collector.xml")
end
if REALISTIC_SHOVEL_MOVE_OTHER_POWDERS ~= false then
    start_collector("other_powder_collector.xml")
end
