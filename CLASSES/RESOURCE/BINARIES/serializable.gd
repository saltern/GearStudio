@abstract class_name Serializable extends Resource

var semaphore: Semaphore = Semaphore.new()

var big_endian: bool

@abstract func serialize() -> PackedByteArray
@abstract func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void
