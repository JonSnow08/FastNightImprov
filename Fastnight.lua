--
-- Fastnight
-- V1.0.1.0
--
-- @author apuehri
-- @date 28/09/2022
--
-- Copyright (C) apuehri
-- V1.0.1.0 ..... LS22 first implementation
-- V1.0.1.0 ..... Fix: Time is not loaded correctly at game start

fastnight = {};
fastnight.Version = "1.0.1.0";
fastnight.debug = false;
fastnight.dir = g_currentModDirectory;
fastnight.timeScaling = {1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;20;25;30;35;40;50;60;70;80;90;100;120;140;160;180;200;220;240;260;280;300;350;400;450;500;550;600;650;700;750;800;};
fastnight.hourSteps = {0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;};
fastnight.minuteSteps = {0;10;20;30;40;50;};

source(fastnight.dir .. 'gui/FastnightSettingScreen.lua');
source(fastnight.dir .. 'gui/FastnightSettingsFrame.lua'); 

function fastnight.prerequisitesPresent(specializations)
    return true;
end;

function fastnight:loadMap(name)
	print("--- loading FastNight V".. fastnight.Version .. " (c) by aPuehri ---")
    -- Only needed for action event for player
    Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, fastnight.registerActionEventsPlayer);
	Player.removeActionEvents = Utils.appendedFunction(Player.removeActionEvents, fastnight.removeActionEventsPlayer);		
		
	-- SaveSettings
	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, fastnight.saveSettings);		
		
	--initialize
	fastnight.autoDayTimeScale = true;
	fastnight.startDayHour = 6;
	fastnight.startDayMinute = 0;
	fastnight.speedDay = 3;	
	fastnight.autoNightTimeScale = true;
	fastnight.startNightHour = 22;
	fastnight.startNightMinute = 0;
	fastnight.speedNight = 80;
	fastnight.manScaling = 0;
	fastnight.showHelp = true;
	fastnight.eventName = {};
	
	--gui
	local fastnightSettingFrame = FastnightSettingsFrame.new(g_i18n);
	
	fastnight.gui = FastnightSettingsScreen.new(g_messageCenter, g_i18n, g_inputBinding);

	g_gui:loadGui(fastnight.dir .. 'gui/FastnightSettingsFrame.xml', 'FastnightSettingsFrame', fastnightSettingFrame, true);
    g_gui:loadGui(fastnight.dir .. "gui/FastnightSettingScreen.xml", "FastnightSettingsScreen", fastnight.gui);
	
	--load Savegame
	local savegameIndex = g_currentMission.missionInfo.savegameIndex;
	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory;
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), savegameIndex);
	end;
	
	if g_currentMission:getIsServer() then
		if fileExists(savegameFolderPath .. '/careerSavegame.xml') then
			local key = "fastnight";
			if fileExists(savegameFolderPath .. '/fastnight.xml') then
				local xmlFile = loadXMLFile("fastnight", savegameFolderPath .. "/fastnight.xml", key);

				-- AutoDayTimeScale
				fastnight.autoDayTimeScale = Utils.getNoNil(getXMLBool(xmlFile, key.."#autoDayTimeScale"), true);
				
				--startDayHour
				local startDayHour = getXMLInt(xmlFile, key.."#startDayHour");
				if startDayHour ~= nil then
					if startDayHour >= 0 and startDayHour <= fastnight.startNightHour then
						fastnight.startDayHour = startDayHour;
					end;
				end;			

				--startDayMinute
				local startDayMinute = getXMLInt(xmlFile, key.."#startDayMinute");
				if startDayMinute ~= nil then
					if startDayMinute >= 0 and startDayMinute <= 59 then
						fastnight.startDayMinute = startDayMinute;
					end;
				end;	

				--speedDay
				local speedDay = getXMLInt(xmlFile, key.."#speedDay");
				if speedDay ~= nil then
					if speedDay >= 1 and speedDay <= 800 then
						fastnight.speedDay = speedDay;
					end;
				end;	

				-- AutoNightTimeScale
				fastnight.autoNightTimeScale = Utils.getNoNil(getXMLBool(xmlFile, key.."#autoNightTimeScale"), true);			
				
				--startNightHour
				local startNightHour = getXMLInt(xmlFile, key.."#startNightHour");
				if startNightHour ~= nil then
					if startNightHour > startDayHour and startNightHour <= 24 then
						fastnight.startNightHour = startNightHour;
					end;
				end;			

				--startNightMinute
				local startNightMinute = getXMLInt(xmlFile, key.."#startNightMinute");
				if startNightMinute ~= nil then
					if startNightMinute >= 0 and startNightMinute <= 59 then
						fastnight.startNightMinute = startNightMinute;
					end;
				end;	

				--speedNight
				local speedNight = getXMLInt(xmlFile, key.."#speedNight");
				if speedNight ~= nil then
					if speedNight >= 1 and speedNight <= 800 then
						fastnight.speedNight = speedNight;
					end;
				end;			
				
				-- ShowHelp
				fastnight.showHelp = Utils.getNoNil(getXMLBool(xmlFile, key.."#showHelp"), true);			
				
				delete(xmlFile);
			end;
		end;
	end;

	-- set fastnight.manScaling
	fastnight.manScaling = g_currentMission.missionInfo.timeScale;
	
end;

function fastnight:loadSavegame() 
end;

function fastnight:registerActionEventsPlayer()
	-- FastNight Minus
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'fastnight_Minus',self, fastnight.actionFastnight_Minus ,false ,true ,false ,true)
	if result then
		table.insert(fastnight.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = fastnight.showHelp;
    end
	-- FastNight Plus	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'fastnight_Plus',self, fastnight.actionFastnight_Plus ,false ,true ,false ,true)
	if result then
        table.insert(fastnight.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = fastnight.showHelp;
    end
	-- FastNight Setting	
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'fastnight_Setting',self, fastnight.actionFastnight_Setting ,false ,true ,false ,true)
	if result then
		table.insert(fastnight.eventName, eventName);
        g_inputBinding.events[eventName].displayIsVisible = fastnight.showHelp;
    end
	if fastnight.debug then
		print("--- FastNight Debug ... fastnight:registerActionEventsPlayer(fastnight.eventName)");
		DebugUtil.printTableRecursively(fastnight.eventName,"----",0,1)
	end;	
end;

function fastnight:removeActionEventsPlayer()
	fastnight.eventName = {};
	if fastnight.debug then
		print("--- FastNight Debug ... fastnight:removeActionEventsPlayer(fastnight.eventName)");
		DebugUtil.printTableRecursively(fastnight.eventName,"----",0,1)
	end;
end;

function fastnight:mouseEvent(posX, posY, isDown, isUp, button)
end;

function fastnight:keyEvent(unicode, sym, modifier, isDown)
end;

function fastnight:update(dt)
	-- Auto scaling Day / Night
	if fastnight.autoDayTimeScale then
		if (math.abs(g_currentMission.environment.currentHour) == math.abs(fastnight.startDayHour)) and (math.abs(g_currentMission.environment.currentMinute) == math.abs(fastnight.startDayMinute)) then 
			g_currentMission:setTimeScale(fastnight.speedDay);
			fastnight.manScaling = fastnight.speedDay;
		end;
	end;
	if fastnight.autoNightTimeScale then	
		if (math.abs(g_currentMission.environment.currentHour) == math.abs(fastnight.startNightHour)) and (math.abs(g_currentMission.environment.currentMinute) == math.abs(fastnight.startNightMinute)) then
			g_currentMission:setTimeScale(fastnight.speedNight);
			fastnight.manScaling = fastnight.speedNight;
		end;
	end;
end;

function fastnight:draw()   
end;

function fastnight:saveSavegame() 
end;

function fastnight:delete()
end;

function fastnight:deleteMap()
end;

function fastnight:saveSettings()
	if fastnight.debug then
		print("--- FastNight Debug ... fastnight:saveSettings -- Settings will be saved");
	end;
	local savegameIndex = g_currentMission.missionInfo.savegameIndex;
	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory;
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), savegameIndex);
		if fastnight.debug then
			print("--- FastNight Debug ... fastnight:saveSettings(savegameFolderPath= " ..tostring(savegameFolderPath)..")");
		end;		
	end;
	
	local key = "fastnight";
	local xmlFile = createXMLFile("fastnight", savegameFolderPath .. "/fastnight.xml", key);
	
	-- AutoDayTimeScale
	setXMLBool(xmlFile, key .. "#autoDayTimeScale",fastnight.autoDayTimeScale);
	--startDayHour		
	setXMLInt(xmlFile, key .. "#startDayHour",fastnight.startDayHour);
	--startDayMinute		
	setXMLInt(xmlFile, key .. "#startDayMinute",fastnight.startDayMinute);
	--speedDay		
	setXMLInt(xmlFile, key .. "#speedDay",fastnight.speedDay);
	-- AutoDayTimeScale
	setXMLBool(xmlFile, key .. "#autoNightTimeScale",fastnight.autoNightTimeScale);		
	--startNightHour		
	setXMLInt(xmlFile, key .. "#startNightHour",fastnight.startNightHour);
	--startNightMinute		
	setXMLInt(xmlFile, key .. "#startNightMinute",fastnight.startNightMinute);
	--speedNight		
	setXMLInt(xmlFile, key .. "#speedNight",fastnight.speedNight);
	-- ShowHelp
	setXMLBool(xmlFile, key .. "#showHelp",fastnight.showHelp);
	
	saveXMLFile(xmlFile);
	delete(xmlFile);
end;

function fastnight:actionFastnight_Minus(actionName, keyStatus, arg3, arg4, arg5)
	if g_currentMission.isMasterUser then
		if (fastnight.manScaling >= 350) then
			fastnight.manScaling = fastnight.manScaling - 50;	
		elseif (fastnight.manScaling > 100) and (fastnight.manScaling <= 300) then
			fastnight.manScaling = fastnight.manScaling - 20;
		elseif (fastnight.manScaling > 40) and (fastnight.manScaling <= 100) then
			fastnight.manScaling = fastnight.manScaling - 10;
		elseif (fastnight.manScaling > 15) and (fastnight.manScaling <= 40) then
			fastnight.manScaling = fastnight.manScaling - 5;
		elseif (fastnight.manScaling > 1) and (fastnight.manScaling <= 15) then
			fastnight.manScaling = fastnight.manScaling - 1;
		end;
		g_currentMission:setTimeScale(fastnight.manScaling);
	end;
end;

function fastnight:actionFastnight_Plus(actionName, keyStatus, arg3, arg4, arg5)
	if g_currentMission.isMasterUser then
		if (fastnight.manScaling < 15) then
			fastnight.manScaling = fastnight.manScaling + 1;
		elseif (fastnight.manScaling >= 15) and (fastnight.manScaling < 40) then
			fastnight.manScaling = fastnight.manScaling + 5;
		elseif (fastnight.manScaling >= 40) and (fastnight.manScaling < 100) then
			fastnight.manScaling = fastnight.manScaling + 10;
		elseif (fastnight.manScaling >= 100) and (fastnight.manScaling < 300) then
			fastnight.manScaling = fastnight.manScaling + 20;
		elseif (fastnight.manScaling >= 300) and (fastnight.manScaling < 800) then
			fastnight.manScaling = fastnight.manScaling + 50;			
		end;
		g_currentMission:setTimeScale(fastnight.manScaling);	
	end;
end;

function fastnight:actionFastnight_Setting(actionName, keyStatus, arg3, arg4, arg5)
	if g_currentMission.isMasterUser then
		if g_gui.currentGui == nil then
			g_gui:showGui("FastnightSettingsScreen");
		end;
	end;
end;

addModEventListener(fastnight);

-- *****+++++*****+++++ Multiplayer *****+++++*****+++++
local origServerSendObjects = Server.sendObjects;

function Server:sendObjects(connection, x, y, z, viewDistanceCoeff)
	connection:sendEvent(fastnightMultiplayerJoinEvent:new());
	return origServerSendObjects(self, connection, x, y, z, viewDistanceCoeff);
end;

fastnightMultiplayerJoinEvent = {};
fastnightMultiplayerJoinEvent_mt = Class(fastnightMultiplayerJoinEvent, Event);
InitEventClass(fastnightMultiplayerJoinEvent, "fastnightMultiplayerJoinEvent");

function fastnightMultiplayerJoinEvent:emptyNew()
	local self = Event.new(fastnightMultiplayerJoinEvent_mt);
	self.className = 'fastnight.fastnightMultiplayerJoinEvent';
	return self;
end;

function fastnightMultiplayerJoinEvent:new()
	local self = fastnightMultiplayerJoinEvent.emptyNew()
	return self;
end;

-- Send data from the server to the client fastnightMultiplayerJoinEvent
function fastnightMultiplayerJoinEvent:writeStream(streamId, connection)
	if not connection:getIsServer() then	
		if fastnight.debug then
			print("--- FastNight Debug ... sending data to joining client: ..... ---");
		end;
		streamWriteUInt8(streamId, fastnight.startDayHour);
		streamWriteUInt8(streamId, fastnight.startDayMinute);
		streamWriteUInt8(streamId, fastnight.speedDay);
		streamWriteBool(streamId, fastnight.autoDayTimeScale);
		streamWriteUInt8(streamId, fastnight.startNightHour);
		streamWriteUInt8(streamId, fastnight.startNightMinute);
		streamWriteUInt8(streamId, fastnight.speedNight);
		streamWriteBool(streamId, fastnight.autoNightTimeScale);
		streamWriteBool(streamId, fastnight.showHelp);
	end;	
end;

-- Read from the server fastnightMultiplayerJoinEvent
function fastnightMultiplayerJoinEvent:readStream(streamId, connection)
	if connection:getIsServer() then
		if fastnight.debug then
			print("--- FastNight Debug ... reading data from server: ..... ---");
		end;
		fastnight.startDayHour = streamReadUInt8(streamId);
		fastnight.startDayMinute = streamReadUInt8(streamId);
		fastnight.speedDay = streamReadUInt8(streamId);
		fastnight.autoDayTimeScale = streamReadBool(streamId);
		fastnight.startNightHour = streamReadUInt8(streamId);
		fastnight.startNightMinute = streamReadUInt8(streamId);
		fastnight.speedNight = streamReadUInt8(streamId);
		fastnight.autoNightTimeScale = streamReadBool(streamId);
		fastnight.showHelp = streamReadBool(streamId);			
	end;
end;

fastnightMultiplayerUpdEvent = {};
fastnightMultiplayerUpdEvent_mt = Class(fastnightMultiplayerUpdEvent, Event);
InitEventClass(fastnightMultiplayerUpdEvent, "fastnightMultiplayerUpdEvent");

function fastnightMultiplayerUpdEvent:emptyNew()
	local self = Event.new(fastnightMultiplayerUpdEvent_mt);
	self.className = 'fastnight.fastnightMultiplayerUpdEvent';
	return self;
end;

function fastnightMultiplayerUpdEvent:new()
	local self = fastnightMultiplayerUpdEvent.emptyNew()
	return self;
end;

-- Send data from the client to the server fastnightMultiplayerUpdEvent
function fastnightMultiplayerUpdEvent:writeStream(streamId, connection)
	if connection:getIsServer() then	
		if fastnight.debug then
			print("--- FastNight Debug ... sending data to server: ..... ---");
		end;
		streamWriteUInt8(streamId, fastnight.startDayHour);
		streamWriteUInt8(streamId, fastnight.startDayMinute);
		streamWriteUInt8(streamId, fastnight.speedDay);
		streamWriteBool(streamId, fastnight.autoDayTimeScale);
		streamWriteUInt8(streamId, fastnight.startNightHour);
		streamWriteUInt8(streamId, fastnight.startNightMinute);
		streamWriteUInt8(streamId, fastnight.speedNight);
		streamWriteBool(streamId, fastnight.autoNightTimeScale);
		streamWriteBool(streamId, fastnight.showHelp);
	end;	
end;

-- Read from the client fastnightMultiplayerUpdEvent
function fastnightMultiplayerUpdEvent:readStream(streamId, connection)
	if not connection:getIsServer() then
		if fastnight.debug then
			print("--- FastNight Debug ... reading data from client: ..... ---");
		end;
		fastnight.startDayHour = streamReadUInt8(streamId);
		fastnight.startDayMinute = streamReadUInt8(streamId);
		fastnight.speedDay = streamReadUInt8(streamId);
		fastnight.autoDayTimeScale = streamReadBool(streamId);
		fastnight.startNightHour = streamReadUInt8(streamId);
		fastnight.startNightMinute = streamReadUInt8(streamId);
		fastnight.speedNight = streamReadUInt8(streamId);
		fastnight.autoNightTimeScale = streamReadBool(streamId);
		fastnight.showHelp = streamReadBool(streamId);
	end;
end;

function fastnightMultiplayerUpdEvent:sendEvent()
	if g_currentMission.missionDynamicInfo.isMultiplayer and not g_currentMission:getIsServer() then
        -- Send to server
        g_client:getServerConnection():sendEvent(fastnightMultiplayerUpdEvent:new());
	end;
end