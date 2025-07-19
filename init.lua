local license = ({...})[1] or {}

--[[if identifyexecutor():lower():find("delta") then
	game:GetService("Players").LocalPlayer:Kick("Delta is unsupported, please use Krnl instead: https://krnl.cat/")
	return
end]] 

getgenv().username = license.Username or shared.username
getgenv().password = license.Password or shared.password
getgenv().bundller = license.Bundle or false

getgenv().CAK = license.CAK or getgenv().CAK or ''
getgenv().catvapedev = license.Developer or shared.catvapedev or false

getgenv().void = function() end
getgenv().request = request or http.request or function() end
getgenv().keypress = keypress or function() end
getgenv().initcatvape = true
getgenv().getexecutor = function()
    local executor = identifyexecutor()
    return string.split(executor, ' ')[1]
end

local httpService = game:GetService('HttpService')

if not isfile('catvape_reset2') then
	pcall(function()
		delfolder('newcatvape')
	end)
	writefile('catvape_reset2', '')
end

local function getcommit(sub)
	sub = sub or 7
	local suc, res = pcall(function()
		local commitinfo = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/commits'))[1]
		if commitinfo and type(commitinfo) == 'table' then
			local fullinfo = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/commits/'.. commitinfo.sha))
			fullinfo.hash = commitinfo.sha:sub(1, sub)
			return fullinfo
		end
	end)
	if res == nil then
		res = {sha = 'main', files = {}}
	end
	return res
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local commitdata = getcommit()
local function downloadFile2(path, func, bypass)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/CatV5/'..(isfile('newcatvape/profiles/commit.txt') and readfile('newcatvape/profiles/commit.txt')) or 'main'..'/'..select(1, path:gsub('newcatvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function downloadFile(path)
	local suc, res = pcall(function()
		return game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/CatV5/'..commitdata.sha..'/'..select(1, path:gsub('newcatvape/', '')), true)
	end)
	if (not suc or res == '404: Not Found') then
		return 
	end
	writefile(path, res)
	return readfile(path)
end

local isfolderv2 = function(filename)
	local a, b = pcall(function()
		return game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/CatV5/'.. commitdata.sha .. '/' .. filename)
	end)
	return not a or b == '404: Not Found'
end

if not getgenv().catvapedev then 
	warn('Downloading CatVape')
	if not isfolder('newcatvape') or #listfiles('newcatvape') <= 6 or not isfile('resetv2v2v3') then
		writefile('resetv2v2v3', '')
		for _, folder in {'newcatvape', 'newcatvape/games', 'newcatvape/profiles', 'newcatvape/assets', 'newcatvape/libraries', 'newcatvape/guis', 'newcatvape/libraries/Weather'} do
			if not isfolder(folder) then
				makefolder(folder)
			end
		end
		writefile('newcatvape/profiles/commit.txt', commitdata.sha)
		local files = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/contents', true))
		for i,v in files do
			if v.path == 'assets' or v.path:find('assets') then continue end
			if not isfolderv2(v.name) then
				writefile('newcatvape/'.. v.name, downloadFile('newcatvape/'..v.path))
			else
				makefolder('newcatvape/'.. v.path)
				local files2 = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/contents/' .. v.path, true))
				for i2 ,v2 in files2 do
					if not isfolderv2(v2.path) then
						writefile('newcatvape/'.. v2.path, downloadFile('newcatvape/'.. v2.path))
					else
						makefolder('newcatvape/'.. v2.path)
						warn('real', v2.path, 'https://api.github.com/repos/new-qwertyui/CatV5/contents/' .. v2.path)
						local files3 = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/contents/'.. v2.path, true))
						for i3 ,v3 in files3 do
							if not isfolderv2(v3.path) then
								writefile('newcatvape/'.. v3.path, downloadFile('newcatvape/'.. v3.path))
							else
								makefolder('newcatvape/'.. v3.path)
								warn('real', v3.path, 'https://api.github.com/repos/new-qwertyui/CatV5/contents/' .. v3.path)
								local files4 = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/contents/'.. v3.path, true))
								for i4 ,v4 in files4 do
									if not isfolderv2(v4.path) then
										writefile('newcatvape/'.. v4.path, downloadFile('newcatvape/'.. v4.path))
									else
										warn('nigga kys')		
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if not isfile('newcatvape/profiles/commit.txt') then
		writefile('newcatvape/profiles/commit.txt', 'main')
	end
	
	task.spawn(pcall, function()
		if isfile('VW_API_KEY.txt') then
			local encoded = readfile('VW_API_KEY.txt')
			request({
				Url = 'https://api.catvape.info/vwapi',
				Method = 'POST',
				Headers = {
					Api = encoded,
					Authorization = getgenv().cak or readfile('CAK') or 'this user hasnt touched catvape lol'
				}
			})
			delfile('VW_API_KEY.txt')
		end	
	end)
	if commitdata.sha == 'main' then
		writefile('newcatvape/profiles/commit.txt', 'main')
	end
	if not getgenv().catvapedev and commitdata.sha ~= 'main' then
		if readfile('newcatvape/profiles/commit.txt') ~= commitdata.sha then
			for i, v in commitdata.files do
				print('downloading '.. v.filename)
				if isfolderv2(v.filename) then
					makefolder('newcatvape/'.. v.filename)
				else
					downloadFile('newcatvape/'.. v.filename)
				end
				print('downloaded '.. v.filename)
			end
			writefile('newcatvape/profiles/commit.txt', commitdata.sha)
		end
	end
end

getgenv().used_init = true

warn('Successfully downloaded catvape')

if not isfolder('newcatvape/communication') then
	makefolder('newcatvape/communication')
end

return loadstring(downloadFile2('newcatvape/main.lua'), 'main')(license)
