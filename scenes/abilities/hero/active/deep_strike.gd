extends "res://scenes/abilities/hero/active/active.gd"

export var unit_template = "blue_infantry"

var deep_strike_executor_template = preload("res://scenes/abilities/hero/active/deep_strike_executor.tscn")

func _execute(board, position):
    var executor = self.deep_strike_executor_template.instance()
    
    executor.set_up(board, position, self.source, self.unit_template)
    board.ability_markers.add_child(executor)
    executor.set_translation(board.map.map_to_world(position))

    board.use_current_player_ap(self.ap_cost)

func is_tile_applicable(tile):
    return tile.can_acommodate_unit()
