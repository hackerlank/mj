local dir = "sound/"

local SoundFiles = {
	man = {
		[1] = {"0-0, 0-1"},
		[10] = {"9-0, 9-1, 9-2"},
		[11] = {"10-0, 10-1"},
		[19] = {"18-0", "18-1", "18-2"},
		[23] = {"22-0", "22-1", "22-2"},
		[26] = {"25-0", "25-1"},
		[27] = {"26-0", "26-1"}
	},
	woman = {

	}
}

MJBACKGOURNDMUSIC = dir .. "gaming.ogg"

local man_dir = "sound/man/"
local women_dir = "sound/woman/"

function mjGetCardSoundFile(id, sex)
	local sound_files = sex == 1 and SoundFiles.man or SoundFiles.woman
	if sound_files[id] then
	else
		--GSound:getInstance():play
	end
end