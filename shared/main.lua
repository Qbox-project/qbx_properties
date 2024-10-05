local sharedConfig = require 'config.shared'

---@param propertyCoords vector3 | vector4
---@param offset vector3
---@return vector4
function CalculateOffsetCoords(propertyCoords, offset)
    return vec4(propertyCoords.x + offset.x, propertyCoords.y + offset.y, (propertyCoords.z - sharedConfig.shellUndergroundOffset) + offset.z, propertyCoords.w or 0.0)
end