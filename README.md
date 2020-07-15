# Virtual key [![Build Status](https://travis-ci.org/louisroyer/minetest-virtual-key.svg?branch=master)](https://travis-ci.org/louisroyer/minetest-virtual-key)

This minetest mod add virtual keys you can add in your keyring.

Craft a virtual keys registerer and start using it as regular skeleton-keys.
Content of registerer can be copied without loss on any other registerer and added on any keyring.

## Craft
### Virtual keys registerer (shapeless)
- `default:skeleton_key`
- `basic_materials:ic`

### Personal virtual keys registerer (shapeless)
- `default:skeleton_key`
- `basic_materials:ic`
- `basic_materials:padlock`

or
- `virtual_key:virtual_key_registerer`
- `basic_materials:padlock`

### Synchronize virtual keys (shapeless)
- `group:virtual_key`
- `virtual_key:virtual_key_registerer`

or
- `group:virtual_key`
- `virtual_key:personal_virtual_key_registerer`

Notes:
- if you use a personal virtual keys registerer in the craft, then it must belong to you, else the craft will be forbidden.
- you cannot register a virtual key using a key/keyring in a craft: you need to click on the locked node to register the virtual key, then if you borrow a regular key to another player, no clandestine copy can be done.

## Dependencies
- [basic_materials](https://gitlab.com/VanessaE/basic_materials)
- default
- [keyring](https://github.com/louisroyer/minetest-keyring)

![Screenshot](screenshot.png)

## License
- CC0-1.0, Louis Royer 2020

## Settings
Setting `virtual_key.personnal_vkeys_registerer` is available to disable/enable personal virtual keys registerer (enabled by default).
