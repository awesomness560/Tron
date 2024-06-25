extends MeshInstance3D

@export var your_radius = 20

var points := []
var max_points = 20

#func _ready():
	## Initialize points and collision shape (if applicable)
	#points = []
	#max_points = 20  # Adjust as needed

func _physics_process(delta):
	# Update trail points based on parent's position
	if points.size() >= max_points:
		points.pop_front()  # Remove oldest point if exceeding limit

	points.append(get_parent().global_translate)

	# Update MeshInstance vertices (replace with your preferred update logic)
	update_mesh_vertices()  # Defined below

func update_mesh_vertices():
	# Update MeshInstance vertices based on the stored points array
	# This example assumes a simple tube mesh with two vertices per segment
	var vertices = []
	for i in range(points.size() - 1):
		# Calculate positions for current and next points with desired radius offset
		var current_pos = points[i] + Vector3(0, 0, your_radius)  # Adjust offset as needed
		var next_pos = points[i + 1] + Vector3(0, 0, your_radius)
		vertices.append(current_pos)
		vertices.append(next_pos)

	# Update Mesh data
	mesh.set_data(Mesh.DATA_VERTEX, vertices)
