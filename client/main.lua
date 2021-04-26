ESX              = nil
local onDuty = false
local AnyDeliveriesLeft = false
local Deliverycount = 0
local DeliveriesMade = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

-- Draw Main Blip
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.PackagePickup)
	SetBlipSprite(blip, 501)
end)

-- Check main blip to start deliveries
Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do -- Wait for the user to load
		Wait(500)
	end

	while true do
		Citizen.Wait(500)
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'delivery' then
			local coords = GetEntityCoords(PlayerPedId())
			local markerlocation = Config.PackagePickup
			while #(GetEntityCoords(PlayerPedId()) - markerlocation) <= 1.0 do
				Citizen.Wait(0)
				if onDuty then
					ESX.Game.Utils.DrawText3D(markerlocation, '~b~Press ~y~[E]~b~ to stop delivering', 1, 0)
					if IsControlJustReleased(0, 51) then
						ESX.ShowNotification('You are now off duty as a delivery driver', false, true)
						onDuty = false
						AnyDeliveriesLeft = false
						DeliveriesMade = 0
						Deliverycount = 0
					end
				else
					ESX.Game.Utils.DrawText3D(markerlocation, '~b~Press ~y~[E]~b~ to start delivering', 1, 0)
					if IsControlJustReleased(0, 51) then
						onDuty = true
						AnyDeliveriesLeft = true
						DrawDeliveryBlips()
						ESX.ShowNotification('You are now on duty as a delivery driver', false, true)
						CreateVehicleFunction(Config.DeliveryVan, Config.DeliveryVanSpawn.x, Config.DeliveryVanSpawn.y, Config.DeliveryVanSpawn.z, Config.DeliveryVanSpawnHeading)
						ESX.ShowHelpNotification('Deliver ~y~' .. Deliverycount .. ' ~w~package(s) to the marked locations on your map!')
						TriggerServerEvent('PackageDelivery:NewDriver')
						TriggerServerEvent('PackageDelivery:GivePackages', Deliverycount)
					end
				end
			end
		end
	end
end)

-- Draw Delivery Markers if on duty
Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do -- Wait for the user to load
		Wait(500)
	end

	while true do
		Citizen.Wait(500)
		if onDuty and AnyDeliveriesLeft and ESX.PlayerData.job and ESX.PlayerData.job.name == 'delivery' then
			local coords = GetEntityCoords(PlayerPedId())
			for k,v in pairs(Config.DeliveryLocations) do
				local markerlocation = vector3(v.x, v.y, v.z)
				while #(GetEntityCoords(PlayerPedId()) - markerlocation) <= 1.0 do
					Citizen.Wait(0)
					ESX.Game.Utils.DrawText3D(markerlocation, '~b~Press ~y~[E]~b~ to deliver package', 1, 0)
					if IsControlJustReleased(0, 51) then
						DeliveriesMade = DeliveriesMade + 1
						TriggerServerEvent('PackageDelivery:PackageDelivered')
					end
				end
			end
		end
	end
end)

-- Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		-- Draw Main Office Marker
		DrawMarker(25, Config.PackagePickup.x, Config.PackagePickup.y, Config.PackagePickup.z - 0.98, 
		0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 155, false, true, 2, nil, nil, false)

		-- Draw delivery markers if on duty
		if onDuty and AnyDeliveriesLeft then
			for k,v in pairs(Config.DeliveryLocations) do
				DrawMarker(25, v.x, v.y, v.z - 0.98, 
				0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 155, false, true, 2, nil, nil, false)
			end
		end
	end
end)

-- Check how many deliveries are leftq
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if onDuty and DeliveriesMade == Deliverycount then
			AnyDeliveriesLeft = false
			ESX.ShowNotification('You have made all your deliveries! Head back to the office to clock out!')
		end
	end
end)

-- Events
RegisterNetEvent('PackageDelivery:NewDriverNotification')
AddEventHandler('PackageDelivery:NewDriverNotification', function(driverName)
	ESX.ShowNotification("~b~" .. driverName .. " ~w~is now delivering packages for ~y~PostOP!")
end)

RegisterNetEvent('PackageDelivery:PackageDeliveredNotification')
AddEventHandler('PackageDelivery:PackageDeliveredNotification', function(driverName)
	ESX.ShowNotification("~b~" .. driverName .. " ~w~has just delivered a package!")
end)

function CreateVehicleFunction(vehicleName, x, y, z, heading)
	--Get player 
	local playerPed = PlayerPedId()

	-- Request Model
	RequestModel(vehicleName)

	-- Wait for model to load
	while not HasModelLoaded(vehicleName) do
		Wait(500)
	end

	-- Create the vehicle
	local vehicle = CreateVehicle(vehicleName, x, y, z, heading, true, false)

	-- Warp Into
	TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
end

function DrawDeliveryBlips()
  	for _ in pairs(Config.DeliveryLocations) do Deliverycount = Deliverycount + 1 
	end

	for k,v in pairs(Config.DeliveryLocations) do
		if onDuty then
			print(Deliverycount)
			local markerlocation = vector3(v.x, v.y, v.z)
			local Deliveryblip = AddBlipForCoord(markerlocation)
			SetBlipSprite(Deliveryblip, 501)
			SetBlipColour(Deliveryblip, 5)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName('Delivery Location')
			EndTextCommandSetBlipName(Deliveryblip)
		end
	end
end