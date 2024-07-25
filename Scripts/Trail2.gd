extends MeshInstance3D

@export var collision : Node3D
@export var width : float = .05
@export var timeForSpawn : float = 0.1
@export var bikeMesh : Node3D
@export var parent : Node3D
@export var trailColor := Color8(0,235,243,255)
@export var trailSpawnNode : Node3D
@export var miniMapMarker : MeshInstance3D
@export var minimapTrail : MeshInstance3D
var points := PackedVector3Array() 
var widths := []
var oldPos : Vector3
var minimapPoints := PackedVector3Array()

func _ready():
	material_override.set_albedo(trailColor)
	material_override.emission = trailColor
	
	minimapTrail.material_override.set_albedo(trailColor)
	minimapTrail.material_override.emission = trailColor
	
	miniMapMarker.mesh.material.set_albedo(trailColor)
	miniMapMarker.mesh.material.emission = trailColor
	
	
func _process(delta):
	calculateMesh()
	generate_minimapTrail()
	if self.position.y < -70:
		self.position = Vector3(0,0,0)
		self.velocity = Vector3(0,0,0)
		
func _GenerateMesh(verts : PackedVector3Array, uvs : PackedVector2Array):
	var surface_array= []
	
	var x = verts.duplicate() 
	verts.reverse()
	verts.append_array(x)
	
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = verts
	
	var uvs2 = uvs.duplicate()

	uvs.reverse()
	uvs.append_array(uvs2)
	
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	var arrMesh = ArrayMesh.new()
	arrMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)
	mesh = arrMesh
	collision.shape.set_faces(mesh.get_faces())
	
func appendPoint():
	points.append(trailSpawnNode.global_position)
	widths.append([
		trailSpawnNode.global_transform.basis.z * width
	])
func calculateMesh():
	if (oldPos - trailSpawnNode.global_position).length() > timeForSpawn:
		appendPoint()
		oldPos = trailSpawnNode.global_position
	
		mesh.clear_surfaces()
		
		#If there are no more than two points, don't render it
		if points.size() < 2:
			return
		var uvs := PackedVector2Array()
		var vertices := PackedVector3Array()
		for i in range(points.size()):
			var t = float(i) / (points.size() - 1.0)
			
			var currWidth = widths[i][0]
			
			var t0 = i / points.size()
			var t1 = t
			
			uvs.append(Vector2(t0, 0))
			var localPoint1 : Vector3 = to_local(points[i] + currWidth)
			vertices.append(localPoint1)
			
			uvs.append(Vector2(t1, 1))
			var localPoint2 : Vector3 = to_local(points[i] - currWidth)
			vertices.append(localPoint2)
			
			
		_GenerateMesh(vertices, uvs)
			

func generate_minimapTrail():
	minimapTrail.mesh.clear_surfaces()
		
	if points.size() < 2:
			return
	var uvs := PackedVector2Array()
	var vertices := PackedVector3Array()
	for i in range(points.size()):
		var t = float(i) / (points.size() - 1.0)
		
		var currWidth = Vector3(0.06,0,0)
		
		var t0 = i / points.size()
		var t1 = t
		
		uvs.append(Vector2(t0, 0))
		var localPoint1 : Vector3 = to_local(points[i] + currWidth)
		vertices.append(localPoint1)
		
		uvs.append(Vector2(t1, 1))
		var localPoint2 : Vector3 = to_local(points[i] - currWidth)
		vertices.append(localPoint2)
	var surface_array= []
	
	var x = vertices.duplicate() 
	vertices.reverse()
	vertices.append_array(x)
	
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	
	var uvs2 = uvs.duplicate()

	uvs.reverse()
	uvs.append_array(uvs2)
	
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	var arrMesh = ArrayMesh.new()
	arrMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)
	minimapTrail.mesh = arrMesh
	
func _on_area_3d_body_entered(body):
	if body != parent:
		body.Respawn()

func _on_timer_timeout():
	self.visible = true

func _delete_trail():
	points.clear()
	widths.clear()
	mesh.clear_surfaces()
	collision.shape.set_faces(PackedVector3Array())
		
