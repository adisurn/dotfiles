local menu_bin = os.getenv("HOME")
    .. "/.config/sketchybar/helpers/menus/bin/menus"

SBAR.add("item", "control_center", {
    position = "right",
    icon = "􀜊",
    label = { drawing = false },
    click_script = menu_bin .. " -s 'Control Center,BentoBox-0'",
})