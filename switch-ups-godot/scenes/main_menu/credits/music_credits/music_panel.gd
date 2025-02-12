extends PanelContainer

@onready var title = $MarginContainer/VBoxContainer/Title
@onready var artist = $MarginContainer/VBoxContainer/Artist
@onready var source = $MarginContainer/VBoxContainer/Source
@onready var license = $MarginContainer/VBoxContainer/License
@onready var play_button = $MarginContainer/VBoxContainer/Button

var current_info : bgm

func _notification(what: int) -> void:
	match what :
		NOTIFICATION_TRANSLATION_CHANGED :
			populate_translatable()

func populate_translatable() :
	if not current_info == null : license.text = tr("TR_CREDIT_LICENSE_PERSON").format({"license":bgm.license_to_string(current_info.license)})

func populate(music_info : bgm) :
	current_info = music_info
	title.text = music_info.name
	artist.text = music_info.author
	source.text = "[center][u][url=%s]%s[/url][/u][/center]" % [music_info.source, music_info.source]
	
	play_button.song_data = music_info
	populate_translatable()
