local root = "mods/realistic_shovel/"
dofile(root .. "config.lua")
local restore = REALISTIC_SHOVEL_RESTORE == true
local new_id = "REALISTIC_SHOVEL_DIG"
local old_id = "POWERDIGGER"
local shovel_script = "mods/variaAddons/files/entities/specialty_wands/shovel/shovel_lua.lua"
local projectile_file = "data/entities/projectiles/deck/powerdigger.xml"
local new_projectile = root .. "files/projectile.xml"
local enabled = false
local registry_ok = nil
local function log(s) print("[Realistic Shovel 0.2.4] " .. tostring(s)) end

-- Copy the locally installed projectile; never modify the original file.
local function prepare_projectile()
    local xml = ModTextFileGetContent(projectile_file)
    if type(xml) ~= "string" or xml == "" then error("original projectile not found") end
    -- Require the expected explosion and component layout, and fail closed otherwise.
    local n
    xml, n = xml:gsub('(%f[%w_]hole_enabled%s*=%s*")[^"]*(")', '%10%2')
    if n ~= 1 then error("unexpected hole_enabled layout: " .. n) end
    xml = xml:gsub('(%f[%w_]is_digger%s*=%s*")[^"]*(")', '%10%2')
    xml = xml:gsub('(%f[%w_]collect_materials_to_shooter%s*=%s*")[^"]*(")', '%10%2')
    xml = xml:gsub('(%f[%w_]physics_throw_enabled%s*=%s*")[^"]*(")', '%10%2')
    xml = xml:gsub('(%f[%w_]max_durability_to_destroy%s*=%s*")[^"]*(")', '%10%2')
    xml = xml:gsub('(%f[%w_]shake_vegetation%s*=%s*")[^"]*(")', '%10%2')
    -- Preserve original lifetime, visual/audio effects, range and normal drill damage.
    -- Preserve the exclusive projectile identity; the Lua callback now handles conversion.
    xml = xml:gsub('value_string%s*=%s*"data/entities/projectiles/deck/powerdigger%.xml"', 'value_string="' .. new_projectile .. '"')
    local extra = [[
<LuaComponent execute_on_added="1" execute_every_n_frame="1" remove_after_executed="1" script_source_file="mods/realistic_shovel/files/projectile_diag.lua" />
]]
    xml, n = xml:gsub("</Entity>%s*$", function() return extra .. "\n</Entity>" end)
    if n ~= 1 then error("unexpected projectile root") end
    ModTextFileSetContent(new_projectile, xml)
    log("Exclusive projectile prepared; Lua conversion callback")
end

if restore then
    -- Keep the old custom action registered until saved shovels are restored.
    ModLuaFileAppend("data/scripts/gun/gun_actions.lua", root .. "files/shovel_action.lua")
    log("RESTORE MODE: no excavation patch will be installed")
else
    local ok, err = pcall(prepare_projectile)
    if ok then
        -- Standard append: a new action, no modifications to actions already present.
        ModLuaFileAppend("data/scripts/gun/gun_actions.lua", root .. "files/shovel_action.lua")
        enabled = true
        -- Virtual patch only: the Workshop file on disk stays untouched.
        local original = ModTextFileGetContent(shovel_script)
        if type(original) == "string" then
            -- Keep POWERDIGGER during spawning; migrate only after the exclusive ID is verified.
            -- Repair the original nil action_count loop, without editing the Workshop file.
            if original:match('AddGunActionPermanent%(%s*entity_id%s*,%s*"POWERDIGGER"%s*%)') then
                local patched, count = original:gsub('for%s+i%s*=%s*1%s*,%s*action_count%s+do%s+AddGunAction%(%s*entity_id%s*,%s*gun_action%s*%)%s+end', '')
                if count == 1 then
                    ModTextFileSetContent(shovel_script, patched)
                    log("Ordinary shovel generation: undefined loop repaired in memory")
                else
                    log("Generation script loop not matched; will migrate loaded shovels without altering it")
                end
            end
        else
            log("Varia shovel generation script not found; will migrate loaded shovels instead")
        end
    else
        log("Initialization failed; original shovel left unchanged: " .. tostring(err))
    end
end

-- On first in-world tick verify the engine actually registered our exclusive spell.
-- Existing cards are migrated in place (no capacity increase, no extra card).
local function verify_registry()
    if registry_ok ~= nil then return registry_ok end
    local ok, card = pcall(CreateItemActionEntity, new_id, 0, 0)
    registry_ok = false
    if ok and card and card ~= 0 then
        local comp = EntityGetFirstComponentIncludingDisabled(card, "ItemActionComponent")
        registry_ok = comp ~= nil and ComponentGetValue2(comp, "action_id") == new_id
        EntityKill(card)
    end
    log("Exclusive action registered: " .. tostring(registry_ok))
    if not registry_ok then GamePrint("Realistic Shovel: accion no registrada (ver logger.txt)") end
    return registry_ok
end

local function visit_shovel(shovel, from_id, to_id)
    if not EntityHasTag(shovel, "shovel") then return end
    for _, child in ipairs(EntityGetAllChildren(shovel) or {}) do
        local action = EntityGetFirstComponentIncludingDisabled(child, "ItemActionComponent")
        local item = EntityGetFirstComponentIncludingDisabled(child, "ItemComponent")
        if action and item and ComponentGetValue2(item, "permanently_attached") and ComponentGetValue2(action, "action_id") == from_id then
            ComponentSetValue2(action, "action_id", to_id)
            log("Shovel " .. shovel .. ": " .. from_id .. " -> " .. to_id)
            if not GameHasFlagRun("realistic_shovel_021_migration_" .. to_id) then
                GameAddFlagRun("realistic_shovel_021_migration_" .. to_id)
                GamePrint(restore and "Realistic Shovel: pala restaurada" or "Realistic Shovel: pala actualizada")
            end
        end
    end
end

local last_scan = -100
function OnWorldPostUpdate()
    if not enabled and not restore then return end
    local frame = GameGetFrameNum()
    if frame < last_scan then last_scan = -100 end
    if frame - last_scan < 15 then return end
    last_scan = frame
    if #(EntityGetWithTag("player_unit") or {}) == 0 then return end
    local ok = not restore and verify_registry()
    -- If the action failed registration, revert any generated/migrated cards to vanilla.
    local from_id, to_id = ok and old_id or new_id, ok and new_id or old_id
    for _, shovel in ipairs(EntityGetWithTag("shovel") or {}) do
        visit_shovel(shovel, from_id, to_id)
    end
end
