--#NoSimplerr#

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile("entities/sv_config.lua")
 
include('shared.lua')
include('entities/sv_config.lua')

util.AddNetworkString("Bailermenu")
util.AddNetworkString("Bailplayer")

function Spawn()
	--> Map Check
	if !NPC.Bailer.npcSpawns[game.GetMap()] then
		ErrorNoHalt("Missing car dealer spawn points for map: "..game.GetMap())
		return 
	end

	--> Loop Dealers
	for k,v in pairs(NPC.Bailer.npcSpawns[game.GetMap()]) do
		--> NPC
		local bailer = ents.Create("bailer_npc")
		bailer:SetPos(v.pos + Vector(0, 0, 10))
		bailer:SetAngles(v.ang)
		bailer:SetModel(v.mdl)
		bailer:SetHullType(HULL_HUMAN)
		bailer:SetHullSizeNormal()
		bailer:SetNPCState(NPC_STATE_SCRIPT)
		bailer:SetSolid(SOLID_BBOX)
		bailer:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
		bailer:SetUseType(SIMPLE_USE)
		bailer:Spawn()
		bailer:DropToFloor()
	end
end
hook.Add("InitPostEntity", "BailerSpawn", Spawn)

function ENT:Initialize()
	self:SetModel( "models/mossman.mdl" )
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE, CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)
    self:DropToFloor()    
end
  
function ENT:AcceptInput(name, activator, caller)
    if name == "Use" and IsValid(caller) then
        
		--> Variables
        local nbyPlayers = GetNearbyPlayers(activator) 
		
		if table.IsEmpty(nbyPlayers) then 
			DarkRP.notify(activator, 3, 4, "No nearby players")
			return
		end
		print(#nbyPlayers)
		net.Start("Bailermenu")
			net.WriteTable(nbyPlayers)
		net.Send(caller)
    end
end

function GetNearbyPlayers(ply)
	local nbyPlayers = {}
	local count = 0
	for k, v in pairs( player.GetAll() ) do	
		if v:isArrested() ~= nil then
			count = count+1
           	table.insert(nbyPlayers, count, v)
		end
	end
	return nbyPlayers
end

function Bailplayer()
	local ply_steamid = net.ReadString()
	local bailer_steamid = net.ReadString()
	local ply = player.GetBySteamID(ply_steamid)
	local bailer = player.GetBySteamID(bailer_steamid)

	if bailer:getDarkRPVar("money") > 10000 then
		ply:addMoney(-10000)
		ply:unArrest(bailer)
	else
		DarkRP.notify(bailer, 4, 4, "You don't have enough money to bail out this player")
	end

end
net.Receive("Bailplayer", Bailplayer)