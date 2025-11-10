extends Control

# References to UI nodes
@onready var turn_label = $TurnLabel
@onready var board_view = $BoardView
@onready var new_game_button = $NewGameButton
@onready var result_dialog = $ResultDialog

# Game state
var board = []  # Will hold "X", "O", or ""
var current_player = "X"
var game_over = false

# Cell buttons
var cell_buttons = []

func _ready():
	# Initialize the board with 9 empty strings
	for i in range(9):
		board.append("")
	
	# Get all cell buttons
	for i in range(9):
		var button = board_view.get_node("Cell_" + str(i))
		cell_buttons.append(button)
		# Connect each button's pressed signal to our function
		button.pressed.connect(_on_cell_pressed.bind(i))
	
	# Connect new game button
	new_game_button.pressed.connect(_on_new_game_pressed)
	
	update_ui()

func _on_cell_pressed(index: int):
	# Don't do anything if game is over or cell is taken
	if game_over or board[index] != "":
		return
	
	# Place the current player's mark
	board[index] = current_player
	
	# Check for winner
	var winner = check_winner()
	if winner != "":
		game_over = true
		if winner == "Draw":
			result_dialog.dialog_text = "It's a Draw!"
		else:
			result_dialog.dialog_text = "Player " + winner + " Wins!"
		result_dialog.popup_centered()
	else:
		# Switch player
		if current_player == "X":
			current_player = "O"
		else:
			current_player = "X"
	
	update_ui()

func check_winner() -> String:
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
		
		if board[a] != "" and board[a] == board[b] and board[a] == board[c]:
			return board[a]  # Return "X" or "O"
	
	# Check for draw (all cells filled)
	var is_full = true
	for cell in board:
		if cell == "":
			is_full = false
			break
	
	if is_full:
		return "Draw"
	
	return ""  # Game continues

func update_ui():
	# Update turn label
	if game_over:
		turn_label.text = "Game Over"
	else:
		turn_label.text = "Turn: " + current_player
	
	# Update all cell buttons
	for i in range(9):
		cell_buttons[i].text = board[i]

func _on_new_game_pressed():
	# Reset everything
	for i in range(9):
		board[i] = ""
	current_player = "X"
	game_over = false
	update_ui()
