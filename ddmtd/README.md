This IP implements a [https://white-rabbit.web.cern.ch/documents/DDMTD_for_Sub-ns_Synchronization.pdf](Digital Dual Mixer Time Difference)



## Usage

Since this IP is writen in amaranth it doesn't support verilog generics, for configuration it must be re-built for each build.

### Configure

In the `conf.json` file, you need to set:
- `freq` : the input frequency of `clk_a`
- `mult` : the multiplicator used in the PLL to generate the ddmtd reference clock
- `div` : the divisor used in the PLL to generate the ddmtd reference clock (the offset clock will be generated with `div + 0.125`)
- `word_size`: the width of the output stream, needs to be big enought to hold `reference_freq / beat_note` as an unsigned integer

Then run :
```
$ make clean && make
```

This should re-generate the `ip/` directory containing the vivado ip.

### Use in design

The ip can be instantiated and wired in block design graphically and used in tcl scripts.
The following example instantiate a DDMTD comparing the local clock to a sata clock input on a redpitaya,
with a simple data-to-ram output.

```tcl
#############################################################
#	Clocks
#############################################################

# Local 125MHz clock
add_ip_and_conf redpitaya_converters converters {
	CLOCK_DUTY_CYCLE_STABILIZER_EN {false} }
connect_to_fpga_pins converters phys_interface phys_interface_0
connect_proc_rst converters adc_rst_i

# Example SATA clock input on the redpitaya
add_files ./daisy_clk/daisy_clk.v
add_files -fileset constrs_1 -norecurse ./daisy_clk/daisy_clk.xdc
create_bd_port -dir I daisy_clk_p_i
create_bd_port -dir I daisy_clk_n_i
create_bd_cell -type module -reference daisy_clk daisy_clk_0
connect_bd_net [get_bd_ports daisy_clk_n_i] [get_bd_pins daisy_clk_0/daisy_clk_p_i]
connect_bd_net [get_bd_ports daisy_clk_p_i] [get_bd_pins daisy_clk_0/daisy_clk_n_i]

#############################################################
#	DDMTD
#############################################################

# instantiate the pre-configured and build ip
add_ip_and_conf ddmtd ddmtd {}

# connect local clock to ddmtd clk_a input (used to generate the reference and offset clocks)
connect_intf converters clk_o ddmtd clk_a

# connect the sata clock to ddmtd clk_b input (should be te same frequency as the reference clock derived from clk_a)
connect_bd_net [get_bd_pins daisy_clk_0/daisy_clk_o] [get_bd_pins ddmtd/clk_b]

#############################################################
#	DtoRAM
#############################################################

# Create instance: dtr0, and set properties
add_ip_and_conf dataReal_to_ram dtr0 {
	DATA_SIZE {32} \
	NB_INPUT {1} \
	DATA_FORMAT {signed} \
	NB_SAMPLE {64} \ # async fifo size needs to be large enought so that vivado use a block ram
	USE_EOF {false} }
connect_proc dtr0 s00_axi 0x00000


# connect the stream interfaces
connect_bd_net [get_bd_pins ddmtd/phase] [get_bd_pins dtr0/data1_i]
connect_bd_net [get_bd_pins ddmtd/phase_en] [get_bd_pins dtr0/data1_en_i]
connect_bd_net [get_bd_pins ddmtd/phase_eof] [get_bd_pins dtr0/data1_eof_i]
connect_bd_net [get_bd_pins ddmtd/phase_clk] [get_bd_pins dtr0/data1_clk_i]
connect_bd_net [get_bd_pins ddmtd/phase_rst] [get_bd_pins dtr0/data1_rst_i]
```
