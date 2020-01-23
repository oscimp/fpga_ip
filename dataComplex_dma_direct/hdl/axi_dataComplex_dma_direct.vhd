library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

Entity axi_dataComplex_dma_direct is 
	generic(
		DATA_SIZE : natural := 32;
		NB_SAMPLE: natural := 32;
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Syscon signals
		reset	      : in std_logic;
		clk	          : in std_logic;
		-- axi signals
		M_AXIS_TVALID : out std_logic;
		M_AXIS_TDATA  : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB  : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST  : out std_logic;
		M_AXIS_TREADY : in std_logic;
		-- config/control
		start_acquisition_i : in std_logic;
		busy_o     : out std_logic;
		-- input data stream
		data_en_i  : in std_logic;
		data_sof_i : in std_logic;
		data_eof_i : in std_logic;
		data1_i    : in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_i    : in std_logic_vector(DATA_SIZE-1 downto 0)
	);
end entity axi_dataComplex_dma_direct;

Architecture bhv of axi_dataComplex_dma_direct is
	signal axis_tvalid_delay	: std_logic;
	signal tlast_next_s : std_logic;
	signal axis_tlast_delay	: std_logic;
	signal stream_data_out	: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);

	-- new
	signal start_acquisition_s : std_logic;
	signal stop_acquisition_s : std_logic;
	signal busy_s : std_logic;
	signal data_en_s : std_logic;
	constant CPT_SIZE      : natural := natural(ceil(log2(real(NB_SAMPLE))));
	signal cpt_s : unsigned(CPT_SIZE-1 downto 0);
	signal sec_part : natural range 0 to 1;
	signal data2_s : std_logic_vector(31 downto 0);

	signal ready_s, ready_next_s : std_logic;
	signal enable_s : std_logic;
	signal data_eof_s : std_logic;
begin
	busy_o <= busy_s;


	ready_next_s <= data_en_i when (busy_s or (enable_s and data_sof_i)) = '1' else '0';
	--stop_acquisition_s <= busy_s and data_eof_i;
	stop_acquisition_s <= busy_s and tlast_next_s;
	data_eof_s <= ready_next_s and data_eof_i;

	process(clk) begin
		if rising_edge(clk) then
			if (reset or ready_next_s) = '1' then
				enable_s <= '0';
			elsif start_acquisition_i = '1' then
				enable_s <= '1';
			end if;
		end if;
	end process;

	process(clk) begin
		if rising_edge(clk) then
			if (stop_acquisition_s or reset) = '1' then
				busy_s <= '0';
			elsif ready_next_s = '1' then
				busy_s <= '1';
			else
				busy_s <= busy_s;
			end if;
		end if;
	end process;

	data_en_s <= data_en_i and ready_next_s;

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				axis_tvalid_delay <= '0';
				axis_tlast_delay  <= '0';
				tlast_next_s      <= '0';
				data2_s           <= (others => '0');
				stream_data_out   <= (others => '0');
				sec_part          <= 0;
			else
				axis_tlast_delay <= '0';
				tlast_next_s     <= tlast_next_s;
				data2_s          <= data2_s;
				if data_en_s = '1' then
					axis_tvalid_delay <= '1';
					tlast_next_s      <= data_eof_s; --stop_acquisition_s;
					data2_s           <= data2_i;
					stream_data_out   <= data1_i;
					sec_part          <= 1;
				elsif sec_part = 1 then
					axis_tvalid_delay <= '1';
					axis_tlast_delay  <= tlast_next_s;
					tlast_next_s      <= '0';
					stream_data_out   <= data2_s;
					sec_part          <= 0;
				else
					axis_tvalid_delay <= '0';
					stream_data_out   <= stream_data_out;
					sec_part          <= 0;
				end if;
			end if;
		end if;
	end process;

	M_AXIS_TVALID	<= axis_tvalid_delay;
	M_AXIS_TDATA	<= stream_data_out;
	M_AXIS_TLAST	<= axis_tlast_delay;
	M_AXIS_TSTRB	<= (others => '1');

	--ready_next_s <= busy_s and (ready_s or (data_en_i and data_sof_i));
	--data_en_s <= data_en_i and ready_next_s; --busy_s;
	--stop_acquisition_s <= '1' when cpt_s = NB_SAMPLE-1 else '0';


	--process(clk) begin
	--	if rising_edge(clk) then
	--		if reset = '1' then
	--			ready_s <= '0';
	--		else
	--			ready_s <= ready_next_s;
	--		end if;
	--	end if;
	--end process;

	--process(clk)
	--begin
	--	if rising_edge(clk) then
	--		if (reset = '1' or (data_en_s and stop_acquisition_s)='1') then
	--			busy_s <= '0';
	--		elsif start_acquisition_s = '1' then
	--			busy_s <= '1';
	--		end if;
	--	end if;
	--end process;

	--process(clk)
	--begin
	--	if rising_edge(clk) then
	--		if (not busy_s or reset) = '1' then
	--			cpt_s <= (others => '0');
	--		elsif data_en_s = '1' then
	--			cpt_s <= cpt_s + 1;
	--		end if;
	--	end if;
	--end process;

end architecture bhv;
