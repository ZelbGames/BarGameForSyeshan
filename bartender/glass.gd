extends StaticBody3D

@export var glass_contents : Dictionary[String, float] = {}
var drink_colours : Dictionary[String, Color]
var tinting_strength : Dictionary[String, float] = {}
@export var current_liquid : float = 0.0
@export var max_liquid : float = 130.0

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
		current_liquid = clampf(current_liquid + current_pour_speed * delta, 0.0 , max_liquid)
		if current_liquid < max_liquid:
			var new_contents = clampf(current_contents + current_pour_speed * delta,0.0, max_liquid)
			glass_contents.set(current_drink_name, new_contents)


func pour_drink(drink_name : String, pour_speed : float, drink_colour : Color) -> float:
	if !drink_colours.has(drink_name):
		drink_colours.get_or_add(drink_name,drink_colour)
		var luminence_factor = get_inverse_brightness(drink_colour)
		tinting_strength.get_or_add(drink_name, luminence_factor)
	current_drink_name = drink_name
	current_pour_speed = pour_speed
	should_pour = true
	print("Pouring: " + drink_name + " at a speed of " + str(pour_speed) + " per second")
	update_liquid.start(0.0)
	return 0.0

func stop_pouring() -> void:
	update_liquid.stop()
	should_pour = false

func get_inverse_brightness(col: Color) -> float:
	var luminance = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b
	return clampf(1.0 - luminance, 0.0, 1.0)

func mix_colours() -> Color:
	var colours : Array[Color] 
	var weights : Array[float]
	for drink_name in glass_contents:
		var col = drink_colours.get(drink_name, Color.WHITE)
		var w = clamp(tinting_strength[drink_name] * glass_contents[drink_name]/current_liquid * 2, 0.0, 1.0)
		colours.append(col)
		weights.append(w)
	var final_colour = mix_n_colours(colours, weights)
	final_colour.a = 0.8
	return final_colour

func mix_n_colours(colors: Array[Color], weights: Array[float] = []) -> Color:
	if colors.is_empty(): return Color.BLACK
	
	var n := colors.size()
	var w_sum := 0.0
	for i in range(n): w_sum += weights[i] if i < weights.size() else 1.0
	
	var cmyk_acc := Vector4.ZERO
	var alpha_acc := 0.0

	for i in range(n):
		var col := colors[i]
		var w := (weights[i] if i < weights.size() else 1.0) / (w_sum if w_sum > 0 else 1.0)
		var k := 1.0 - maxf(col.r, maxf(col.g, col.b))
		var d := 1.0 - k
		var cmy := Vector3(1 - col.r - k, 1 - col.g - k, 1 - col.b - k) / d if d > 0 else Vector3.ZERO
		
		cmyk_acc += Vector4(cmy.x, cmy.y, cmy.z, k) * w
		alpha_acc += col.a * w

	var r := (1.0 - cmyk_acc.x) * (1.0 - cmyk_acc.w)
	var g := (1.0 - cmyk_acc.y) * (1.0 - cmyk_acc.w)
	var b := (1.0 - cmyk_acc.z) * (1.0 - cmyk_acc.w)

	return Color(r, g, b, alpha_acc).clamp()



@export var liquid : MeshInstance3D
func set_colour_and_fill() -> void:
	var colour = mix_colours()
	liquid.get_active_material(0).set_shader_parameter("_FillColor", colour)
	colour.s = clampf(colour.s - 0.1,0.0, 1.0)
	liquid.get_active_material(0).set_shader_parameter("_SurfaceColor", colour)
	var fill_level = (current_liquid/max_liquid * 2) - 1. 
	liquid.get_active_material(0).set_shader_parameter("_FillLevel", fill_level)

@onready var update_liquid: Timer = $UpdateLiquid
