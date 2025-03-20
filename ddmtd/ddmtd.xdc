# Set false path for Amaranth generated attributes
set_false_path -to [get_cells -hier -filter {amaranth.vivado.false_path == "TRUE"}]
