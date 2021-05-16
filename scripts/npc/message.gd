extends Resource
class_name Message

enum Character {
	Nathaniel,
	Janice,
	Ferguson,
	Kitty
}

enum Emotion {
	Neutral,
	Happy,
	Angry,
	Ugh
}

export(int) var emotion = Emotion.Neutral
export(int) var character = Character.Nathaniel
export(String) var text = ""

func _init(p_chara, p_emo, p_text):
	character = p_chara
	emotion = p_emo
	text = p_text
