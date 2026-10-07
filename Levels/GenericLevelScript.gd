extends Node3D

func _ready() -> void:
	_generate_level_collisions(self)

func _generate_level_collisions(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			_attach_primitive_collision(child)
		
		# Recursively scan sub-children
		if child.get_child_count() > 0:
			_generate_level_collisions(child)

func _attach_primitive_collision(mesh_inst: MeshInstance3D) -> void:
	# Skip if a collision body already exists on or under this mesh
	if mesh_inst.get_parent() is PhysicsBody3D or mesh_inst.has_node("AutoStaticBody"):
		return

	var shape: Shape3D = _create_matching_shape(mesh_inst.mesh)
	if not shape:
		return

	# Build StaticBody3D and CollisionShape3D
	var static_body: StaticBody3D = StaticBody3D.new()
	static_body.name = "AutoStaticBody"
	
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	col_shape.shape = shape
	
	# Attach to scene tree
	mesh_inst.add_child(static_body)
	static_body.add_child(col_shape)

func _create_matching_shape(mesh: Mesh) -> Shape3D:
	if mesh is BoxMesh:
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = (mesh as BoxMesh).size
		return box_shape
		
	elif mesh is SphereMesh:
		var sphere_shape: SphereShape3D = SphereShape3D.new()
		sphere_shape.radius = (mesh as SphereMesh).radius
		return sphere_shape
		
	elif mesh is CylinderMesh:
		var cyl_mesh: CylinderMesh = mesh as CylinderMesh
		var cyl_shape: CylinderShape3D = CylinderShape3D.new()
		cyl_shape.height = cyl_mesh.height
		cyl_shape.radius = maxf(cyl_mesh.top_radius, cyl_mesh.bottom_radius)
		return cyl_shape
		
	elif mesh is CapsuleMesh:
		var cap_mesh := mesh as CapsuleMesh
		var cap_shape := CapsuleShape3D.new()
		cap_shape.height = cap_mesh.height
		cap_shape.radius = cap_mesh.radius
		return cap_shape
		
	else:
		# Fast convex fallback for Prisms, Toruses, or custom shapes
		return mesh.create_convex_shape()
