extends Node2D


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	# A restrained backdrop keeps attention on silhouette, frame alignment, and weapon motion.
	draw_rect(Rect2(-2600, -400, 5200, 1600), Color("111117"))
	draw_rect(Rect2(-2600, 80, 5200, 700), Color("18171d"))
	for x in range(-2500, 2501, 420):
		draw_rect(Rect2(x, 170, 250, 610), Color("1e1d24"))
		draw_rect(Rect2(x + 28, 205, 194, 575), Color("15151a"))
	draw_rect(Rect2(-2600, 640, 5200, 140), Color("232129"))
	draw_rect(Rect2(-2600, 780, 5200, 330), Color("2b282e"))
	draw_rect(Rect2(-2600, 800, 5200, 26), Color("4a4243"))
	for x in range(-2600, 2600, 190):
		var shade := Color("343037") if posmod(x / 190, 2) == 0 else Color("2f2b32")
		draw_rect(Rect2(x + 6, 830, 178, 220), shade)
