IsDecorating = false
local camera
local IsDisabledControlPressed = IsDisabledControlPressed
local SetCamCoord = SetCamCoord
local SetCamRot = SetCamRot
local GetCamCoord = GetCamCoord
local GetCamRot = GetCamRot
local GetHashKey = GetHashKey

local function freeCam()
    if IsDecorating then
        lib.showTextUI('BACKSPACE - Exit  \n SPACE - Up  \n LCTRL - Down  \n WHEELUP - Speedup  \n WHEELDOWN - Slowdown  \n E - Add Object')
        local cameraPosition = GetGameplayCamCoord()
        local cameraRotation = GetGameplayCamRot(2)
        local cameraFov = GetGameplayCamFov()
        camera = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', cameraPosition.x, cameraPosition.y, cameraPosition.z, cameraRotation.x, cameraRotation.y, cameraRotation.z, cameraFov, true, 2)
        CreateThread(function()
            local multiplier = 0.1
            while IsDecorating do
                cameraPosition = GetCamCoord(camera)
                cameraRotation = GetCamRot(camera, 2)
                local forwardX = -math.sin(math.rad(cameraRotation.z))
                local forwardY = math.cos(math.rad(cameraRotation.z))
                local rightX = math.cos(math.rad(cameraRotation.z))
                local rightY = math.sin(math.rad(cameraRotation.z))
                local upwardZ = math.sin(math.rad(cameraRotation.x))
                if IsDisabledControlPressed(0, 241) then
                    multiplier = multiplier + 0.01
                end
                if IsDisabledControlPressed(0, 242) then
                    multiplier = multiplier - 0.01
                end
                if multiplier < 0.01 then multiplier = 0.001 end
                if multiplier > 1.0 then multiplier = 1.0 end
                if IsDisabledControlPressed(0, 32) then
                    cameraPosition = cameraPosition + vector3(forwardX * multiplier, forwardY * multiplier, upwardZ * multiplier)
                end
                if IsDisabledControlPressed(0, 33) then
                    cameraPosition = cameraPosition - vector3(forwardX * multiplier, forwardY * multiplier, upwardZ * multiplier)
                end
                if IsDisabledControlPressed(0, 34) then
                    cameraPosition = cameraPosition - vector3(rightX * multiplier, rightY * multiplier, 0)
                end
                if IsDisabledControlPressed(0, 35) then
                    cameraPosition = cameraPosition + vector3(rightX * multiplier, rightY * multiplier, 0)
                end
                if IsDisabledControlPressed(0, 36) then
                    cameraPosition = cameraPosition - vector3(0, 0, multiplier)
                end
                if IsDisabledControlPressed(0, 203) then
                    cameraPosition = cameraPosition + vector3(0, 0, multiplier)
                end
                cameraRotation = cameraRotation - vector3(GetDisabledControlNormal(0, 272) * 5, 0, GetDisabledControlNormal(0, 270) * 5)
                SetCamCoord(camera, cameraPosition.x, cameraPosition.y, cameraPosition.z)
                SetCamRot(camera, math.min(math.max(cameraRotation.x, -89), 89), cameraRotation.y, cameraRotation.z, 2)
                Wait(0)
            end
        end)
    else
        lib.hideTextUI()
        DestroyCam(camera, false)
    end
    SetPlayerControl(cache.playerId, not IsDecorating, 0)
    RenderScriptCams(IsDecorating, true, 1000, true, true)
end

function ToggleDecorating()
    IsDecorating = not IsDecorating
    freeCam()
    while IsDecorating do
        Wait(0)
        if IsDisabledControlJustReleased(0, 202) then
            ToggleDecorating()
        end
        if IsDisabledControlJustReleased(0, 38) then
            lib.showContext('qbx_properties_decoratingMenu')
        end
    end
end

local decoratingOptions = {}
for k, v in pairs(Furniture) do
    local menuId = string.format('qbx_properties_decoratingMenu_%s', k)
    decoratingOptions[#decoratingOptions + 1] = {
        title = k,
        menu = menuId
    }

    local furnitureOptions = {}
    for i = 1, #v do
        local furniture = v[i]
        furnitureOptions[#furnitureOptions + 1] = {
            title = furniture.label,
            onSelect = function(args)
                print(args.object, args.label)
            end,
            image = string.format('nui://qbx_properties/screenshots/%s.png', furniture.object),
            args = {
                object = furniture.object,
                label = furniture.label
            }
        }
    end
    lib.registerContext({
        id = menuId,
        title = k,
        menu = 'qbx_properties_decoratingMenu',
        options = furnitureOptions
    })
end

lib.registerContext({
    id = 'qbx_properties_decoratingMenu',
    title = locale('menu.decorating_categories'),
    options = decoratingOptions
})

-- this command should not be used in production. Dev command only to create images of the objects put into the Furniture table.
-- RegisterCommand('screenshotfurniture', function()
--     local modelHash = GetHashKey('prop_ld_greenscreen_01')
--     lib.requestModel(modelHash, 5000)
--     local greenScreen = CreateObject(modelHash, -1894.99, -3357.08, 145.35, false, false, false)
--     SetModelAsNoLongerNeeded(modelHash)
--     FreezeEntityPosition(greenScreen, true)
--     CreateThread(function()
--         while DoesEntityExist(greenScreen) do
--             local forward, right, upVector, position = GetEntityMatrix(greenScreen)
--             SetEntityMatrix(greenScreen, forward.x, 20.0, forward.z, 20.0, right.y, right.z, upVector.x, upVector.y, 20.0, position.x, position.y, position.z)
--             Wait(0)
--         end
--     end)
--     DisableIdleCamera(true)
--     local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
--     RenderScriptCams(true, false, 0, false, false)
--     for _, v in pairs(Furniture) do
--         for i = 1, #v do
--             modelHash = GetHashKey(v[i].object)
--             lib.requestModel(modelHash, 5000)
--             local object = CreateObjectNoOffset(modelHash, -1899.83, -3340.52, 150.24, false, false, false)
--             SetModelAsNoLongerNeeded(modelHash)
--             FreezeEntityPosition(object, true)
--             local minDimension, maxDimension = GetModelDimensions(modelHash)
--             local modelSize = maxDimension - minDimension
--             local fov = math.min(math.max(modelSize.x, modelSize.y) / 0.35 * 10, 60)
--             local objectCoords = GetEntityCoords(object)
--             local objectForward = -GetEntityForwardVector(object) * 2
--             local center = vector3(objectCoords.x + (minDimension.x + maxDimension.x) / 2, objectCoords.y + (minDimension.y + maxDimension.y) / 2, objectCoords.z + (minDimension.z + maxDimension.z) / 2)
--             local cameraPosition = center + objectForward * 2 + vector3(1.5, -1, 1.5 * modelSize.z)
--             SetCamFov(cam, fov)
--             SetCamCoord(cam, cameraPosition.x, cameraPosition.y, cameraPosition.z)
--             PointCamAtCoord(cam, center.x, center.y, center.z)
--             TriggerServerEvent('screenshotFurniture', v[i].object)
--             Wait(1000)
--             DeleteEntity(object)
--         end
--     end
--     DestroyCam(cam, false)
--     RenderScriptCams(false, false, 0, false, false)
--     DisableIdleCamera(false)
--     DeleteEntity(greenScreen)
-- end)
