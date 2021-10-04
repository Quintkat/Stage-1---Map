extends Node


func vectInt(v : Vector2):
	return Vector2(int(v[0]), int(v[1]))

func mod(v: Vector2, m : int):
	return Vector2(int(v[0])%m, int(v[1])%m)
