extends PanelContainer

@onready var title = $MarginContainer/VBoxContainer/Title
@onready var artist = $MarginContainer/VBoxContainer/Artist
@onready var source = $MarginContainer/VBoxContainer/Source
@onready var license = $MarginContainer/VBoxContainer/License
@onready var play_button = $MarginContainer/VBoxContainer/Button

func populate(music_info : bgm) :
	title.text = music_info.name
	artist.text = music_info.author
	license.text = "License : " + bgm.license_to_string(music_info.license)
	source.text = "[center][u][url=%s]%s[/url][/u][/center]" % [music_info.source, music_info.source]
	
	play_button.song_data = music_info
