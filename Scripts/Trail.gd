extends MeshInstance3D

var points = PackedVector3Array()
var widths = []

@export var width : float = 0.05
@export var timeForSpawn : float = 0.1
@export var collider : CollisionShape3D
@export var bikeMesh : Node3D

var concaveShape : ConcavePolygonShape3D
var oldPos : Vector3

func _ready():
	oldPos = global_position
	concaveShape = collider.shape

func _process(delta):
	calculateMesh()
	calculateCollisions()
	rotation = bikeMesh.rotation #FIXME: You shuld not do this plz
	rotation.x += 80
	
func calculateCollisions():
	var localPoints = PackedVector3Array()
	for point in points:
		localPoints.append(to_local(point))
	concaveShape.set_faces(localPoints)

#func calculateCollisions(): #This doesn't work
	#var localPoints = PackedVector3Array()
	#
	#var n : int = 0
	#var add : bool = true
	#for point in points:
		#if add:
			#localPoints.append(to_local(point))
		#
		#if n >= 6:
			#add = !add
			#n = 0
		#n += 1
	#
	#concaveShape.set_faces(localPoints)

func calculateMesh():
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
			var localPoint1 : Vector3 = to_local(points[i] + currWidth)
			mesh.surface_add_vertex(localPoint1)
			
			mesh.surface_set_uv(Vector2(t1, 1))
			var localPoint2 : Vector3 = to_local(points[i] - currWidth)
			mesh.surface_add_vertex(localPoint2)
			
			#calculateCollisions() #Doesn't work
		
		mesh.surface_end()

func appendPoint():
	points.append(global_position)
	widths.append([
		global_transform.basis.z * width
	])


#func _on_timer_timeout():
	##calculateCollisions()
	#if get_child_count() > 0:
		#for i in get_children():
			#i.queue_free()
	#create_multiple_convex_collisions()


func _on_static_body_3d_body_entered(body):
	print(get_parent().name+" "+body.name)
