library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_dut is
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- axistream
		M_AXIS_TVALID : out std_logic;
		M_AXIS_TDATA  : out std_logic_vector(32-1 downto 0);
		M_AXIS_TSTRB  : out std_logic_vector((32/8)-1 downto 0);
		M_AXIS_TLAST  : out std_logic;
		M_AXIS_TREADY : in std_logic;
		-- data in
		data1_i    : in std_logic_vector(31 downto 0);
		data_en_i  : in std_logic;
		-- config
		start_acquisition_i : in std_logic;
		busy_o              : out std_logic
	);
end top_dut;

architecture Behavioral of top_dut is
	signal mux_data1_s : std_logic_vector(31 downto 0);
	signal mux_data2_s : std_logic_vector(31 downto 0);
	signal mux_data_en_s : std_logic;
	signal mux_data_sof_s : std_logic;
	signal mux_data_eof_s : std_logic;

begin
	dut_inst : entity work.axi_dataReal_dma_direct
	generic map (
		NB_INPUT => 1,
		STOP_ON_EOF => false,
		DATA_SIZE => 32,
		NB_SAMPLE => 10,
		C_M_AXIS_TDATA_WIDTH => 32
	)
	port map (
		clk => clk_i, reset => rst_i,
		M_AXIS_TVALID => M_AXIS_TVALID,
		M_AXIS_TDATA  => M_AXIS_TDATA,
		M_AXIS_TSTRB  => M_AXIS_TSTRB,
		M_AXIS_TLAST  => M_AXIS_TLAST,
		M_AXIS_TREADY => M_AXIS_TREADY,

		start_acquisition_i => start_acquisition_i,
		busy_o     => busy_o,
		data_en_i  => mux_data_en_s,
		data_sof_i => mux_data_sof_s,
		data_eof_i => mux_data_eof_s,
		data1_i    => mux_data1_s,
		data2_i    => mux_data2_s
	);

	mux_data1_s <= data1_i;
	mux_data2_s <= (others => '0');
	mux_data_en_s <= data_en_i;
	mux_data_sof_s <= '1';
	mux_data_eof_s <= '0';
end Behavioral;
