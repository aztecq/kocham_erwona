class_name ArtifactRenderer extends Node2D

# One sprite per find, keyed by the find itself. They start hidden: a find shows the
# moment the ground it was buried in comes off, and goes for good when it's picked up.
var _sprites := {}

func bind(artifacts: ArtifactData, terrain_renderer: TerrainRenderer) -> void:
	for sprite in _sprites.values():
		remove_child(sprite)
		sprite.queue_free()
	_sprites.clear()

	for artifact in artifacts.artifacts:
		var sprite := Sprite2D.new()
		sprite.texture = ArtifactTypes.texture(artifact.file)
		sprite.visible = artifacts.is_unearthed(artifact)
		add_child(sprite)
		# Set once in the tree, where global_position means something. Sprite2D centres
		# its texture, and the finds are a tile across, so the cell centre is the spot.
		sprite.global_position = terrain_renderer.global_at_cell(artifact.cell)
		_sprites[artifact] = sprite

	artifacts.artifact_unearthed.connect(_on_unearthed)
	artifacts.artifact_taken.connect(_on_taken)
	artifacts.artifact_degraded.connect(_on_degraded)

func _on_unearthed(artifact: ArtifactData.Artifact) -> void:
	_sprites[artifact].visible = true

func _on_degraded(artifact: ArtifactData.Artifact, _lost: int) -> void:
	_sprites[artifact].texture = ArtifactTypes.texture(artifact.file)

func _on_taken(artifact: ArtifactData.Artifact) -> void:
	var sprite: Sprite2D = _sprites[artifact]
	_sprites.erase(artifact)
	remove_child(sprite)
	sprite.queue_free()
