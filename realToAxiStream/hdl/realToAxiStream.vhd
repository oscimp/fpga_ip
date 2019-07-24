library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity realToAxiStream is 
	generic (
		DATA_SIZE : natural := 32
	);
	port (
		-- input data
		data_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_clk_i: in std_logic;
		data_rst_i: in std_logic;
		-- output data
		m00_axis_aclk   : in std_logic;
		m00_axis_tdata  : out std_logic_vector(DATA_SIZE-1 downto 0);
		m00_axis_tready  : in std_logic;
		m00_axis_tvalid  : out std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture realToAxiStream_1 of realToAxiStream is
begin
	m00_axis_tdata <= data_i;
	m00_axis_tvalid <= data_en_i;
end architecture realToAxiStream_1;

