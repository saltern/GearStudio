extends MenuButton

# Guh v2
var chain_names: PackedStringArray = [
	"chain_5p",
	"chain_6p",
	"chain_5k",
	"chain_fs",
	"chain_cs",
	"chain_5h",
	"chain_6h",
	"chain_2p",
	"chain_2k",
	"chain_2d",
	"chain_2s",
	"chain_2h",
	"chain_jp",
	"chain_jk",
	"chain_js",
	"chain_jh",
	"chain_unk16",
	"chain_j2k",
	"chain_3p",
	"chain_unk19",
	"chain_unk20",
	"chain_6k",
	"chain_j2s",
	"chain_3s",
	"chain_3k",
	"chain_3h",
	"chain_j2h",
	"chain_unk27",
	"chain_unk28",
	"chain_unk29",
	"chain_unk30",
	"chain_unk31",
]

var entry: String

@onready var var_edit: VariableEdit = owner
@onready var play_data: PlayData = var_edit.play_data
@onready var popup: PopupMenu = get_popup()


func _ready() -> void:
	var_edit.table_entry_changed.connect(on_table_entry_changed)
	var_edit.chain_table_changed.connect(update)
	
	entry = chain_names[get_index()]
	
	popup.hide_on_checkable_item_selection = false
	popup.id_pressed.connect(on_item_clicked)
	
	popup.add_check_item("5P")
	popup.add_check_item("6P")
	popup.add_check_item("5K")
	popup.add_check_item("f.S")
	popup.add_check_item("c.S")
	popup.add_check_item("5H")
	popup.add_check_item("6H")
	popup.add_check_item("2P")
	popup.add_check_item("2K")
	popup.add_check_item("2D")
	popup.add_check_item("2S")
	popup.add_check_item("2H")
	popup.add_check_item("j.P")
	popup.add_check_item("j.K")
	popup.add_check_item("j.S")
	popup.add_check_item("j.H")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	popup.add_check_item("j.2K")
	popup.add_check_item("3P")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	popup.add_check_item("6K")
	popup.add_check_item("j.2S")
	popup.add_check_item("3S")
	popup.add_check_item("3K")
	popup.add_check_item("3H")
	popup.add_check_item("j.2H")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	popup.add_check_item("CHAIN_TABLE_UNKNOWN")
	
	update()


func on_item_clicked(id: int) -> void:
	popup.toggle_item_checked(id)
	var_edit.set_chain_table_bit(entry, id, popup.is_item_checked(id))


func on_table_entry_changed(entry_name: String, bit: int, value: bool) -> void:
	if entry_name != entry:
		return
	
	popup.set_item_checked(bit, value)


func update() -> void:
	for item in popup.item_count:
		popup.set_item_checked(item, var_edit.get_chain_table_bit(entry, item))
