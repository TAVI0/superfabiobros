extends Node

var total_coins = 0
var lives = 30
enum PlayerState { SMALL, BIG, THONG }
var current_state = PlayerState.SMALL

func spawn_beer_bottle(pos):
	var BeerBottleScene = load("res://scene/beer.tscn")
	var beer_bottle = BeerBottleScene.instantiate()
	beer_bottle.global_position = pos 
	get_tree().root.add_child(beer_bottle)

func spawn_thong_power_up(pos):
	var ThongeScene = load("res://scene/thonge_power_up.tscn")
	var thonge = ThongeScene.instantiate()
	thonge.global_position = pos
	get_tree().root.add_child(thonge)
