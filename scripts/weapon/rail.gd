extends Spatial

export(NodePath) var timer

var speed: float = 200


func _ready() -> void:
	$mesh.translation.z = -$mesh.mesh.mid_height / 2
	var timer_node = get_node(timer)
	timer_node.connect("timeout", self, "queue_free")


func _process(_delta) -> void:
	translation -= (global_transform.basis.z * speed) * _delta
