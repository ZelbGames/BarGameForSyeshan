extends StaticBody3D

@export var glass_contents : Dictionary[String, float] = {}
@export var total_liquid : float = 0.0

func _ready() -> void:
	var all_bottles : Array[Node] = get_tree().get_nodes_in_group("Bottles")
	for bottle in all_bottles:
		bottle.pouring_drink.connect(pour_drink)
		bottle.stop_pouring.connect(stop_pouring)

var should_pour = false
var current_drink_name : String 
var current_pour_speed : float = 0.0

func _process(delta: float) -> void:
	if should_pour and current_drink_name:
		var current_contents = glass_contents.get_or_add(current_drink_name,0.0)
		glass_contents.set(current_drink_name,current_contents + current_pour_speed * delta)
		total_liquid += current_pour_speed * delta
		print(glass_contents)

func pour_drink(drink_name : String, pour_speed : float) -> float:
	current_drink_name = drink_name
	current_pour_speed = pour_speed
	should_pour = true
	print("Pouring: " + drink_name + " at a speed of " + str(pour_speed) + " per second")
	return 0.0

func stop_pouring() -> void:
	should_pour = false
