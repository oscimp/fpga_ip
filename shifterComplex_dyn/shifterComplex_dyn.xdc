set_property ASYNC_REG TRUE \
	[get_cells -hier flipflops*_reg[0]] \
	[get_cells -hier flipflops*_reg[1]]
set_false_path \
	-from [get_cells -hier sync_stage0_*_reg -filter {IS_SEQUENTIAL}] \
	-to [get_cells -hier flipflops*_reg[0] -filter {IS_SEQUENTIAL}]

set_property ASYNC_REG TRUE \
	[get_cells -hier flipflops_vect*_reg[0][*]] \
	[get_cells -hier flipflops_vect*_reg[1][*]]
set_false_path \
	-from [get_cells -hier sync_vect_stage0_*_reg[*] -filter {IS_SEQUENTIAL}] \
	-to [get_cells -hier flipflops_vect*_reg[0][*] -filter {IS_SEQUENTIAL}]
