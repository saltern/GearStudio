class_name Session extends Resource

signal palette_changed

enum Type {
	BINARY,
	DIRECTORY,
}

var archive			: BinArchive		= BinArchive.new()
var path			: String			= ""
var type			: Type				= Type.BINARY
var current_object	: int				= 0
var reindex_mode	: bool				= Settings.general_reindex_mode

var palettes		: BinSpriteBlock
# For previews
var palette_index	: int				= 0


func _init(p_path: String) -> void:
	var file: FileAccess = FileAccess.open(p_path, FileAccess.READ)
	
	if file == null:
		var error := FileAccess.get_open_error()
		match error:
			ERR_FILE_CANT_OPEN:
				print("Couldn't open file!")
			_:
				print(error)
		
		return
	
	var data: PackedByteArray = file.get_buffer(file.get_length())
	data = BinDecrypter.decrypt_file(p_path.get_file(), data)
	
	# Endianness check
	var is_big_endian: bool = false
	var pointers_le: PackedInt64Array = BinObject.get_pointers(data, false)
	
	var padded_size: int = 4 * (pointers_le.size() / 4) + 4
	
	if pointers_le[0] != 4 * padded_size:
		is_big_endian = true
	
	archive.deserialize(data, is_big_endian)
	
	if archive.get_object_count() < 1:
		Status.set_status.bind("STATUS_LOAD_INVALID").call_deferred()
		return
	
	# Set palettes
	if archive.get_object(0) is BinScriptable:
		var player: BinScriptable = archive.get_object(0)
		if player.has_palettes():
			palettes = player.palettes
	
	path = p_path


func get_object_count() -> int:
	return archive.get_object_count()


func get_object(index: int) -> BinObject:
	return archive.get_object(index)


func has_palettes() -> bool:
	return palettes != null


func set_palette(index: int) -> void:
	palette_index = index
	palette_changed.emit(index)


func get_palette(index: int) -> PackedByteArray:
	return palettes.get_palette(index)
