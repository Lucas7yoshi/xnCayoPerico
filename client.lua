local disableRadioInCP = false
local expandWorldLimits = true
local drawCayoBlip = true

local cayoOffset = vec(-5757.178, -6489.789, 0)
local toCayoA = vec(7200, -2000, -1000)
local toCayoB = vec(15000, 4000, 10000)
local toLSA = vec3((toCayoA.x + cayoOffset.x), (toCayoA.y + cayoOffset.y), toCayoA.z)
local toLSB = vec3((toCayoB.x + cayoOffset.x), (toCayoB.y + cayoOffset.y), toCayoB.z)
local inCayoPerico = false
local cam = nil
local cayoBlip = nil
local blipLocation = vec(11063, 908, 0)
local blipID = 765
local blipColour = 5
local blipText = "Cayo Perico"

function TogglePerico()
	local ped = PlayerPedId()
	local offset = inCayoPerico and -cayoOffset or cayoOffset
	if not DoesCamExist(cam) then
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 0, true, true)
		StopCamShaking(cam, true)
	end
	local veh = GetVehiclePedIsIn(ped)
	local entity = veh ~= 0 and veh or ped
	local coords = GetEntityCoords(entity)
	local velocity = GetEntityVelocity(entity)
	local heading = GetEntityHeading(entity)
	local seat = nil
	local camOffset = GetOffsetFromEntityInWorldCoords(entity, 20.0, 50.0, 5.0)
	SetCamCoord(cam, camOffset)
	PointCamAtCoord(cam, coords)
	if veh ~= 0 then
		seat = GetPedInVehicleSeat(veh, -1)
		if seat == ped then
			TaskVehicleTempAction(ped, entity, 23, 5000)
		end
	end
	DoScreenFadeOut(2000)
	Wait(2000)
	if inCayoPerico then
		DisableCayoPerico(false)
	else
		EnableCayoPerico(false)
	end
	DetachCam(cam)
	SetCamActive(cam, false)
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(cam, false)
	if seat == ped then
		SetEntityCoordsNoOffset(entity, coords + offset)
		SetEntityHeading(heading)
		SetEntityVelocity(entity, velocity)
	end
	SetGameplayCamRelativeHeading(0.0)
	Wait(1000)
	ClearPedTasks(ped)
	DoScreenFadeIn(2000)
	inCayoPerico = not inCayoPerico
	TriggerEvent("IsInCayoPerico", inCayoPerico)
	TriggerServerEvent("IsInCayoPerico", inCayoPerico)
end

function EnableCayoPerico(event)
	SetIslandHopperEnabled('HeistIsland', true)
	SetToggleMinimapHeistIsland(true)
	SetAiGlobalPathNodesType(true)
	SetScenarioGroupEnabled('Heist_Island_Peds', true)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
	SetDeepOceanScaler(0.0)
	CPWait = 0
	if drawCayoBlip then
		SetBlipHiddenOnLegend(cayoBlip, true)
		SetBlipAlpha(cayoBlip, 0)
	end
	if disableRadioInCP then
		SetAudioFlag('PlayerOnDLCHeist4Island', true)
	end
	if event then
		inCayoPerico = true
		TriggerEvent("IsInCayoPerico", true)
		TriggerServerEvent("IsInCayoPerico", true)
	end
end

function DisableCayoPerico(event)
	SetIslandHopperEnabled('HeistIsland', false)
	SetToggleMinimapHeistIsland(false)
	SetAiGlobalPathNodesType(false)
	SetScenarioGroupEnabled('Heist_Island_Peds', false)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', false, false)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', true, false)
	ResetDeepOceanScaler()
	CPWait = 1000
	if drawCayoBlip then
		SetBlipHiddenOnLegend(cayoBlip, false)
		SetBlipAlpha(cayoBlip, 255)
	end
	if disableRadioInCP then
		SetAudioFlag('PlayerOnDLCHeist4Island', false)
	end
	if event then
		inCayoPerico = false
		TriggerEvent("IsInCayoPerico", false)
		TriggerServerEvent("IsInCayoPerico", false)
	end
end

local CPWait = 1000
CreateThread(function()
	if drawCayoBlip then
		cayoBlip = AddBlipForCoord(blipLocation)
		SetBlipSprite(cayoBlip, blipID)
		SetBlipColour(cayoBlip, blipColour)
		SetBlipDisplay(cayoBlip, 3)
		AddTextEntry("xnCayoPerico_Blip", blipText)
		BeginTextCommandSetBlipName("xnCayoPerico_Blip")
		EndTextCommandSetBlipName(cayoBlip)
	end
	
	if expandWorldLimits then
		ExtendWorldBoundaryForPlayer(-12000, -12000, 0)
		ExtendWorldBoundaryForPlayer(12000, 12000, 0)
	end
	
	while true do
		Wait(CPWait)
		if inCayoPerico then
			SetRadarAsExteriorThisFrame()
			SetRadarAsInteriorThisFrame(`h4_fake_islandx`, vec(4700.0, -5145.0), 0, 0)
		end
	end
end)

CreateThread(function()	
	SetZoneEnabled(GetZoneFromNameId("PrLog"), false) -- Disables snow effect from the ungodly map above Cayo Perico
	while true do
		Wait(2000)
		local ped = PlayerPedId()
		if not inCayoPerico then
			if IsEntityInArea(ped, toCayoA, toCayoB) then
				TogglePerico()
			end
		else
			if not IsEntityInArea(ped, toLSA, toLSB) then
				TogglePerico()
			end
		end
	end
end)

RegisterNetEvent('EnableCayoPerico')
AddEventHandler('EnableCayoPerico', function()
    EnableCayoPerico(true)
end)

RegisterNetEvent('DisableCayoPerico')
AddEventHandler('DisableCayoPerico', function()
    DisableCayoPerico(true)
end)