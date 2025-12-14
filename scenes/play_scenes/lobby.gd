extends Node2D

func _on_loaded_avatar(id: int, size: int, buffer : PackedByteArray) -> void:
	print("Avatar for user: %s" % id)
	print("Size: %s" % size)
	var avatar_image : Image = Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)
	var avatar_texture : ImageTexture = ImageTexture.new()
	avatar_texture = ImageTexture.create_from_image(avatar_image)
	$TextureRect.texture = avatar_texture


func _ready() -> void:
	print("scene loaded")
	Steam.getPlayerAvatar()
	$RichTextLabel.text = Steam.getPersonaName()
	Steam.avatar_loaded.connect(_on_loaded_avatar)
