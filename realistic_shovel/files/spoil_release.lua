-- Release collected material using Noita's native death-spill mechanic.
local id=GetUpdatedEntityID()
local st={}
for _, c in ipairs(EntityGetComponentIncludingDisabled(id,"VariableStorageComponent") or {}) do
    st[ComponentGetValue2(c,"name")]=c
end
if not st.start_frame or not st.target_x or not st.target_y then return end
local started=ComponentGetValue2(st.start_frame,"value_int")
if started < 0 then return end
local frame=GameGetFrameNum()
if frame>=started and frame-started<4 then return end
local s=EntityGetFirstComponentIncludingDisabled(id,"MaterialSuckerComponent")
if s then EntitySetComponentIsEnabled(id,s,false) end
local dm=EntityGetFirstComponentIncludingDisabled(id,"DamageModelComponent")
if not dm then return end
local x,y=EntityGetTransform(id)
local tx=ComponentGetValue2(st.target_x,"value_float")
local ty=ComponentGetValue2(st.target_y,"value_float")
local n="unknown"
if s then
    local ok,v=pcall(ComponentGetValue2,s,"mAmountUsed")
    if ok and type(v)=="number" then n=v end
end
-- Recheck the destination in case moving material filled it during collection.
if RaytraceSurfaces(tx-2,ty,tx+2,ty) or RaytraceSurfaces(tx,ty-2,tx,ty+2) then
    local fx,fy=FindFreePositionForBody(tx,ty,0,-20,3)
    if type(fx)=="number" and type(fy)=="number"
       and (fx-tx)^2+(fy-ty)^2<=12^2 then
        tx,ty=fx,fy
    else
        -- No safe nearby alternative: return material at its original location.
        tx,ty=x,y
    end
end
EntitySetTransform(id,tx,ty)
-- Identify the dominant material BEFORE native spill. This is diagnostic only.
local main="unknown"
local ok,material_id=pcall(GetMaterialInventoryMainMaterial,id)
if ok and type(material_id)=="number" then
    if material_id==0 then main="empty" else
        local valid,name=pcall(CellFactory_GetName,material_id)
        if valid and type(name)=="string" then main=name end
    end
end
local kind="unknown"
if s then
    local mt=ComponentGetValue2(s,"material_type")
    local tag=ComponentGetValue2(s,"suck_tag")
    if mt==0 then kind="liquid" elseif tag=="[sand_other]" then kind="other_powder" else kind="ground_powder" end
end
local key="realistic_shovel_024_last_spill_"..kind
local last=tonumber(GlobalsGetValue(key,"-9999")) or -9999
if frame<last or frame-last>=30 then
    GlobalsSetValue(key,tostring(frame))
    print(string.format("[Realistic Shovel 0.2.4] Collector %d: %s; main=%s; native amount=%s; spill %.1f,%.1f -> %.1f,%.1f",id,kind,main,tostring(n),x,y,tx,ty))
end
-- Same mechanism as data/scripts/projectiles/vacuum_powder.lua.
-- Never manually create arbitrary particles or clear the inventory.
ComponentSetValue2(dm,"kill_now",true)
EntityInflictDamage(id,1000,"DAMAGE_PROJECTILE","","NONE",0,0)
