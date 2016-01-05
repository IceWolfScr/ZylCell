ZylcellVersion       = 0.02
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
  ToUpdate.VersionPath = "/IceWolfScr/ZylCell/Nasus/ZylCellNasus.version"
  ToUpdate.ScriptPath =  "/IceWolfScr/ZylCell/Nasus/ZylCellNasus.lua"
  ToUpdate.SavePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
  ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Msg("Updated from v"..OldVersion.." to "..NewVersion..". Please press F9 twice to reload.") end
  ToUpdate.CallbackNoUpdate = function(OldVersion) end
  ToUpdate.CallbackNewVersion = function(NewVersion) Msg("New version found v"..NewVersion..". Please wait until it's downloaded.") end
  ToUpdate.CallbackError = function(NewVersion) Msg("There was an error while updating.") end
  CScriptUpdate(ZylcellVersion, ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
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

----] My functions
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
----]

--] Damage and minion functions
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

----] Update Clases
-- }

class "CScriptUpdate"

function CScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
  if not ZylcellAutoUpdate then return end
  self.LocalVersion = LocalVersion
  self.Host = Host
  self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..random(99999999)
  self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..random(99999999)
  self.SavePath = SavePath
  self.CallbackUpdate = CallbackUpdate
  self.CallbackNoUpdate = CallbackNoUpdate
  self.CallbackNewVersion = CallbackNewVersion
  self.CallbackError = CallbackError
  self:CreateSocket(self.VersionPath)
  self.DownloadStatus = 'Connect to Server for VersionInfo'
  AddTickCallback(function() self:GetOnlineVersion() end)
  return self
end

function CScriptUpdate:print(str)
  print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function CScriptUpdate:CreateSocket(url)
  if not self.LuaSocket then
    self.LuaSocket = require("socket")
  else
    self.Socket:close()
    self.Socket = nil
    self.Size = nil
    self.RecvStarted = false
  end
  self.LuaSocket = require("socket")
  self.Socket = self.LuaSocket.tcp()
  self.Socket:settimeout(0, 'b')
  self.Socket:settimeout(99999999, 't')
  self.Socket:connect('sx-bol.eu', 80)
  self.Url = url
  self.Started = false
  self.LastPrint = ""
  self.File = ""
end

function CScriptUpdate:Base64Encode(data)
  local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  return ((data:gsub('.', function(x)
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r;
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

function CScriptUpdate:GetOnlineVersion()
  if self.GotScriptVersion then return end

  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
  if self.Status == 'timeout' and not self.Started then
    self.Started = true
    self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
  end
  if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
    self.RecvStarted = true
    self.DownloadStatus = 'Downloading VersionInfo (0%)'
  end

  self.File = self.File .. (self.Receive or self.Snipped)
  if self.File:find('</s'..'ize>') then
    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
    end
    if self.File:find('<scr'..'ipt>') then
      local _,ScriptFind = self.File:find('<scr'..'ipt>')
      local ScriptEnd = self.File:find('</scr'..'ipt>')
      if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
      local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
      self.DownloadStatus = 'Downloading VersionInfo ('..round(100/self.Size*DownloadedSize,2)..'%)'
    end
  end
  if self.File:find('</scr'..'ipt>') then
    self.DownloadStatus = 'Downloading VersionInfo (100%)'
    local a,b = self.File:find('\r\n\r\n')
    self.File = self.File:sub(a,-1)
    self.NewFile = ''
    for line,content in ipairs(self.File:split('\n')) do
      if content:len() > 5 then
        self.NewFile = self.NewFile .. content
      end
    end
    local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
    local ContentEnd, _ = self.File:find('</sc'..'ript>')
    if not ContentStart or not ContentEnd then
      if self.CallbackError and type(self.CallbackError) == 'function' then
        self.CallbackError()
      end
    else
      self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
      self.OnlineVersion = tonumber(self.OnlineVersion)
      if self.OnlineVersion and self.LocalVersion and self.OnlineVersion > self.LocalVersion then
        if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
          self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
        end
        self:CreateSocket(self.ScriptPath)
        self.DownloadStatus = 'Connect to Server for ScriptDownload'
        AddTickCallback(function() self:DownloadUpdate() end)
      else
        if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
          self.CallbackNoUpdate(self.LocalVersion)
        end
      end
    end
    self.GotScriptVersion = true
  end
end

function CScriptUpdate:DownloadUpdate()
  if self.GotCScriptUpdate then return end
  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
  if self.Status == 'timeout' and not self.Started then
    self.Started = true
    self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
  end
  if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
    self.RecvStarted = true
    self.DownloadStatus = 'Downloading Script (0%)'
  end

  self.File = self.File .. (self.Receive or self.Snipped)
  if self.File:find('</si'..'ze>') then
    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
    end
    if self.File:find('<scr'..'ipt>') then
      local _,ScriptFind = self.File:find('<scr'..'ipt>')
      local ScriptEnd = self.File:find('</scr'..'ipt>')
      if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
      local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
      self.DownloadStatus = 'Downloading Script ('..round(100/self.Size*DownloadedSize,2)..'%)'
    end
  end
  if self.File:find('</scr'..'ipt>') then
    self.DownloadStatus = 'Downloading Script (100%)'
    local a,b = self.File:find('\r\n\r\n')
    self.File = self.File:sub(a,-1)
    self.NewFile = ''
    for line,content in ipairs(self.File:split('\n')) do
      if content:len() > 5 then
        self.NewFile = self.NewFile .. content
      end
    end
    local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
    local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
    if not ContentStart or not ContentEnd then
      if self.CallbackError and type(self.CallbackError) == 'function' then
        self.CallbackError()
      end
    else
      local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
      local newf = newf:gsub('\r','')
      if newf:len() ~= self.Size then
        if self.CallbackError and type(self.CallbackError) == 'function' then
          self.CallbackError()
        end
        return
      end
      local newf = Base64Decode(newf)
      if type(load(newf)) ~= 'function' then
        if self.CallbackError and type(self.CallbackError) == 'function' then
          self.CallbackError()
        end
      else
        local f = io.open(self.SavePath,"w+b")
        f:write(newf)
        f:close()
        if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
          self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
        end
      end
    end
    self.GotCScriptUpdate = true
  end
end









-- }









----]



















     

































































