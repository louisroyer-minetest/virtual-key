-- Translation support
local S = minetest.get_translator("virtual_key")

local form_def = {}
for k, v in pairs(virtual_key.craft_common.base_form_def) do
	form_def[k] = v
end
form_def.title_tab = true
keyring.form.register_allowed("virtual_key:personal_virtual_keys_registerer", form_def)

local def = {}
for k, v in pairs(virtual_key.craft_common.base_craft_def) do
	def[k] = v
end
def.description = S("Personal virtual keys registerer")
def._doc_items_longdesc = S("A personal virtual keys registerer to "
	.."register your virtual keys.")
minetest.register_craftitem("virtual_key:personal_virtual_keys_registerer", def)

minetest.register_craft({
	output = "virtual_key:personal_virtual_keys_registerer",
	recipe = { "default:skeleton_key", "basic_materials:ic", "basic_materials:padlock" },
	type = "shapeless",
})

minetest.register_craft({
	output = "virtual_key:personal_virtual_keys_registerer",
	recipe = { "virtual_key:virtual_keys_registerer", "basic_materials:padlock" },
	type = "shapeless",
})

-- craft to synchronize virtual keys
minetest.register_craft({
	output = "virtual_key:personal_virtual_keys_registerer",
	recipe = { "virtual_key:personal_virtual_keys_registerer", "group:virtual_key" },
	type = "shapeless",
})
