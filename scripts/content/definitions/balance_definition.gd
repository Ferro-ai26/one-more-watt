class_name BalanceDefinition
extends ContentDefinition


func get_simulation_step_seconds() -> float:
	return float(get_value("simulation_step_seconds", 0.0))
