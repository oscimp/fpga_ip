# Package Maia SDR IP core

create_project ddmtd . -force
add_files ddmtd.v
add_files -fileset constrs_1 -norecurse ../ddmtd.xdc
set_property top top [current_fileset]
load_features ipservices
ipx::package_project -import_files -root_dir . -vendor oscimp -library user -force
set_property name ddmtd [ipx::current_core]
set_property library ddmtd [ipx::current_core]
set_property display_name {DDMTD} [ipx::current_core]
set_property description "DDMTD" [ipx::current_core]
set_property vendor_display_name {OscimpDigital} [ipx::current_core]
set_property version $::env(IP_CORE_VERSION) [ipx::current_core]

# phase_clk interface
ipx::add_bus_interface phase_clk [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 \
    [ipx::get_bus_interfaces phase_clk -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:signal:clock:1.0 \
    [ipx::get_bus_interfaces phase_clk -of_objects [ipx::current_core]]
ipx::add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces phase_clk -of_objects [ipx::current_core]]

ipx::create_xgui_files [ipx::current_core]
ipx::save_core [ipx::current_core]
