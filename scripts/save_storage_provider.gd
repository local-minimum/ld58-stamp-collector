extends Node
class_name SaveStorageProvider

@warning_ignore_start("unused_parameter")
func store_data(slot: int, save_data: Dictionary) -> bool:
    return false

func retrieve_data(slot: int, silence_non_exist: bool) -> Dictionary:
    return {}
@warning_ignore_restore("unused_parameter")
