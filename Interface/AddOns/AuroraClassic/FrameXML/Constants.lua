-- Add quality colour for Poor items
BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_POOR] = {r = .61, g = .61, b = .61}
-- Change Common from grey to black
BAG_ITEM_QUALITY_COLORS[-1] = {r = 0, g = 0, b = 0}
BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON] = {r = 0, g = 0, b = 0}

NORMAL_QUEST_DISPLAY = gsub(NORMAL_QUEST_DISPLAY, "000000", "ffffff")
TRIVIAL_QUEST_DISPLAY = gsub(TRIVIAL_QUEST_DISPLAY, "000000", "ffffff")
IGNORED_QUEST_DISPLAY = gsub(IGNORED_QUEST_DISPLAY, "000000", "ffffff")