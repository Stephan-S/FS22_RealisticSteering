





RealisticSteering = {};
RealisticSteering.Version = "1.0.0.0";
RealisticSteering.config_changed = false;
local myName = "FS22_RealisticSteering";
RealisticSteering.actions             = { 'RealisticSteering_Toggle'}

RealisticSteering.steeringSpeeds = { 0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9 };
RealisticSteering.angleLimits = { 0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75};
RealisticSteering.resetForces = { 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 3.25, 3.5 };

RealisticSteering.steeringSpeedTexts = { "0 %", "5 %", "10 %", "15 %", "20 %", "25 %", "30 %", "35 %", "40 %", "45 %", "50 %", "55 %", "60 %", "65 %", "70 %", "75 %", "80 %", "85 %", "90 %"};
RealisticSteering.angleLimitTexts = { "0 %", "5 %", "10 %", "15 %", "20 %", "25 %", "30 %", "35 %", "40 %", "45 %", "50 %", "55 %", "60 %", "65 %", "70 %", "75 %" };
RealisticSteering.resetForceTexts = {  "50 %", "75 %", "100 %", "125 %", "150 %", "175 %", "200 %", "225 %", "250 %", "275 %", "300 %", "325 %", "350 %"};

RealisticSteering.steeringSpeed = 0.55;
RealisticSteering.angleLimit = 0.35;
RealisticSteering.resetForce = 2.5;

RealisticSteering.steeringSpeedIndex = 12;
RealisticSteering.angleLimitIndex = 8;
RealisticSteering.resetForceIndex = 6;

RealisticSteering.directory = g_currentModDirectory;
RealisticSteering.confDirectory = getUserProfileAppPath().. "modsSettings/FS22_RealisticSteering/"; 

function RealisticSteering:prerequisitesPresent(specializations)
    return true;
end;

function RealisticSteering:delete()	

end;

function RealisticSteering:loadMap(name)		
	--print("RealisticSteering load map");
	
	--gui
    RealisticSteering.gui = {};
    RealisticSteering.gui["rsSettingGui"] = rsGui:new();
	g_gui:loadGui(RealisticSteering.directory .. "gui/rsGui.xml", "rsGui", RealisticSteering.gui.rsSettingGui);	
	
	-- Save Configuration when saving savegame
	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, RealisticSteering.saveSavegame)

	--load settings:
	RealisticSteering:readConfig();
end;

function RealisticSteering.registerEventListeners(vehicleType)    
  for _,n in pairs( { "onUpdate", "onRegisterActionEvents", "onDelete" } ) do
    SpecializationUtil.registerEventListener(vehicleType, n, RealisticSteering)
  end 
end

function RealisticSteering:deleteMap()	
end;

function RealisticSteering:load(xmlFile)	
end;

function RealisticSteering.registerOverwrittenFunctions(vehicleType)
    --print("RealisticSteering registerOverwrittenFunctions");
    
    -- Only needed for action event for player
    --Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, RealisticSteering.registerActionEventsPlayer);

    -- Only needed for global action event 
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, RealisticSteering.registerActionEventsMenu);
end

-- only needed for global action event
function RealisticSteering:registerActionEventsMenu()
    --print("RealisticSteering registerActionEventsMenu")
    local erg, eventName = InputBinding.registerActionEvent(g_inputBinding, 'RealisticSteering_Settings',self, RealisticSteering.onOpenSettings ,false ,true ,false ,true)
    if erg then
         g_inputBinding.events[eventName].displayIsVisible = false
    end
end

function RealisticSteering:onOpenSettings(actionName, keyStatus, arg4, arg5, arg6)
	--print("Realistic Steering - open settings");
	if RealisticSteering.gui.rsSettingGui.isOpen then
		RealisticSteering.gui.rsSettingGui:onClickBack()
	elseif g_gui.currentGui == nil then
		g_gui:showGui("rsGui")
	end;
end;

function RealisticSteering:settingsFromGui(steeringSpeedState, steeringAngleLimitState, resetForceState)
	--print("Realistic Steering - received settings");
	RealisticSteering.steeringSpeed =  RealisticSteering.steeringSpeeds[steeringSpeedState];
	RealisticSteering.angleLimit = RealisticSteering.angleLimits[steeringAngleLimitState];
	RealisticSteering.resetForce = RealisticSteering.resetForces[resetForceState];
	
	RealisticSteering.steeringSpeedIndex = steeringSpeedState;
	RealisticSteering.angleLimitIndex = steeringAngleLimitState;
	RealisticSteering.resetForceIndex = resetForceState;
end;

function RealisticSteering:settingsResetGui()
	--print("Realistic Steering - reset gui received");
	RealisticSteering.gui.rsSettingGui:setSteeringSpeed(12);
	RealisticSteering.gui.rsSettingGui:setSteeringAngleLimit(8);
	RealisticSteering.gui.rsSettingGui:setResetForce(6);
end;

function RealisticSteering:guiClosed()
	RealisticSteering.gui.rsSettingGui:setSteeringSpeed(RealisticSteering.steeringSpeedIndex);
	RealisticSteering.gui.rsSettingGui:setSteeringAngleLimit(RealisticSteering.angleLimitIndex);
	RealisticSteering.gui.rsSettingGui:setResetForce(RealisticSteering.resetForceIndex);
end;
 

function RealisticSteering:onRegisterActionEvents(isSelected, isOnActiveVehicle)   
	-- continue on client side only
	if not self.isClient then
		return
	end
  
	-- only in active vehicle
	if isOnActiveVehicle then
		-- we could have more than one event, so prepare a table to store them  
		if self.rsActionEvents == nil then 
		  self.rsActionEvents = {}
		else  
		  self:clearActionEventsTable( self.rsActionEvents )
		end 

		-- attach our actions
		for _ ,actionName in pairs(RealisticSteering.actions) do
			local toggleButton = false;
			--local __, eventName = InputBinding.registerActionEvent(g_inputBinding, actionName, self, RealisticSteering.onActionCall, toggleButton ,true ,false ,true)
			local __, eventName = self:addActionEvent(self.rsActionEvents, actionName, self, RealisticSteering.onActionCall, toggleButton ,true, false ,true ,nil)
			
			g_inputBinding:setActionEventTextVisibility(eventName, false)
		end	
	end
end

function RealisticSteering:onActionCall(actionName)	
	if actionName == "RealisticSteering_Toggle" then
		if self.realisticSteering ~= nil then
			if self.realisticSteering.isActive == false then
				self.realisticSteering.isActive = true;
			else
				self.realisticSteering.isActive = false;
				self.maxRotTime = self.realisticSteering.maxRotTimeSaved;
				self.minRotTime = self.realisticSteering.minRotTimeSaved;
			end;
					
		end;
	end;
end

function RealisticSteering:onLeave()
end;

function RealisticSteering:onDelete()
	--RealisticSteering:writeConfig();
end;

function RealisticSteering:saveSavegame()
	RealisticSteering:writeConfig();
end;

function RealisticSteering:newMouseEvent(superFunc,posX, posY, isDown, isUp, button)
end;

function RealisticSteering:mouseEvent(posX, posY, isDown, isUp, button)	
end; 

function RealisticSteering:keyEvent(unicode, sym, modifier, isDown) 	
end; 

function RealisticSteering:RealisticSteering_init()	
end;

function RealisticSteering:onUpdate(dt)
	if self.RealisticSteeringModuleInitialized == nil then
		if self.spec_drivable ~= nil then
			self.realisticSteering = {};
			self.realisticSteering.maxDeltaSpeed = 0;
			self.realisticSteering.minDeltaSpeed = 50;
			self.realisticSteering.axisSide = self.spec_drivable.axisSide;
			
			self.realisticSteering.maxRotTimeSaved = self.maxRotTime;
			self.realisticSteering.minRotTimeSaved = self.minRotTime;
			self.realisticSteering.maxDeltaRot = 1;
			self.realisticSteering.minDeltaRot = 0.65;
			
			self.realisticSteering.isActive = true;
			self.RealisticSteeringModuleInitialized = true;	
						
		end;
	end;	
	
	
	if self == g_currentMission.controlledVehicle and self.realisticSteering.isActive == true and (self.getIsAIActive == nil or not self:getIsAIActive()) then
		local speed = self:getLastSpeed();
		local deltaPercent = math.min((math.abs(speed) / (self.realisticSteering.minDeltaSpeed - self.realisticSteering.maxDeltaSpeed)),1.0);
		local deltaMinus = deltaPercent * RealisticSteering.steeringSpeed;
		
		local curDelta = self.spec_drivable.axisSide - self.realisticSteering.axisSide;
		curDelta = curDelta * (1 - deltaMinus);

		if (self.spec_drivable.axisSide > 0 and curDelta < 0) or (self.spec_drivable.axisSide < 0 and curDelta > 0) then
			curDelta = curDelta * RealisticSteering.resetForce;
		end;
		
		local MinusRot = deltaPercent * RealisticSteering.angleLimit;
		self.maxRotTime = self.realisticSteering.maxRotTimeSaved * (1 - MinusRot);
		self.minRotTime = self.realisticSteering.minRotTimeSaved * (1 - MinusRot);		
		
		self.spec_drivable.axisSide = self.realisticSteering.axisSide + curDelta;		
		self.realisticSteering.axisSide = self.spec_drivable.axisSide;
	end;
end;

function RealisticSteering:draw()
end; 

function RealisticSteering:angleBetween(vec1, vec2)

	local scalarproduct_top = vec1.x * vec2.x + vec1.z * vec2.z;
	local scalarproduct_down = math.sqrt(vec1.x * vec1.x + vec1.z*vec1.z) * math.sqrt(vec2.x * vec2.x + vec2.z*vec2.z)
	local scalarproduct = scalarproduct_top / scalarproduct_down;

	return math.deg(math.acos(scalarproduct));
end

function RealisticSteering:writeConfig()
	-- skip on dedicated servers
	if g_dedicatedServerInfo ~= nil then
		return
	end

	createFolder(getUserProfileAppPath().. "modsSettings/");
	createFolder(RealisticSteering.confDirectory);

	local file = RealisticSteering.confDirectory..myName..".xml"
	local xml
	local groupNameTag
	local group
	xml = createXMLFile("FS22_RealisticSteering_XML", file, "FS22_RealisticSteeringSettings");		

		if RealisticSteering ~= nil then  
					
			setXMLInt(xml,  "FS22_RealisticSteeringSettings.steeringSpeed(0)#value", RealisticSteering.steeringSpeedIndex);
			setXMLInt(xml,  "FS22_RealisticSteeringSettings.angleLimit(0)#value", RealisticSteering.angleLimitIndex);	
			setXMLInt(xml,  "FS22_RealisticSteeringSettings.resetForce(0)#value", RealisticSteering.resetForceIndex);			
			
		end;
	
	saveXMLFile(xml)
end

function RealisticSteering:readConfig()
	-- skip on dedicated servers
	if g_dedicatedServerInfo ~= nil then
		return
	end

	local file = RealisticSteering.confDirectory..myName..".xml"
	local xml
	if not fileExists(file) then
		RealisticSteering:writeConfig()
	else
		-- load existing XML file
		xml = loadXMLFile("FS22_RealisticSteering_XML", file, "FS22_RealisticSteeringSettings");
		
		if RealisticSteering ~= nil then  
			RealisticSteering.steeringSpeedIndex = getXMLInt(xml,  "FS22_RealisticSteeringSettings.steeringSpeed(0)#value");
			RealisticSteering.angleLimitIndex = getXMLInt(xml,  "FS22_RealisticSteeringSettings.angleLimit(0)#value");
			RealisticSteering.resetForceIndex = getXMLInt(xml,  "FS22_RealisticSteeringSettings.resetForce(0)#value");
			
			RealisticSteering.steeringSpeed =  RealisticSteering.steeringSpeeds[RealisticSteering.steeringSpeedIndex];
			RealisticSteering.angleLimit = RealisticSteering.angleLimits[RealisticSteering.angleLimitIndex];
			RealisticSteering.resetForce = RealisticSteering.resetForces[RealisticSteering.resetForceIndex];

			RealisticSteering.gui.rsSettingGui:setSteeringSpeed(RealisticSteering.steeringSpeedIndex);
			RealisticSteering.gui.rsSettingGui:setSteeringAngleLimit(RealisticSteering.angleLimitIndex);
			RealisticSteering.gui.rsSettingGui:setResetForce(RealisticSteering.resetForceIndex);
		else
			print("RealisticSteering: Error loading settings - ResetSteering == nil");
		end
	end;
end


addModEventListener(RealisticSteering);
