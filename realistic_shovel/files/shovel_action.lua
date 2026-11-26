-- This is a standalone internal action. POWERDIGGER is never wrapped or replaced.
local id = "REALISTIC_SHOVEL_DIG"
local projectile = "mods/realistic_shovel/files/projectile.xml"
local function is_shovel_cast()
    local entity = GetUpdatedEntityID()
    if not entity or entity == 0 then return false end
    if EntityHasTag(entity, "shovel") then return true end
    local player = EntityGetRootEntity(entity)
    if not player or player == 0 or not EntityHasTag(player, "player_unit") then return false end
    local inv = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
    if not inv then return false end
    local wand = ComponentGetValue2(inv, "mActiveItem")
    return wand and wand ~= 0 and EntityHasTag(wand, "shovel")
end
local function dig()
    -- Reflectors may inspect the action without a live caster.
    if reflecting then
        add_projectile(projectile)
        c.fire_rate_wait = c.fire_rate_wait + 1
        current_reload_time = current_reload_time - (ACTION_DRAW_RELOAD_TIME_INCREASE or 0) - 10
        return
    end
    if not is_shovel_cast() then return end
    if not GameHasFlagRun("realistic_shovel_021_cast") then
        GameAddFlagRun("realistic_shovel_021_cast")
        print("[Realistic Shovel 0.2.4] Exclusive action fired")
        GamePrint("Realistic Shovel: disparo exclusivo")
    end
    add_projectile(projectile)
    c.fire_rate_wait = c.fire_rate_wait + 1
    current_reload_time = current_reload_time - (ACTION_DRAW_RELOAD_TIME_INCREASE or 0) - 10
end
for _, a in ipairs(actions) do if a.id == id then return end end
table.insert(actions, {
    id = id,
    name = "$action_powerdigger",
    description = "Internal shovel action: loosens selected soft terrain.",
    sprite = "data/ui_gfx/gun_actions/powerdigger.png",
    sprite_unidentified = "data/ui_gfx/gun_actions/powerdigger_unidentified.png",
    type = ACTION_TYPE_PROJECTILE,
    spawn_level = "",
    spawn_probability = "",
    never_unlimited = true,
    price = 0,
    mana = 0,
    sound_loop_tag = "sound_digger",
    -- Intentionally omit related projectile metadata used by copy spells.
    action = dig,
})
