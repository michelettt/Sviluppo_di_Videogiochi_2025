extends Node

signal health_change(character_type: Character.Type, current_health: int, max_health: int)
signal heavy_blow_received()
signal player_revive()
signal press_revive
