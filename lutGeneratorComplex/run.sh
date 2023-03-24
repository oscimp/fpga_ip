FILES="./hdl/lutGeneratorComplex_storage.vhd ./hdl/lutGeneratorComplex_logic.vhd"
TOP="lutGeneratorComplex_logic"
OPTS="--std=08 --no-formal -frelaxed"
OPTS="$OPTS -gPRESC_SIZE=12 -gDATA_SIZE=16 -gADDR_SIZE=10"
ghdl --synth --out=verilog $OPTS $FILES -e $TOP >> output.v

yosys -p "prep -top $TOP; write_json output.json" output.v
$HOME/misc/repo/netlistsvg/node_modules/netlistsvg/bin/netlistsvg.js output.json -o output.svg
