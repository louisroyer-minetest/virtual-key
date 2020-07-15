-- Translation support
local S = minetest.get_translator("virtual_key")
local DS = minetest.get_translator("default")
local KS = minetest.get_translator("keyring")

virtual_key.craft_common = {}
virtual_key.craft_common.base_form_def = {
	translator = S,
	title_tab_management = S("Virtual keys management"),
	title_tab_settings = S("Registerer settings"),
	virtual_symbol = "", -- all keys are virtual, no need to print this
	msg_not_allowed_edit = S("You are not allowed to edit settings of this registerer."),
	msg_is_public = S("This registerer is public."),
	msg_you_own = S("You own this registerer."),
	msg_is_owned_by = "This registerer is owned by @1.",
	msg_is_shared_with = S("This registerer is shared with:"),
	msg_not_use_allowed = S("You are not allowed to use this registerer."),
	msg_not_shared = S("This registerer is not shared."),
	msg_list_of_keys = S("List of virtual keys in the registerer:"),
	msg_no_key = S("There is no virtual key in the registerer."),
	remove_key = true,
	rename_key = true,
	set_owner = true,
	share = false,
}

--[[
-- Adds a virtual key to a registerer. There is no owning check in this function.
--]]
virtual_key.craft_common.import_virtual_key = function(itemstack,
	secret, description, user_desc)
	local meta = itemstack:get_meta()
	local krs = minetest.deserialize(meta:get_string(keyring.fields.KRS)) or {}
	if not keyring.fields.utils.KRS.in_keyring(krs, secret) then
		krs[secret] = {
			number = 0,
			virtual = true,
			description = description,
			user_description = user_desc or nil,
		}
		meta:set_string(keyring.fields.KRS, minetest.serialize(krs))
	end
	return itemstack
end

virtual_key.craft_common.base_craft_def = {
	inventory_image = "virtual_key_virtual_keys_registerer.png",
	-- mimic a key
	groups = {virtual_key = 1, key_container = 1},
	stack_max = 1,

	-- on left click
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)

		if not node then
			return itemstack
		end

		local on_skeleton_key_use = minetest.registered_nodes[node.name].on_skeleton_key_use
		if not on_skeleton_key_use then
			return itemstack
		end

		local name = user:get_player_name()
		local keyring_owner = itemstack:get_meta():get_string("owner")
		local keyring_access = keyring.fields.utils.owner.is_edit_allowed(keyring_owner, name)
		if not keyring_access then
			virtual_key.log("action", "Player "..name
				.." tryed to use personal virtual keys registerer of "
				..(keyring_owner or "unkwown player"))
			minetest.chat_send_player(name,
				S("You are not allowed to use this personal virtual keys registerer."))
			return itemstack
		end

		-- make a new key secret in case the node callback needs it
		local random = math.random
		local newsecret = string.format(
			"%04x%04x%04x%04x",
			random(2^16) - 1, random(2^16) - 1,
			random(2^16) - 1, random(2^16) - 1)

		local secret, _, _ = on_skeleton_key_use(pos, user, newsecret)

		if secret then
			-- add virtual key
			return virtual_key.craft_common.import_virtual_key(itemstack, secret,
				DS("Key to @1's @2", name, minetest.registered_nodes[node.name].description))
		end
		return itemstack
	end,
	on_secondary_use = function(itemstack, placer, pointed_thing)
		return keyring.form.formspec(itemstack, placer)
	end,
	-- mod doc
	_doc_items_usagehelp = S("Use it like a regular skeleton key. "
		.."Click pointing no node to access virtual-key-management interface "
		.."(keys can be renamed or removed).\n"
		.."To use your registered virtual keys, add them to a keyring."),
}

--[[
-- Returns a table with:
-- - consumme
-- - is_craft_forbidden
-- - is_result_owned
-- - return_list
-- - result_name
--]]
virtual_key.craft_common.get_craft_properties = function(itemstack, player_name,
	old_craft_grid)
	local props = {
		consumme = false,
		is_craft_forbidden = false,
		is_result_owned = false,
		return_list = {},
		result_name = itemstack:get_name(),
	}
	for position, item in pairs(old_craft_grid) do
		local item_name = item:get_name()
		if item_name == "basic_materials:padlock" then
			props.consumme = true
		end
		local owner = item:get_meta():get_string("owner")
		if owner ~= "" then
			props.is_craft_forbidden = not keyring.fields.utils.owner.is_edit_allowed(owner,
				player_name)
			if props.is_craft_forbidden then
				return props
			end
			if props.result_name == item_name then
				props.is_result_owned = true
			end
		end
		if minetest.get_item_group(item_name, "virtual_key") == 1 then
			table.insert(props.return_list, position, item)
		end
	end
	for position, item in pairs(props.return_list) do
		local item_name = item:get_name()
		if (props.consumme and (minetest.get_item_group(item_name, "virtual_key") == 1))
			or (item_name == props.result_name
			and props.is_result_owned == (item:get_meta():get_string("owner") ~= "")) then
			props.return_list[position] = nil
			break
		end
	end

	return props
end

-- manage virtual keys copy
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local name = itemstack:get_name()
	-- guard
	if (name ~= "virtual_key:virtual_keys_registerer")
		and (name ~= "virtual_key:personal_virtual_keys_registerer") then
		return
	end
	local play_name = player:get_player_name()
	local properties = virtual_key.craft_common.get_craft_properties(itemstack,
		play_name, old_craft_grid)
	if properties.is_craft_forbidden then
		virtual_key.log("action", "Player "..play_name.." used a virtual key owned by "
			.."an other player in a craft")
		for p, i in pairs(old_craft_grid) do
			craft_inv:set_stack("craft", p, i)
		end
		return ItemStack(nil)
	end
	-- merge virtual keys in 1 KRS
	local r_krs = {}
	for p, i in pairs(old_craft_grid) do
		print(dump(i))
		if minetest.get_item_group(i:get_name(), "virtual_key") == 1 then
			local meta = i:get_meta()
			local krs = minetest.deserialize(meta:get_string(keyring.fields.KRS)) or {}
			for s, vk in pairs(krs) do
				r_krs[s] = vk
			end
		end
	end
	-- resulting krs
	local ser_r_krs = minetest.serialize(r_krs)
	itemstack:get_meta():set_string(keyring.fields.KRS, ser_r_krs)
	-- set back return_list
	for p, i in pairs(properties.return_list) do
		i:get_meta():set_string(keyring.fields.KRS, ser_r_krs)
		craft_inv:set_stack("craft", p, i)
	end

	if properties.consumme then
		return itemstack
	end

	if not properties.is_result_owned then
		return itemstack
	end
	local meta = itemstack:get_meta()
	meta:set_string("description", itemstack:get_description()
		.." "..KS("(owned by @1)", play_name))
	meta:set_string("owner", play_name)
	return itemstack
end)

-- craft predictions
minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	local name = itemstack:get_name()
	if (name ~= "virtual_key:virtual_keys_registerer")
		and (name ~= "virtual_key:personal_virtual_keys_registerer") then
		return
	end
	local play_name = player:get_player_name()
	local properties = virtual_key.craft_common.get_craft_properties(itemstack,
		play_name, old_craft_grid)
	if properties.is_craft_forbidden then
		return ItemStack(nil)
	end
	if properties.consumme or (not properties.is_result_owned) then
		return
	end

	local meta = itemstack:get_meta()
	meta:set_string("description", itemstack:get_description()
		.." "..KS("(owned by @1)", play_name))
	meta:set_string("owner", play_name)
	return itemstack
end)
