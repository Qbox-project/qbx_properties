RegisterNetEvent('qbx-properties:server:Logout', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    QBCore.Player.Logout(src)
    TriggerClientEvent('qbx-multicharacter:client:chooseChar', src)
end)