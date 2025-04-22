extends Resource

class_name bgm

@export var name : String
@export var key : String

@export var loop : AudioStream
@export var volume_linear : float = 1.0

@export var author : String
@export var license : LICENSE
@export var source : String

enum LICENSE {
	CC0,
	OGA_BY_3,
	OGA_BY_4,
}

static func license_to_string(license : LICENSE) -> String :
	match license :
		LICENSE.CC0 : return "CC0"
		LICENSE.OGA_BY_3 : return "OGA-BY-3.0"
		LICENSE.OGA_BY_4 : return "OGA-BY-4.0"
		_: return "Unknown"
