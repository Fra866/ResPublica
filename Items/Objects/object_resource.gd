extends Resource
class_name object_resource

export(String) var name
export(int) var id
export(String) var description
export(int) var prize
export(Texture) var texture
export(Script) var use_script


func ready():
	print(use_script)
