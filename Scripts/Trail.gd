extends MeshInstance3D

@export var spacing = 10

var points = []
var widths = []

@export var width : float = 0.1
@export var timeForSpawn : float = 0.1

var oldPos : Vector3

func _ready():
	oldPos = global_position
	#draw_line(Vector3.ZERO, Vector3(0, 100, 0), 1)

func _process(delta):
	if (oldPos - global_position).length() > timeForSpawn:
		appendPoint()
		oldPos = global_position
	
	if mesh is ImmediateMesh:
		mesh.clear_surfaces()
		#If there are no more than two points, don't render it
		if points.size() < 2:
			return
		
		#Render a new mesh based on the positions of each point and their current width
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for i in range(points.size()):
			var t = float(i) / (points.size() - 1.0)
			
			var currWidth = widths[i][0]
			
			var t0 = i / points.size()
			var t1 = t
			
			mesh.surface_set_uv(Vector2(t0, 0))
			mesh.surface_add_vertex(to_local(points[i] + currWidth))
			mesh.surface_set_uv(Vector2(t1, 1))
			mesh.surface_add_vertex(to_local(points[i] - currWidth))
		
		mesh.surface_end()
		

func appendPoint():
	points.append(global_position)
	widths.append([
		global_transform.basis.z * width
	])

#
#func draw_line(pointA : Vector3, pointB : Vector3, thickness : float = 2.0):
	#pointB = pointA + pointB
	#
	#if pointA.is_equal_approx(pointB):
		#return
	#
	#if mesh is ImmediateMesh:
		#mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		#
		#var scaleFactor : float = 100.0
		#
		#var dir := pointA.direction_to(pointB)
		#var EPSILON = 0.00001
		#
		##Draw cube line
		#var normal := Vector3(-dir.y, dir.x, 0).normalized() \
			#if (abs(dir.x) + abs(dir.y) > EPSILON) \
			#else Vector3(0, -dir.z, dir.y).normalized()
		#normal *= thickness / scaleFactor
		#
		#var verticesStripOrder = [4, 5, 0, 1, 2, 5, 6, 4, 7, 0, 3, 2, 7, 6]
		#var localB = (pointB - pointA)
		#
		##Calculates mesh at origin
		#for v in range(14):
			#var vertex = normal if \
				#verticesStripOrder[v] < 4 else \
				#normal + localB
			#var finalVert = vertex.rotated(dir, 
				#PI * (0.5 * (verticesStripOrder[v] % 4) + 0.25))
			##Offset to real position
			#finalVert += pointA
			#mesh.surface_add_vertex(finalVert)
		#mesh.surface_end()
