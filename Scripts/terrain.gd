extends Path2D
class_name Terrain

#region Variables
@export_group("Line")
@export var line_color: Color = Color.BLACK
@export var line_texture: Texture2D
@export var line_width: float = 5.0

@export_group("Polygon")
@export var polygon_color: Color = Color.WHITE
@export var polygon_texture: Texture2D
@export var polygon_texture_scale: Vector2 = Vector2.ONE

@export_group("Body")
@export var collision_enabled: bool = true
@export_flags_2d_physics var collision_layer: int
@export_flags_2d_physics var collison_mask: int

@export_group("Up Line")
@export var has_up_line: bool
@export var up_angle: Vector2 = Vector2(-30.0, 30.0)
@export var up_line_color: Color = Color.BLACK
@export var up_line_texture: Texture2D
@export var up_line_width: float = 10.0
#endregion

func _ready() -> void:
	#Setup
	var parent := get_parent()
	var static_body := StaticBody2D.new()
	var current_name = name
	name = current_name + "Path"
	
	#StaticBody2D
	static_body.name = current_name
	static_body.z_index = z_index
	parent.add_child.call_deferred(static_body)
	await static_body.ready
	static_body.global_position = global_position
	static_body.collision_layer = collision_layer
	static_body.collision_mask = collison_mask
	
	#Path2D
	reparent.call_deferred(static_body)
	z_as_relative = true
	z_index = 0
	
	var polygons = curve.get_baked_points()
	
	#Collision
	if collision_enabled:
		var collision_polygon := CollisionPolygon2D.new()
		collision_polygon.name = name + "CollisionPolygon"
		static_body.add_child(collision_polygon)
		collision_polygon.global_position = global_position
		collision_polygon.polygon = polygons
		collision_polygon.z_as_relative = true
	
	#Appearances
	var polygon := Polygon2D.new()
	var line := Line2D.new()
	
	polygon.name = current_name + "Polygon"
	static_body.add_child(polygon)
	polygon.global_position = global_position
	polygon.polygon = polygons
	polygon.color = polygon_color
	polygon.texture = polygon_texture
	polygon.texture_scale = polygon_texture_scale
	polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	polygon.z_as_relative = true
	polygon.z_index = 1

	line.name = current_name + "Line"
	static_body.add_child(line)
	line.global_position = global_position
	line.points = polygons
	line.default_color = line_color
	line.texture = line_texture
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.width = line_width
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.z_as_relative = true
	line.z_index = 2
	
	#Upper Side
	if has_up_line:
		var pre_point: Vector2
		var has_pre_point := false
		var segments: Array[PackedVector2Array] = []
		var current_segment: PackedVector2Array = []

		for p in polygons:
			if not has_pre_point:
				pre_point = p
				has_pre_point = true
				continue
			var dir := (p - pre_point).normalized()
			var normal := Vector2(-dir.y, dir.x)
			var angle_deg := rad_to_deg(normal.angle_to(Vector2.DOWN))
			if angle_deg >= up_angle.x and angle_deg <= up_angle.y:
				if current_segment.is_empty():
					current_segment.append(pre_point)
				current_segment.append(p)
			else:
				if not current_segment.is_empty():
					segments.append(current_segment)
					current_segment = []
			pre_point = p

		if not current_segment.is_empty():
			segments.append(current_segment)

		for i in segments.size():
			var up_line := Line2D.new()
			up_line.name = current_name + "UpLine" + str(i)
			static_body.add_child(up_line)
			up_line.global_position = global_position
			up_line.points = segments[i]
			up_line.default_color = up_line_color
			up_line.texture = up_line_texture
			up_line.texture_mode = Line2D.LINE_TEXTURE_TILE
			up_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			up_line.width = up_line_width
			up_line.joint_mode = Line2D.LINE_JOINT_ROUND
			up_line.begin_cap_mode = Line2D.LINE_CAP_ROUND if not up_line_texture else Line2D.LINE_CAP_NONE
			up_line.end_cap_mode = Line2D.LINE_CAP_ROUND if not up_line_texture else Line2D.LINE_CAP_NONE
			up_line.z_as_relative = true
			up_line.z_index = 3
