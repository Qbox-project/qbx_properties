RegisterNetEvent('qbx-properties:server:Logout', function()
    local src = source
    if not Player(src).state.isLoggedIn then return end
    exports.qbx_core:Logout(src)
    TriggerClientEvent('qbx-multicharacter:client:chooseChar', src)
end)