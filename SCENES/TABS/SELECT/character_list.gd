extends ItemList


@export var preview: TextureRect


func _ready() -> void:
	add_item("00: %s" % tr("SELECT_CHAR_00"))
	add_item("01: %s (sl.bin)" % tr("SELECT_CHAR_01"))
	add_item("02: %s (ky.bin)" % tr("SELECT_CHAR_02"))
	add_item("03: %s (my.bin)" % tr("SELECT_CHAR_03"))
	add_item("04: %s (ml.bin)" % tr("SELECT_CHAR_04"))
	add_item("05: %s (ax.bin)" % tr("SELECT_CHAR_05"))
	add_item("06: %s (po.bin)" % tr("SELECT_CHAR_06"))
	add_item("07: %s (ch.bin)" % tr("SELECT_CHAR_07"))
	add_item("08: %s (zt.bin)" % tr("SELECT_CHAR_08"))
	add_item("09: %s (bk.bin)" % tr("SELECT_CHAR_09"))
	add_item("0A: %s (fa.bin)" % tr("SELECT_CHAR_10"))
	add_item("0B: %s (ts.bin)" % tr("SELECT_CHAR_11"))
	add_item("0C: %s (jm.bin)" % tr("SELECT_CHAR_12"))
	add_item("0D: %s (an.bin)" % tr("SELECT_CHAR_13"))
	add_item("0E: %s (jy.bin)" % tr("SELECT_CHAR_14"))
	add_item("0F: %s (ve.bin)" % tr("SELECT_CHAR_15"))
	add_item("10: %s (dz.bin)" % tr("SELECT_CHAR_16"))
	add_item("11: %s (sy.bin)" % tr("SELECT_CHAR_17"))
	add_item("12: %s (in.bin)" % tr("SELECT_CHAR_18"))
	add_item("13: %s (zp.bin)" % tr("SELECT_CHAR_19"))
	add_item("14: %s (yy.bin)" % tr("SELECT_CHAR_20"))
	add_item("15: %s (rk.bin)" % tr("SELECT_CHAR_21"))
	add_item("16: %s (ab.bin)" % tr("SELECT_CHAR_22"))
	add_item("17: %s (fr.bin)" % tr("SELECT_CHAR_23"))
	add_item("18: %s (kr.bin)" % tr("SELECT_CHAR_24"))
	add_item("19: %s (js.bin)" % tr("SELECT_CHAR_25"))
	add_item("FF: %s" % tr("SELECT_CHAR_255"))

	item_selected.connect(on_item_selected)


func on_item_selected(index: int) -> void:
	if index > 25:
		preview.highlight_index(255)
	else:
		preview.highlight_index(index)
