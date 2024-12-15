--[[	   				BGM SELECT MODULE
===================================================================
Version: 1.2
Author: Cable Dorado 2 (CD2)
Tested on: IKEMEN GO v0.98.2, v0.99.0 and 2024-09-25 Nightly Build
Description:
Adds BGM Select for Round 1 to Stage Select Menu
===================================================================
]]

--[[
IMPORTANT! HOW TO FIX bgmSelect.lua:124 error:

GO TO external/script/start.lua AND FOR "local stageListNo = 0"
remove "local" and save the file to that stage select works with this module...
]]

--;===========================================================
--; MOTIF STUFF
--;===========================================================
--[[Example SYSTEM.DEF parameters assignments

[Select Info]

;BGM Select
bgm.move.snd = 100,0
bgm.pos = 160,164
bgm.active.font = 3,0,0
bgm.active2.font = 3,2  ;Second font color for blinking
bgm.done.font = 3,0
bgm.text = "BGM %i: %s"
bgm.random.text = "BGM: Random"
bgm.auto.text = "BGM: Auto"

]]

--if bgm paramvalues are not defined in system.def use following default values:
if motif.select_info.bgm_move_snd == nil then motif.select_info.bgm_move_snd = {100, 0} end
if motif.select_info.bgm_pos == nil then motif.select_info.bgm_pos = {160, 164} end

if motif.select_info.bgm_active_offset == nil then motif.select_info.bgm_active_offset = {0, 0} end
if motif.select_info.bgm_active_font == nil then motif.select_info.bgm_active_font = {"jg.fnt", 0, 0, 255, 255, 255, -1} end
if motif.select_info.bgm_active_scale == nil then motif.select_info.bgm_active_scale = {1.0, 1.0} end
if motif.select_info.bgm_active_switchtime == nil then motif.select_info.bgm_active_switchtime = 2 end

if motif.select_info.bgm_active2_offset == nil then motif.select_info.bgm_active2_offset = {0, 0} end
if motif.select_info.bgm_active2_font == nil then motif.select_info.bgm_active2_font = {"jg.fnt", 2, 0, 255, 255, 255, -1} end
if motif.select_info.bgm_active2_scale == nil then motif.select_info.bgm_active2_scale = {1.0, 1.0} end

if motif.select_info.bgm_done_offset == nil then motif.select_info.bgm_done_offset = {0, 0} end
if motif.select_info.bgm_done_font == nil then motif.select_info.bgm_done_font = {"jg.fnt", 0, 0, 255, 255, 255, -1} end
if motif.select_info.bgm_done_scale == nil then motif.select_info.bgm_done_scale = {1.0, 1.0} end

if motif.select_info.bgm_text == nil then motif.select_info.bgm_text = 'BGM %i: %s' end
if motif.select_info.bgm_random_text == nil then motif.select_info.bgm_random_text = 'BGM: Random' end
if motif.select_info.bgm_auto_text == nil then motif.select_info.bgm_auto_text = 'BGM: Auto' end

--[[ Not Coded
motif.select_info.bgm_portrait_anim = -1
motif.select_info.bgm_portrait_spr = {9000, 1}
motif.select_info.bgm_portrait_offset = {-60, -65}
motif.select_info.bgm_portrait_scale = {0.5, 0.5}
motif.select_info.bgm_portrait_bg_anim = 110
motif.select_info.bgm_portrait_bg_spr = {}
motif.select_info.bgm_portrait_bg_offset = {-76, -71}
motif.select_info.bgm_portrait_bg_scale = {1.0, 1.0}
motif.select_info.bgm_portrait_random_anim = -1
motif.select_info.bgm_portrait_random_spr = {111, 0}
motif.select_info.bgm_portrait_random_offset = {-76, -71}
motif.select_info.bgm_portrait_random_scale = {1.0, 1.0}
motif.select_info.bgm_portrait_window = {115, 172, 205, 223}
]]

if main.debugLog then main.f_printTable(motif, "debug/t_motif.txt") end

--;===========================================================
--; BGM SELECT STUFF
--;===========================================================
t_selMusic = {} --Create Music Table that will be used in the BGM Select
t_bgmList = {} --Create another table with the music that will be used by the BGM: RANDOM option of t_selMusic

for k, v in ipairs(getDirectoryFiles('sound')) do --Read sound Dir
	v:gsub('^(.-)([^\\/]+)%.([^%.\\/]-)$', function(path, filename, ext)
		path = path:gsub('\\', '/')
		ext = ext:lower() --Convert file extensions to lowercase
		if ext == 'mp3' or ext == 'ogg' then --Filter files with mp3 or ogg extension
			table.insert(t_selMusic, {bgmfile = path .. filename .. '.' .. ext, bgmname = filename}) --Store each new file in t_selMusic
			table.insert(t_bgmList, path .. filename .. '.' .. ext) --Store each new file in t_bgmList
		end
	end)
end
--Add random item to the end of t_selMusic:
table.insert(t_selMusic, {bgmfile = "", bgmname = ""})

if main.debugLog then main.f_printTable(t_selMusic, 'debug/t_selMusic.txt') end
if main.debugLog then main.f_printTable(t_bgmList, 'debug/t_bgmList.txt') end

musicListNo = 0 --New
txt_selMusic = main.f_createTextImg(motif.select_info, 'bgm_active') --New
txt_selMusicA = main.f_createTextImg(motif.select_info, "bgm_active") --New
bgmActiveCount = 0 --New
bgmActiveType = 'bgm_active' --New
musicSelect = false --New
backupStgActive = motif.select_info.stage_active_switchtime --New

--;===========================================================
--; STAGE MENU
--;===========================================================
function start.f_stageMenu() --Copy of Stage Menu function to make modifications that replace the original script
	local n = stageListNo
	--local m = musicListNo
	if timerSelect == -1 then
		stageEnd = true
		return
	end
	if not musicSelect then --If the BGM Select is not active (Stage Select cursor will be active)
		motif.select_info.stage_active_switchtime = backupStgActive --restore stage sel active cursor
		--Previous Stage
		if main.f_input(main.t_players, {'$B'}) then
			sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
			stageListNo = stageListNo - 1
			if stageListNo < 0 then stageListNo = #main.t_selectableStages end
		--Next Stage
		elseif main.f_input(main.t_players, {'$F'}) then
			sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
			stageListNo = stageListNo + 1
			if stageListNo > #main.t_selectableStages then stageListNo = 0 end
		--Get BGM Select Controls
		elseif main.f_input(main.t_players, {'$U'}) then
			sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
			musicSelect = true
		elseif main.f_input(main.t_players, {'$D'}) then
			sndPlay(motif.files.snd_data, motif.select_info.stage_move_snd[1], motif.select_info.stage_move_snd[2])
			musicSelect = true
		end
	else --If you are in the BGM Select (Stage Select cursor will be inactive)
		motif.select_info.stage_active_switchtime = 0 --inactive stage sel active cursor
		--Previous BGM
		if main.f_input(main.t_players, {'$B'}) then
			sndPlay(motif.files.snd_data, motif.select_info.bgm_move_snd[1], motif.select_info.bgm_move_snd[2])
			musicListNo = musicListNo - 1
			if musicListNo < 0 then musicListNo = #t_selMusic end
		--Next BGM
		elseif main.f_input(main.t_players, {'$F'}) then
			sndPlay(motif.files.snd_data, motif.select_info.bgm_move_snd[1], motif.select_info.bgm_move_snd[2])
			musicListNo = musicListNo + 1
			if musicListNo > #t_selMusic then musicListNo = 0 end
		--Get Stage Select Controls
		elseif main.f_input(main.t_players, {'$U'}) then
			sndPlay(motif.files.snd_data, motif.select_info.bgm_move_snd[1], motif.select_info.bgm_move_snd[2])
			musicSelect = false
		elseif main.f_input(main.t_players, {'$D'}) then
			sndPlay(motif.files.snd_data, motif.select_info.bgm_move_snd[1], motif.select_info.bgm_move_snd[2])
			musicSelect = false
		end
	end
	--Reset BGM Select (Mainly to avoid desync in online)
	if esc() or main.f_input(main.t_players, {'m'}) then
		musicListNo = 0
		musicSelect = false
	end
	if n ~= stageListNo and stageListNo > 0 then
		animReset(main.t_selStages[main.t_selectableStages[stageListNo]].anim_data)
		animUpdate(main.t_selStages[main.t_selectableStages[stageListNo]].anim_data)
	end
--;----------------------------------
--;              NEW
--;----------------------------------
	--draw bgm portrait (Not Coded)
	
	if musicSelect then
		if bgmActiveCount < motif.select_info.bgm_active_switchtime then --delay change
			bgmActiveCount = bgmActiveCount + 1
		else
			if bgmActiveType == 'bgm_active' then
				bgmActiveType = 'bgm_active2'
			else
				bgmActiveType = 'bgm_active'
			end
			bgmActiveCount = 0
		end
	end
	--draw music name
	local t_txt2 = {}
	--Auto BGM
	if musicListNo == 0 then
		t_txt2[1] = motif.select_info.bgm_auto_text
	--Random BGM
	elseif musicListNo == #t_selMusic then
		t_txt2[1] = motif.select_info.bgm_random_text
	--Custom BGM
	else
		t = motif.select_info.bgm_text:gsub('%%i', tostring(musicListNo))
		t = t:gsub('\n', '\\n')
		t = t:gsub('%%s', t_selMusic[musicListNo].bgmname)
		for i, c in ipairs(main.f_strsplit('\\n', t)) do --split string using "\n" delimiter
			t_txt2[i] = c
		end
	end
	for i = 1, #t_txt2 do
		txt_selMusic:update({
		font =   motif.select_info[bgmActiveType .. '_font'][1],
		bank =   motif.select_info[bgmActiveType .. '_font'][2],
		align =  motif.select_info[bgmActiveType .. '_font'][3],
		text =   t_txt2[i],
		x =      motif.select_info.bgm_pos[1] + motif.select_info[bgmActiveType .. '_offset'][1],
		y =      motif.select_info.bgm_pos[2] + motif.select_info[bgmActiveType .. '_offset'][2] + main.f_ySpacing(motif.select_info, bgmActiveType) * (i - 1),
		scaleX = motif.select_info[bgmActiveType .. '_scale'][1],
		scaleY = motif.select_info[bgmActiveType .. '_scale'][2],
		r =      motif.select_info[bgmActiveType .. '_font'][4],
		g =      motif.select_info[bgmActiveType .. '_font'][5],
		b =      motif.select_info[bgmActiveType .. '_font'][6],
		height = motif.select_info[bgmActiveType .. '_font'][7],
		})
		txt_selMusic:draw()
	end
end

--sets music
function start.f_setMusic(num, data) --Copy of music assignment function to make modifications that replace the original script
	start.bgmround = 0
	start.t_music = {}
	local side = 2
	local soundtrack = nil
	local bgmType = "auto"
	for _, v in ipairs({'music', 'musicfinal', 'musiclife', 'musicvictory', 'musicvictory'}) do
		if start.t_music[v] == nil then
			start.t_music[v] = {}
		end
		local t_ref = nil
		-- music assigned by launchFight
		if data ~= nil and data[v] ~= nil then
			t_ref = data[v]
		-- game modes other than demo (or demo with stage BGM param enabled)
		elseif not gamemode('demo') or motif.demo_mode.fight_playbgm == 1 then
			--AUTO BGM
			if not main.stageMenu or (main.stageMenu and musicListNo == 0) then
				
			else --Stage Select Enabled
				bgmType = "custom"
			end
			-- music assigned as character param
			if (main.charparam.music or (v == 'musicvictory' and main.victoryScreen)) and start.f_getCharData(start.p[side].t_selected[1].ref)[v] ~= nil then
				t_ref = start.f_getCharData(start.p[side].t_selected[1].ref)[v]
			-- music assigned as stage param
			elseif main.t_selStages[num] ~= nil and main.t_selStages[num][v] ~= nil then
				t_ref = main.t_selStages[num][v]
			end
		end
		-- append t_music table
		if t_ref ~= nil then
			if main.debugLog then main.f_printTable(t_ref, 'debug/t_stageSongRef.txt') end
			-- musicX tracks are nested using round numbers as table keys
			if v == 'music' then
				for k2, v2 in pairs(t_ref) do
					local track = math.random(1, #v2)
					start.t_music[v][k2] = {
						bgmusic = v2[track].bgmusic,
						bgmvolume = v2[track].bgmvolume,
						bgmloopstart = v2[track].bgmloopstart,
						bgmloopend = v2[track].bgmloopend
					}
				end
			else
				local track = math.random(1, #t_ref)
				-- musicvictory tracks are nested using team side as table keys
				if v == 'musicvictory' then
					start.t_music[v][side] = {
						bgmusic = t_ref[track].bgmusic,
						bgmvolume = t_ref[track].bgmvolume,
						bgmloopstart = t_ref[track].bgmloopstart,
						bgmloopend = t_ref[track].bgmloopend
					}
				-- musicfinal and musiclife tracks are stored without additional nesting
				else
					start.t_music[v] = {
						bgmusic = t_ref[track].bgmusic,
						bgmvolume = t_ref[track].bgmvolume,
						bgmloopstart = t_ref[track].bgmloopstart,
						bgmloopend = t_ref[track].bgmloopend
					}
				end
			end
		end
		if v == 'musicvictory' then
			side = 1
		end
	end
	-- bgmratio.life, bgmtrigger.life
	for k, v in pairs({bgmratio_life = 30, bgmtrigger_life = 1}) do
		if main.t_selStages[num] ~= nil and main.t_selStages[num][k] ~= nil then
			start.t_music[k] = main.t_selStages[num][k]
		else
			start.t_music[k] = v
		end
	end
	--Generate table with custom Music Data
	if bgmType == "custom" then
		soundtrack = t_selMusic[musicListNo].bgmfile --CUSTOM BGM
		if musicListNo == #t_selMusic then --RANDOM BGM
			if #t_bgmList == 0 then --If there is not custom songs added in sound folder
				soundtrack = ""
			else --If there are songs loaded, select one at random
				soundtrack = t_bgmList[math.random(1, #t_bgmList)]
			end
		end
		start.t_music.music[1] = {bgmusic = (soundtrack), bgmvolume = (100), bgmloopstart = (0), bgmloopend = (0)} --Round 1 Music
	end
	if main.debugLog then main.f_printTable(start.t_music, 'debug/t_stageSong.txt') end
	--Reset BGM Select (Mainly to avoid desync in online)
	musicListNo = 0
	musicSelect = false
end