--
-- FastnightSettingsScreen
-- V1.0.0.0
--
-- @author apuehri
-- Thanks to sfcmod for the inspiration, and code elements 
-- @date 16/12/2021
--
-- Copyright (C) apuehri
-- V1.0.0.0 ..... LS19 first implementation

FastnightSettingsFrame = {};

local FastnightSettingsFrame_mt = Class(FastnightSettingsFrame, TabbedMenuFrameElement);

FastnightSettingsFrame.CONTROLS = {
    'gui_fn_onClickStartDayHour',
    'gui_fn_onClickStartDayMinute',
    'gui_fn_onClickDayTimeScale',
    'gui_fn_onClickAutoDayTimeScale',
    'gui_fn_onClickStartNightHour',
    'gui_fn_onClickStartNightMinute',
    'gui_fn_onClickNightTimeScale',
    'gui_fn_onClickAutoNightTimeScale',
	'gui_fn_onClickShowHelp',
	'gui_fn_onClickSave',
	
	'frameHeader',
    'boxLayout'
}

function FastnightSettingsFrame.new(i18n)
    local self = TabbedMenuFrameElement.new(nil, FastnightSettingsFrame_mt);

	self.i18n = i18n;

    self:registerControls(FastnightSettingsFrame.CONTROLS);

    return self;
end

function FastnightSettingsFrame:copyAttributes(src)
    FastnightSettingsFrame:superClass().copyAttributes(self, src)

    self.ui = src.ui
    self.i18n = src.i18n	
end

function FastnightSettingsFrame:initialize()
    self.backButtonInfo = {inputAction = InputAction.MENU_BACK};

    local elementBefore = self.gui_fn_onClickShowHelp
    local elementAfter = self.gui_fn_onClickStartDayHour
    FocusManager:linkElements(self.gui_fn_onClickSave, FocusManager.BOTTOM, elementBefore)
    FocusManager:linkElements(self.gui_fn_onClickSave, FocusManager.TOP, elementAfter)

end

function FastnightSettingsFrame:onFrameOpen()
    FastnightSettingsFrame:superClass().onFrameOpen(self)
	
	self.frameHeader.elements[2]:setText(g_i18n:getText("gui_fn_Setting"));

	-- Start Day Hour
	self.gui_fn_onClickStartDayHour.elements[4]:setText(g_i18n:getText("gui_fn_StartDayHour"));
	self.gui_fn_onClickStartDayHour.elements[6]:setText(g_i18n:getText("gui_fn_StartDayHourToolTip"));
    local elementText = {};

    for i = 1, #fastnight.hourSteps, 1 do
        elementText[i] = ""..tostring(fastnight.hourSteps[i]).. " h";
    end;
    self.gui_fn_onClickStartDayHour:setTexts(elementText);
	
	local index = fastnight.startDayHour + 1;
	if (index >= 1) and (index <= #fastnight.hourSteps) then
		self.gui_fn_onClickStartDayHour:setState(index, false);	
	end;

	-- Start Day Minute
	self.gui_fn_onClickStartDayMinute.elements[4]:setText(g_i18n:getText("gui_fn_StartDayMinute"));
	self.gui_fn_onClickStartDayMinute.elements[6]:setText(g_i18n:getText("gui_fn_StartDayMinuteToolTip"));
    elementText = {};

    for i = 1, #fastnight.minuteSteps, 1 do
        elementText[i] = ""..tostring(fastnight.minuteSteps[i]).. " m";
    end;
    self.gui_fn_onClickStartDayMinute:setTexts(elementText);
	
	index = 0;
	for i=1, #fastnight.minuteSteps, 1 do
		if (fastnight.minuteSteps[i] == fastnight.startDayMinute) then
			index = i;
			break
		end;
	end;
	if (index ~= 0) then
		self.gui_fn_onClickStartDayMinute:setState(index, false);
	end;
	
	-- Day TimeScale
	self.gui_fn_onClickDayTimeScale.elements[4]:setText(g_i18n:getText("gui_fn_DayTimeScale"));
	self.gui_fn_onClickDayTimeScale.elements[6]:setText(g_i18n:getText("gui_fn_DayTimeScaleToolTip"));
    elementText = {};

    for i = 1, #fastnight.timeScaling, 1 do
        elementText[i] = ""..tostring(fastnight.timeScaling[i]).. " x";
    end;
    self.gui_fn_onClickDayTimeScale:setTexts(elementText);
	
	index = 0;
	for i=1, #fastnight.timeScaling, 1 do
		if (fastnight.timeScaling[i] == fastnight.speedDay) then
			index = i;
			break
		end;
	end;
	if (index ~= 0) then
		self.gui_fn_onClickDayTimeScale:setState(index, false);
	end;
	
	-- Auto Day TimeScale
	self.gui_fn_onClickAutoDayTimeScale.elements[4]:setText(g_i18n:getText("gui_fn_AutoDayTimeScale"));
	self.gui_fn_onClickAutoDayTimeScale.elements[6]:setText(g_i18n:getText("gui_fn_AutoDayTimeScaleToolTip"));

	self.gui_fn_onClickAutoDayTimeScale:setIsChecked(fastnight.autoDayTimeScale);
	
	
	-- Start Night Hour
	self.gui_fn_onClickStartNightHour.elements[4]:setText(g_i18n:getText("gui_fn_StartNightHour"));
	self.gui_fn_onClickStartNightHour.elements[6]:setText(g_i18n:getText("gui_fn_StartNightHourToolTip"));
    elementText = {};

    for i = 1, #fastnight.hourSteps, 1 do
        elementText[i] = ""..tostring(fastnight.hourSteps[i]).. " h";
    end;
    self.gui_fn_onClickStartNightHour:setTexts(elementText);
	
	local index = fastnight.startNightHour + 1;
	if (index >= 1) and (index <= #fastnight.hourSteps) then
		self.gui_fn_onClickStartNightHour:setState(index, false);	
	end;

	-- Start Night Minute
	self.gui_fn_onClickStartNightMinute.elements[4]:setText(g_i18n:getText("gui_fn_StartNightMinute"));
	self.gui_fn_onClickStartNightMinute.elements[6]:setText(g_i18n:getText("gui_fn_StartNightMinuteToolTip"));
    elementText = {};

    for i = 1, #fastnight.minuteSteps, 1 do
        elementText[i] = ""..tostring(fastnight.minuteSteps[i]).. " m";
    end;
    self.gui_fn_onClickStartNightMinute:setTexts(elementText);
	
	index = 0;
	for i=1, #fastnight.minuteSteps, 1 do
		if (fastnight.minuteSteps[i] == fastnight.startNightMinute) then
			index = i;
			break
		end;
	end;
	if (index ~= 0) then
		self.gui_fn_onClickStartNightMinute:setState(index, false);
	end;
	
	-- Night TimeScale
	self.gui_fn_onClickNightTimeScale.elements[4]:setText(g_i18n:getText("gui_fn_NightTimeScale"));
	self.gui_fn_onClickNightTimeScale.elements[6]:setText(g_i18n:getText("gui_fn_NightTimeScaleToolTip"));
    elementText = {};

    for i = 1, #fastnight.timeScaling, 1 do
        elementText[i] = ""..tostring(fastnight.timeScaling[i]).. " x";
    end;
    self.gui_fn_onClickNightTimeScale:setTexts(elementText);
	
	index = 0;
	for i=1, #fastnight.timeScaling, 1 do
		if (fastnight.timeScaling[i] == fastnight.speedNight) then
			index = i;
			break
		end;
	end;
	if (index ~= 0) then
		self.gui_fn_onClickNightTimeScale:setState(index, false);
	end;
	
	-- Auto Night TimeScale
	self.gui_fn_onClickAutoNightTimeScale.elements[4]:setText(g_i18n:getText("gui_fn_AutoNightTimeScale"));
	self.gui_fn_onClickAutoNightTimeScale.elements[6]:setText(g_i18n:getText("gui_fn_AutoNightTimeScaleToolTip"));

	self.gui_fn_onClickAutoNightTimeScale:setIsChecked(fastnight.autoDayTimeScale);
	
	-- Show Help
	self.gui_fn_onClickShowHelp.elements[4]:setText(g_i18n:getText("gui_fn_ShowHelp"));
	self.gui_fn_onClickShowHelp.elements[6]:setText(g_i18n:getText("gui_fn_ShowHelpToolTip"));

	self.gui_fn_onClickShowHelp:setIsChecked(fastnight.showHelp);	
	
	-- Save Settings
	self.gui_fn_onClickSave.elements[1]:setText(g_i18n:getText("gui_fn_Save"));
    self.gui_fn_onClickSave.elements[1]:setImageFilename(nil, fastnight.dir .. 'icons/button_save.png');
    self.gui_fn_onClickSave.elements[1].icon.uvs = Overlay.DEFAULT_UVS;
	self.gui_fn_onClickSave.elements[3]:setText(g_i18n:getText("gui_fn_SaveToolTip"));

	if FocusManager:getFocusedElement() == nil then
		self:setSoundSuppressed(true)
		FocusManager:setFocus(self.boxLayout)
		self:setSoundSuppressed(false)
	end
	
end

function FastnightSettingsFrame:onClickSaveSettings()
	-- Start Day Hour
	local index = self.gui_fn_onClickStartDayHour:getState();
	fastnight.startDayHour = fastnight.hourSteps[index];
	
	-- Start Day Minute
	index = self.gui_fn_onClickStartDayMinute:getState();
	fastnight.startDayMinute = fastnight.minuteSteps[index];
	
	-- Day TimeScale
	index = self.gui_fn_onClickDayTimeScale:getState();
	fastnight.speedDay = fastnight.timeScaling[index];
	
	-- Auto Day TimeScale
	fastnight.autoDayTimeScale = self.gui_fn_onClickAutoDayTimeScale:getIsChecked();
	
	-- Start Night Hour
	index = self.gui_fn_onClickStartNightHour:getState();
	fastnight.startNightHour = fastnight.hourSteps[index];
	
	-- Start Night Minute
	index = self.gui_fn_onClickStartNightMinute:getState();
	fastnight.startNightMinute = fastnight.minuteSteps[index];
	
	-- Night TimeScale
	index = self.gui_fn_onClickNightTimeScale:getState();
	fastnight.speedNight = fastnight.timeScaling[index];
	
	-- Auto Night TimeScale
	fastnight.autoNightTimeScale = self.gui_fn_onClickAutoNightTimeScale:getIsChecked();
	
	-- Show Help
	fastnight.showHelp = self.gui_fn_onClickShowHelp:getIsChecked();
	
	if fastnight.debug then
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.startDayHour= " ..tostring(fastnight.startDayHour)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.startDayMinute= " ..tostring(fastnight.startDayMinute)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.speedDay= " ..tostring(fastnight.speedDay)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.autoDayTimeScale= " ..tostring(fastnight.autoDayTimeScale)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.startNightHour= " ..tostring(fastnight.startNightHour)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.startNightMinute= " ..tostring(fastnight.startNightMinute)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.speedNight= " ..tostring(fastnight.speedNight)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.autoNightTimeScale= " ..tostring(fastnight.autoNightTimeScale)..")");
		print("--- FastNight Debug ... fastnight:settingsFromGui(fastnight.showHelp= " ..tostring(fastnight.showHelp)..")");
	end;
	
	--Update Show Help
	for i=1, #fastnight.eventName, 1 do
		if (g_inputBinding.events[fastnight.eventName[i]] ~= nil) then
			g_inputBinding.events[fastnight.eventName[i]].displayIsVisible = fastnight.showHelp;
		end;	
	end;
	
	-- send data from gui to server
	fastnightMultiplayerUpdEvent.sendEvent();	
end
