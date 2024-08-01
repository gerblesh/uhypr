-- Pull in the wezterm API
local catppuccin_mocha = {
	rosewater = "#f5e0dc",
	flamingo = "#f2cdcd",
	pink = "#f5c2e7",
	mauve = "#cba6f7",
	red = "#f38ba8",
	maroon = "#eba0ac",
	peach = "#fab387",
	yellow = "#f9e2af",
	green = "#a6e3a1",
	teal = "#94e2d5",
	sky = "#89dceb",
	sapphire = "#74c7ec",
	blue = "#89b4fa",
	lavender = "#b4befe",
	text = "#cdd6f4",
	subtext1 = "#bac2de",
	subtext0 = "#a6adc8",
	overlay2 = "#9399b2",
	overlay1 = "#7f849c",
	overlay0 = "#6c7086",
	surface2 = "#585b70",
	surface1 = "#45475a",
	surface0 = "#313244",
	base = "#1e1e2e",
	mantle = "#181825",
	crust = "#11111b",
}

local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.default_prog = { "/bin/fish" }
config.set_environment_variables = {
	SHELL = "/bin/fish",
}
--config.term = "wezterm"
-- config.unix_domains = {
-- 	{
-- 		name = "unix",
-- 	},
-- }
-- config.default_gui_startup_args = { "connect", "unix" }
-- appearance
config.font = wezterm.font("JetBrainsMonoNerdFont")
config.font_size = 15.0
config.enable_wayland = true
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.97
config.hide_tab_bar_if_only_one_tab = false
config.window_padding = {
	left = 3,
	right = 3,
	top = 3,
	bottom = 3,
}
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.tab_bar.background = catppuccin_mocha.crust
config.color_schemes = { ["custom"] = custom }
config.color_scheme = "custom"
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 20

config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 1.0,
}

wezterm.on("update-right-status", function(window, pane)
	local leader_color = catppuccin_mocha.green
	if window:leader_is_active() then
		leader_color = catppuccin_mocha.red
	end
	local elements = {
		{ Foreground = { Color = leader_color } },
		{ Text = "" },
		{ Foreground = { Color = catppuccin_mocha.base } },
		{ Background = { Color = leader_color } },
		{ Text = " " },
		{ Foreground = { Color = catppuccin_mocha.text } },
		{ Background = { Color = catppuccin_mocha.base } },
		{ Text = " " .. window:active_workspace() .. " " },
	}

	for _, value in ipairs(wezterm.mux.get_workspace_names()) do
		if value == window:active_workspace() then
			goto continue
		end
		table.insert(elements, { Foreground = { Color = catppuccin_mocha.blue } })
		table.insert(elements, { Text = "" })
		table.insert(elements, { Foreground = { Color = catppuccin_mocha.base } })
		table.insert(elements, { Background = { Color = catppuccin_mocha.blue } })
		table.insert(elements, { Text = " " })
		table.insert(elements, { Foreground = { Color = catppuccin_mocha.text } })
		table.insert(elements, { Background = { Color = catppuccin_mocha.base } })
		table.insert(elements, { Text = " " .. value .. " " })
		::continue::
	end
	window:set_right_status(wezterm.format(elements))
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.active_pane.title
	if tab.tab_title and #tab.tab_title > 0 then
		title = tab.tab_title
	end
	title = wezterm.truncate_right(title, max_width - 5)
	local active_color = catppuccin_mocha.blue
	if tab.is_active then
		active_color = catppuccin_mocha.peach
	end
	return {
		{ Background = { Color = custom.tab_bar.background } },
		{ Foreground = { Color = active_color } },
		{ Text = "" },
		{ Background = { Color = active_color } },
		{ Foreground = { Color = catppuccin_mocha.base } },
		{ Text = (tab.tab_index + 1) .. " " },
		{ Background = { Color = catppuccin_mocha.base } },
		{ Foreground = { Color = catppuccin_mocha.text } },
		{ Text = " " .. title },
		{ Background = { Color = custom.tab_bar.background } },
		{ Foreground = { Color = catppuccin_mocha.base } },
		{ Text = "" },
	}
end)
-- keymaps

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	-- reverse lookup
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

config.leader = { key = " ", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
	{
		mods = "LEADER",
		key = "s",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "v",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "z",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		mods = "LEADER",
		key = "r",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	{
		mods = "LEADER",
		key = "q",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		mods = "LEADER|SHIFT",
		key = "q",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},
	{
		mods = "LEADER",
		key = "k",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
	{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
	{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
	{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
	{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
	{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
	{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
	{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },
	{ key = "9", mods = "LEADER", action = wezterm.action({ ActivateTab = 8 }) },

	{ key = "l", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "h", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
	-- Activate Copy Mode
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
	-- Paste from Copy Mode
	{ key = "]", mods = "LEADER", action = wezterm.action.PasteFrom("PrimarySelection") },
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			-- Here you can dynamically construct a longer list if needed
			local home = wezterm.home_dir
			local workspaces = {
				{ id = home, label = "default" },
				{ id = home, label = "Home" },
				{ id = home .. "/Documents/Rust/", label = "Rust" },
				{ id = home .. "/Documents/go-projects/", label = "Golang" },
				{ id = home .. "/Documents/C/", label = "C" },
				{ id = home .. "/Documents/csharp/", label = "C Sharp" },
				{ id = home .. "/Documents/Processing/", label = "Processing" },
				{ id = home .. "/Documents/Godot Projects/", label = "Godot" },
				{ id = home .. "/Documents/Neorg/", label = "Neorg" },
				{ id = home .. "/Documents/Ublue/", label = "Universal Blue" },
				{ id = home .. "/.config/", label = "Config" },
			}

			window:perform_action(
				wezterm.action.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
						if not id and not label then
							wezterm.log_info("cancelled")
						else
							wezterm.log_info("id = " .. id)
							wezterm.log_info("label = " .. label)
							inner_window:perform_action(
								wezterm.action.SwitchToWorkspace({
									name = label,
									spawn = {
										label = "Workspace: " .. label,
										cwd = id,
									},
								}),
								inner_pane
							)
						end
					end),
					title = "Choose Workspace",
					choices = workspaces,
					fuzzy = true,
					fuzzy_description = "Fuzzy find and/or make a workspace 󱝩 ",
				}),
				pane
			)
		end),
	},
}

return config
