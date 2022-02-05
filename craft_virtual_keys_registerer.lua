-- Translation support
local S = minetest.get_translator("virtual_key")

keyring.form.register_allowed("virtual_key:virtual_keys_registerer",
	virtual_key.craft_common.base_form_def)

local def = {}
for k, v in pairs(virtual_key.craft_common.base_craft_def) do
	def[k] = v
end
def.description = S("Virtual keys registerer")
def._doc_items_longdesc = S("A virtual keys registerer to "
	.."register your virtual keys.")

minetest.register_craftitem("virtual_key:virtual_keys_registerer", def)

minetest.register_craft({
	output = "virtual_key:virtual_keys_registerer",
	recipe = { "keys:skeleton_key", "basic_materials:ic" },
	type = "shapeless",
})

-- craft to synchronize virtual keys
minetest.register_craft({
	output = "virtual_key:virtual_keys_registerer",
	recipe = { "virtual_key:virtual_keys_registerer", "group:virtual_key" },
	type = "shapeless",
})
