local MP = minetest.get_modpath("virtual_key")

virtual_key = {}

-- mod information
virtual_key.mod = {version = "1.0.0", author = "Louis Royer"}

-- virtual_key settings
virtual_key.settings =
	{
		personal_vkeys_registerer = minetest.settings:get_bool(
			"virtual_key.personal_vkeys_registerer", true),
	}

-- XXX: when https://github.com/minetest/minetest/pull/7377
--      is merged, we can remove this function and %s/virtual_key\.log/minetest\.log/g
virtual_key.log = function(level, text)
	local prefix = "[virtual_key] "
	if text then
		minetest.log(level, prefix..text)
	else
		minetest.log(prefix..level)
	end
end

local keyring_version = {}
local k = 1
for v in string.gmatch(keyring.mod.version, "[^%.]+") do
	keyring_version[k] = tonumber(v)
	k = k + 1
end
if (keyring_version[1] < 1) and (keyring_version[2] < 2) then
	-- keyring version must be at least 1.2.0
	virtual_key.log("error", "Please use a more recent version of"
	.." keyring to be able to add your virtual keys to keyrings.")
	virtual_key.log("error", "Get lastest version of keyring: "
	.."https://github.com/louisroyer/minetest-keyring/releases/latest")
end

dofile(MP.."/craft_common.lua")
dofile(MP.."/craft_virtual_keys_registerer.lua")
if virtual_key.settings.personal_vkeys_registerer then
	dofile(MP.."/craft_personal_virtual_keys_registerer.lua")
end
