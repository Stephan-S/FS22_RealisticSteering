--
-- RealisticSteeringGUI
-- V1.0.0.0
--
-- @author Stephan Schlosser
-- @date 11/01/2019

rsGui = {};

local rsGui_mt = Class(rsGui, ScreenElement);

function rsGui:new(target, custom_mt)
    local element = ScreenElement.new(target, rsGui_mt);
    element.returnScreenName = "";
    return element;	
end;

function rsGui:onOpen()
    rsGui:superClass().onOpen(self);
	FocusManager:setFocus(self.backButton);
end;

function rsGui:onClose()
    rsGui:superClass().onClose(self);
end;

function rsGui:onClickBack()
    rsGui:superClass().onClickBack(self);
	RealisticSteering:guiClosed();
end;

function rsGui:onClickOk()
    rsGui:superClass().onClickOk(self);
	RealisticSteering:settingsFromGui(self.steeringSpeed:getState(), self.steeringAngleLimit:getState(), self.resetForce:getState());
    self:onClickBack();
end;

function rsGui:onIngameMenuHelpTextChanged(element)
end;

function rsGui:onCreateRSGuiHeader(element)
	--element.text = "Realistic Steering"
    element:setTextInternal("Realistic Steering", false, true)
end;

function rsGui:onCreateSteeringSpeed(element)
    self.steeringSpeed = element;
	element.labelElement.text = g_i18n:getText('gui_rs_SteeringSpeed');
	element.toolTipText = g_i18n:getText('gui_rs_SteeringSpeedToolTip');
    local speeds = {};

    for i = 1, #RealisticSteering.steeringSpeedTexts, 1 do
        speeds[i] = RealisticSteering.steeringSpeedTexts[i];
    end;
	
    element:setTexts(speeds);
end;

function rsGui:setSteeringSpeed(indexSpeed)
    self.steeringSpeed:setState(indexSpeed, false);
end;

function rsGui:onCreateSteeringAngleLimit(element)
    self.steeringAngleLimit = element;
	element.labelElement.text = g_i18n:getText('gui_rs_SteeringAngleLimit');
	element.toolTipText = g_i18n:getText('gui_rs_SteeringAngleLimitToolTip');
    local angleLimits = {};

    for i = 1, #RealisticSteering.angleLimitTexts, 1 do
        angleLimits[i] = RealisticSteering.angleLimitTexts[i];
    end;	
	
    element:setTexts(angleLimits);
end;

function rsGui:setSteeringAngleLimit(indexAngleLimit)
    self.steeringAngleLimit:setState(indexAngleLimit, false);
end;

function rsGui:onCreateResetForce(element)
    self.resetForce = element;
	element.labelElement.text = g_i18n:getText('gui_rs_ResetForce');
	element.toolTipText = g_i18n:getText('gui_rs_ResetForceToolTip');
    local resetForces = {};

	for i = 1, #RealisticSteering.resetForceTexts, 1 do
        resetForces[i] = RealisticSteering.resetForceTexts[i];
    end;
	
    element:setTexts(resetForces);
end;

function rsGui:setResetForce(indexResetForces)
    self.resetForce:setState(indexResetForces, false);
end;

function rsGui:onClickResetButton()
    RealisticSteering:settingsResetGui();
end;