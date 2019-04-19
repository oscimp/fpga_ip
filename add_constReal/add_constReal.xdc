#set_false_path -from [get_pins {wb_add_constReal_inst/offset_s_reg[*]/C}] -to [get_pins {add_constRealLogic/add_val_s_reg[*]/D}]
set_false_path -from [get_pins -hier *offset_s*/C]
