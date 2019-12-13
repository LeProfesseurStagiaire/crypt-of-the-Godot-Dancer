extends Node

var game_difficulty = ["easy","medium","hard"]
var game_difficulty_selected = 0
var game_param = {
	"easy":{"less_time":1.5,"max_time":0.3},
	"medium":{"less_time":1.2,"max_time":0.25},
	"hard":{"less_time":1.1,"max_time":0.23},
}