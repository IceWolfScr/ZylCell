ZylcellVersion       = 0.01
ZylcellLoaded        = false
ZylcellLoadActivator = true
ZylcellLoadAwareness = true
ZylcellFixBugsplats  = false
ZylcellLoadEvade     = false
ZylcellAutoUpdate    = true

local min, max, cos, sin, pi, huge, ceil, floor, round, random, abs, deg, asin, acos = math.min, math.max, math.cos, math.sin, math.pi, math.huge, math.ceil, math.floor, math.round, math.random, math.abs, math.deg, math.asin, math.acos


--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player               = GetMyHero()
ZylcellConfig        = scriptConfig("ZylCell Loader", "zylcell")
stacks               = 0

--] called once when the script is loaded
function OnLoad()
  Update()
  DialogScreen()
  if (player.charName == "Nasus") then
    OnAfterLoad()
  else
    return
  end
end

--] Auto-Update

function Update()
  local ToUpdate = {}
  ToUpdate.UseHttps = true
  ToUpdate.Host = "raw.githubusercontent.com"
  ToUpdate.VersionPath = "/IceWolfScr/ZylCell/ZylCellNasus.version"
  ToUpdate.ScriptPath =  "/IceWolfScr/ZylCell/ZylCellNasus.lua"
  ToUpdate.SavePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
  ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Msg("Updated from v"..OldVersion.." to "..NewVersion..". Please press F9 twice to reload.") end
  ToUpdate.CallbackNoUpdate = function(OldVersion) end
  ToUpdate.CallbackNewVersion = function(NewVersion) Msg("New version found v"..NewVersion..". Please wait until it's downloaded.") end
  ToUpdate.CallbackError = function(NewVersion) Msg("There was an error while updating.") end
  CScriptUpdate(ScriptologyVersion,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
end
--]

function OnAfterLoad()
  InitMenu()
end


function DialogScreen()
  Msg("Loaded! (v"..ZylcellVersion..")")
  if (player.charName == "Nasus") then
    Msg("Welcome Nasus, how I can help you? Press SHIFT")
  else
    Msg("At this moment, only Nasus is supported, if you want more champions, please donate")
    Msg("This plugin is shut down for now")
  end
end

--] handles script logic, a pure high speed loop
function OnTick()
  if (ZylcellConfig.autofarm and player:CanUseSpell(_Q) == READY) then
    AutoFarm()
  end
end

--] Draw
function OnDraw()
  if (ZylcellConfig.drawCircle) then
    DrawCircle(myHero.x, myHero.y, myHero.z, 150, 0x3399FF)
    if (ZylcellConfig.AntiGank.antigankp) then
      DrawCircle(myHero.x, myHero.y, myHero.z, 3000, 0x111111)
      DrawGankProtection()
    end
  end
end
---] DrawGankProtection
function DrawGankProtection()
  if (GankProction() == true) then
    DrawText("[Warning Gank Protection]: Soneone trys to gank you! (enemys near you: "..EnemiesAround(player, 3000)..")", 18, 100, 100, 0xFFFF0000)
  end
end
--] Draw Hp Bar

--]

--] Msg
function Msg(x, skip)
  local text = "<font color=\"#000066\">[</font><font color=\"#302030\">ZylCell</font><font color=\"#000066\">]: </font>"
  for _=0, x:len() do
    text = text.."<font color=\"#FFFFFF\">"..x:sub(_,_).."</font>"
  end
  print(text)
end

--]

--] My functions
---] InitMenu
function InitMenu()
  ZylcellConfig:addParam("drawCircle", "Draw Circle", SCRIPT_PARAM_ONOFF, true)
  ZylcellConfig:addParam("autofarm", "Auto-Farmer", SCRIPT_PARAM_ONOFF, true)
  ZylcellConfig:addSubMenu("AntiGank", "AntiGank")
  ZylcellConfig.AntiGank:addParam("antigankp", "Anti-Gank Protection", SCRIPT_PARAM_ONOFF, true)
  ZylcellConfig.AntiGank:addParam("antigankn", "Number of enemy near you", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
end
---]

---] Anti-Gank
function EnemiesAround(Unit, range)
  local c=0
  if Unit == nil then return 0 end
  for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero ~= nil and hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end

function GankProction()
  if (ZylcellConfig.AntiGank.antigankp == true) then
    if (EnemiesAround(player, 3000) >= ZylcellConfig.AntiGank.antigankn) then
      return true
    end
  end
  return false
end
---]

function GetRealHealth(unit)
  return unit.health
end

function GetDmg(spell, source, target)
  local ADDmg  = getDmg("AD", minion, Nasus) + spell.level * 20 + 10 + stacks
end

function OnProcessSpell(object, spell)
  if spell.name == "Siphoning Strike" then

  end
end


--]

--] AutoFarm

function AutoFarm()
  enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC)
  enemyMinions:update()

  for index, minion in pairs(enemyMinions.objects) do
    if GetDistance(minion, player) <= 150 and (not minion.dead and minion.visible and minion.bTargetable) and GetRealHealth(minion) <= GetDmg(_Q, player, minion)  then
      CastSpell(_Q, player:Attack(minion))
    end
  end
end
--]
     













