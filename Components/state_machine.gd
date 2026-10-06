extends Node
class_name StateMachine

@export var debug_mode: bool = false
#@export var show_state_label: bool = false
#@export var debug_state_label: Label

@export var initial_state: State

var current_state: State
var states: Dictionary[String, State] = {}

# conner added this. sorry if it breaks something
var is_frozen: bool = false

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			child.setup()
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	else:
		printerr("ERROR: no initial state set")
		
	if debug_mode:
		print("Current State: ", current_state)
		print("All States: \n",  states)
	#debug_state_label.visible = show_state_label


func _process(delta: float) -> void:
	if is_frozen:
		return
	
	if current_state:
		current_state.update(delta)
		
		#if show_state_label:
			#debug_state_label.text = current_state.name
		
func _physics_process(delta: float) -> void:
	if is_frozen:
		return
	
	if current_state:
		current_state.physics_update(delta)
		
		#if show_state_label:
			#debug_state_label.text = current_state.name



func on_child_transition(state: State, new_state_name: String) -> void:
	# called state not current state
	if state != current_state:
		return
		
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state: # exists check
		printerr(str(
			"cannot transition, new state does not exist\n",
			owner.name + ": " + state.name + " -> " + new_state_name+"\n",
		))
		return
		
	if current_state:
		current_state.exit()
	
	current_state = new_state
	
	new_state.enter()
	
	if debug_mode:
		print(owner.name + ": " + state.name + " -> " + new_state.name)
		
	
