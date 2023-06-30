--
-- FastnightSettingsScreen
-- V1.0.0.0
--
-- @author apuehri
-- Thanks to sfcmod for the inspiration, and code elements 
-- @date 16/12/2021
--
-- Copyright (C) apuehri
-- V1.0.0.0 ..... LS22 first implementation

FastnightSettingsScreen = {};
local FastnightSettingsScreen_mt = Class(FastnightSettingsScreen, TabbedMenu);

FastnightSettingsScreen.CONTROLS = {
	'pageSettingsFastnight',
}

function FastnightSettingsScreen.new(messageCenter, l18n, inputManager)
	local self = TabbedMenu.new(nil, FastnightSettingsScreen_mt, messageCenter, l18n, inputManager);

    self:registerControls(FastnightSettingsScreen.CONTROLS);	

	self.messageCenter = messageCenter;
	self.l18n = l18n;
	self.inputManager = g_inputBinding;

    return self;
end

function FastnightSettingsScreen:onGuiSetupFinished()
    FastnightSettingsScreen:superClass().onGuiSetupFinished(self);

    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack);

	self.pageSettingsFastnight:initialize();

	self:setupPages();
	self:setupMenuButtonInfo();		
end

function FastnightSettingsScreen:setupPages()
    local pages = {
        {self.pageSettingsFastnight, 'tab_fastnight.png'},		
	}

    for i, _page in ipairs(pages) do
        local page, icon = unpack(_page);
        self:registerPage(page, i);
        self:addPageTab(page, fastnight.dir .. 'icons/' .. icon);
    end
end

function FastnightSettingsScreen:setupMenuButtonInfo()
    local onButtonBackFunction = self.clickBackCallback;
	
    self.defaultMenuButtonInfo = {
		{inputAction = InputAction.MENU_BACK, text = g_i18n:getText("gui_fn_BtnBack"), callback = onButtonBackFunction},		
	}
    self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1];
	
    self.defaultButtonActionCallbacks = {
		[InputAction.MENU_BACK] = onButtonBackFunction,
	}
end

function FastnightSettingsScreen:exitMenu()
    self:changeScreen();
end