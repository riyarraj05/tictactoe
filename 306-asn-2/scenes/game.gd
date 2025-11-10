extends Control


@onready var turn_label = $TurnLabel
@onready var board_view = $BoardView
@onready var new_game_button = $NewGameButton
@onready var result_dialog = $ResultDialog

var empty_sprite_path: String = "res://assets/asn2edited.png"
var x_sprite_path: String = "res://assets/x.png"
var o_sprite_path: String = "res://assets/o.png"


var empty_texture: Texture2D
var x_texture: Texture2D
var o_texture: Texture2D

var board = [] 
var current_player = 1  # 1 = X, 2 = O
var game_over = false

var cell_buttons = []

func _ready():
	empty_texture = load(empty_sprite_path)
	x_texture = load(x_sprite_path)
	o_texture = load(o_sprite_path)
	
	for i in range(9):
		board.append(0)
	
	for i in range(9):
		var button = board_view.get_node("Cell_" + str(i))
		cell_buttons.append(button)
		button.pressed.connect(_on_cell_pressed.bind(i))
	

	new_game_button.pressed.connect(_on_new_game_pressed)
	
	update_ui()

func _on_cell_pressed(index: int):

	if game_over or board[index] != 0:
		return
	

	board[index] = current_player
	

	var winner = check_winner()
	if winner != 0:
		game_over = true
		if winner == 3:  # Draw
			result_dialog.dialog_text = "It's a Draw!"
		else:
			var player_name = "X" if winner == 1 else "O"
			result_dialog.dialog_text = "Player " + player_name + " Wins!"
		result_dialog.popup_centered()
	else:
		# Switch player
		current_player = 3 - current_player  # Switches between 1 and 2
	
	update_ui()

func check_winner() -> int:
	# All possible winning combinations
	var winning_lines = [
		[0, 1, 2], [3, 4, 5], [6, 7, 8],  # Rows
		[0, 3, 6], [1, 4, 7], [2, 5, 8],  # Columns
		[0, 4, 8], [2, 4, 6]              # Diagonals
	]
	
	# Check each winning combination
	for line in winning_lines:
		var a = line[0]
		var b = line[1]
		var c = line[2]
		
		if board[a] != 0 and board[a] == board[b] and board[a] == board[c]:
			return board[a]  # Return 1 (X) or 2 (O)
	
	# Check for draw (all cells filled)
	var is_full = true
	for cell in board:
		if cell == 0:
			is_full = false
			break
	
	if is_full:
		return 3  # Draw
	
	return 0  # Game continues

func update_ui():
	# Update turn label
	if game_over:
		turn_label.text = "Game Over"
	else:
		var player_name = "X" if current_player == 1 else "O"
		turn_label.text = "Turn: " + player_name
	
	# THIS IS THE KEY PART - Update each button's sprite
	for i in range(9):
		var button = cell_buttons[i]
		
		# Choose which texture to use based on board state
		var texture: Texture2D
		match board[i]:
			0:  # Empty cell
				texture = empty_texture
			1:  # X player
				texture = x_texture
			2:  # O player
				texture = o_texture
		
		# Create a new StyleBoxTexture with the chosen sprite
		var style_box = StyleBoxTexture.new()
		style_box.texture = texture
		
		# Apply the style to the button (all states)
		button.add_theme_stylebox_override("normal", style_box)
		button.add_theme_stylebox_override("hover", style_box)
		button.add_theme_stylebox_override("pressed", style_box)

func _on_new_game_pressed():
	# Reset everything
	for i in range(9):
		board[i] = 0
	current_player = 1
	game_over = false
	update_ui()
