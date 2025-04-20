extends Node

func _ready():
	# when _ready is called, there might already be nodes in the tree, so connect all existing buttons
	connect_buttons(get_tree().root)
	get_tree().node_added.connect(_on_SceneTree_node_added)

func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)

func _on_Button_pressed():
	$ButtonPressed.pitch_scale = randf_range(0.9,1.1)
	$ButtonPressed.play()

func _on_Button_hover() :
	$ButtonHover.pitch_scale = randf_range(0.95,1.05)
	$ButtonHover.play()

# recursively connect all buttons
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(button):
	if not button.mouse_entered.is_connected(_on_Button_hover) :
		button.mouse_entered.connect(_on_Button_hover)
	if not button.pressed.is_connected(_on_Button_pressed) :
		button.pressed.connect(_on_Button_pressed)
