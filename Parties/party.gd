extends Resource
class_name PoliticalParty


export(String) var party_name
export(Texture) var symbol
export(int) var votes
export(Vector2) var political_pos = Vector2(0, 0)


func _ready():
	pass


func addVoter(pos: Vector2, n: int, new_votes: int):
	political_pos = (political_pos + pos) / n
	votes += new_votes


func removeVoter(pos: Vector2, n: int, old_votes: int):
	political_pos = (political_pos - pos) / (n - 1)
	votes -= old_votes
