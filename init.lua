local license = ({...})[1] or {}
local developer = getgenv().catvapedev or license.Developer or false

local cloneref = cloneref or function(ref) return ref end
local gethui = gethui or function() return game:GetService('Players').LocalPlayer.PlayerGui end

local httpService = cloneref(game:GetService('HttpService'))

local success, commitdata = pcall(function()
    local commitinfo = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/commits'))[1]
    if commitinfo and type(commitinfo) == 'table' then
        local fullinfo = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/new-qwertyui/CatV5/commits/'.. commitinfo.sha))
        fullinfo.hash = commitinfo.sha:sub(1, 7)
        return fullinfo
    end
end)

if not success or commitdata == nil then
	commitdata = {sha = 'main', files = {}}
end

local downloader = Instance.new('TextLabel', Instance.new('ScreenGui', gethui()))
downloader.Size = UDim2.new(1, 0, -0.08, 0)
downloader.BackgroundTransparency = 1
downloader.TextStrokeTransparency = 0
downloader.TextSize = 20
downloader.Text = 'Downloading dogvape'
downloader.TextColor3 = Color3.new(1, 1, 1)
downloader.Font = Enum.Font.Arial

local function downloadFile2(path: string) : string
	if not isfile(path) or not developer then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/testaccount11262/DogVape/'.. commitdata.sha.. '/'.. path:gsub('dogvape/', ''))
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		writefile(path, res)
	end
	return readfile(path)
end

local function downloadFile(path: string) : string
	if not developer or not isfile(`dogvape/{path}`) then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/testaccount11262/DogVape/'..commitdata.sha..'/'..path:gsub('dogvape/', ''):gsub(' ', '%%20'), true)
        end)
        if (not suc or res == '404: Not Found') then
            return 
        end
        writefile(path, res)
    end
	return readfile(path)
end

local function gitisfolder(path: string) : boolean
    local suc, body = pcall(function()
        return request({
            Url = 'https://raw.githubusercontent.com/qwertyui-is-back/CatV5/'.. commitdata.sha.. '/'.. path:gsub('dogvape/', ''),
            Method = 'GET'
        })
    end)
    return not suc or body.StatusCode == 404
end

local function yield(path: string) : ()
    if path == nil then
        downloader.Text = 'You have exceeded the limit, Please try again in 30 mins!'
        repeat task.wait() until false
    end
    downloader.Text = `{isfile('dogvape/path') and 'Updating' or 'Downloading'} dogvape/{path}`
    if gitisfolder(path) then
        makefolder(`dogvape/{path}`)
        local contents = request({
            Url = `https://api.github.com/repos/testaccount11262/DogVape/contents/{path}`,
            Method = 'GET'
        }) :: {Body: string, StatusCode: number}
        for _, v: table in httpService:JSONDecode(contents.Body) do
            yield(v.path)
        end
    else
        downloadFile(`dogvape/{path}`)
    end
end

if not developer and not isfile('eiqrhjqpr') then
    pcall(delfolder, 'dogvape')
end

writefile('eiqrhjqpr', 'true')

if not developer then
    local newuser = not isfolder('dogvape') or #listfiles('dogvape') <= 6 or not isfolder('dogvape/profiles') or not isfile('dogvape/profiles/commit.txt')
    if newuser or readfile('dogvape/profiles/commit.txt') ~= commitdata.sha then
        makefolder('dogvape')   

        local blacklist = {'assets', '.vscode', 'README.md'}
        local contents = request({
            Url = `https://api.github.com/repos/new-qwertyui/CatV5/contents`,
            Method = 'GET'
        }) :: {Body: string, StatusCode: number}

        if not newuser then
            table.insert(blacklist, 'profiles')
        end

        for _, v: table in httpService:JSONDecode(contents.Body) do
            if not table.find(blacklist, v.path) then
                yield(v.path)
            end
        end
        writefile(`dogvape/profiles/commit.txt`, commitdata.sha)
    end

    if commitdata.sha == 'main' then
		writefile('dogvape/profiles/commit.txt', 'main')
    end
end

writefile('dogvapereset', 'True')

downloader:Destroy()

shared.VapeDeveloper = true
getgenv().used_init = true
getgenv().catvapedev = developer

if not isfolder('dogvape/communication') then
	makefolder('dogvape/communication')
end

return loadstring(downloadFile2('dogvape/main.lua'), 'main')(license)
