--
-- Mod: RealisticSteering_Register
--
-- Author: Stephan
-- email: Stephan910@web.de
-- @Date: 11.01.2019
-- @Version: 1.0.0.0 

-- #############################################################################

source(Utils.getFilename("gui/rsGui.lua", g_currentModDirectory))
source(Utils.getFilename("RealisticSteering.lua", g_currentModDirectory))


RealisticSteering_Register = {};
RealisticSteering_Register.modDirectory = g_currentModDirectory;

local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
RealisticSteering_Register.version = getXMLString(modDesc, "modDesc.version");

if g_specializationManager:getSpecializationByName("RealisticSteering") == nil then

  g_specializationManager:addSpecialization("RealisticSteering", "RealisticSteering", Utils.getFilename("RealisticSteering.lua", g_currentModDirectory), nil)

  if RealisticSteering == nil then 
    print("ERROR: unable to add specialization 'RealisticSteering'")
  else 
    for vehicleType, typeDef in pairs(g_vehicleTypeManager.types) do
      if typeDef ~= nil and vehicleType ~= "locomotive" and vehicleType ~= "horse" then
        if SpecializationUtil.hasSpecialization(Motorized, typeDef.specializations) and SpecializationUtil.hasSpecialization(Drivable, typeDef.specializations) and SpecializationUtil.hasSpecialization(Enterable, typeDef.specializations) then 
            --print("INFO: attached specialization 'RealisticSteering' to vehicleType '" .. tostring(vehicleType) .. "'")
            g_vehicleTypeManager:addSpecialization(vehicleType, g_currentModName .. ".RealisticSteering")
        end 
      end 
    end   
  end 
end 

function RealisticSteering_Register:loadMap(name)
	print("--> loaded RealisticSteering version " .. self.version .. " (by Stephan) <--");
end;

function RealisticSteering_Register:deleteMap()
  
end;

function RealisticSteering_Register:keyEvent(unicode, sym, modifier, isDown)

end;

function RealisticSteering_Register:mouseEvent(posX, posY, isDown, isUp, button)

end;

function RealisticSteering_Register:update(dt)
	
end;

function RealisticSteering_Register:draw()
  
end;

addModEventListener(RealisticSteering_Register);