library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

Entity firComplex_top is 
	generic (
		coeff_format : string := "signed";
		NB_COEFF : natural := 128;
		DECIMATE_FACTOR : natural := 32;
		COEFF_SIZE : natural := 16;
		COEFF_ADDR_SZ : natural := 10;
		DATA_SIZE : natural := 16;
		DATA_OUT_SIZE : natural := 32
	);
	port (
		-- Syscon signals
		reset		 : in std_logic;
		clk		   : in std_logic;
		clk_axi : in std_logic;
		-- coeff configuration
		wr_coeff_en_i : in std_logic;
		wr_coeff_addr_i : in std_logic_vector(COEFF_ADDR_SZ-1 downto 0);
		wr_coeff_val_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		rd_coeff_val_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		-- input data
		data_en_i : in std_logic;
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		-- for the next component
		data_i_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_q_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o : out std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture bhv of firComplex_top is
---------------------------------------------------------------------------
	constant NB_THREAD : natural :=
			natural(ceil(real(real(NB_COEFF)/real(DECIMATE_FACTOR))));
	constant READY_SZ : natural := NB_THREAD * DECIMATE_FACTOR;
	signal ready_s, ready_next_s : std_logic_vector(READY_SZ-1 downto 0);
	signal end_macc_s : std_logic;
	signal end_s, end_next_s : std_logic_vector(READY_SZ-1 downto 0);

	signal cpt_s : natural range 0 to READY_SZ-1;
	signal cpt_next_s, mux_cpt_s : natural range 0 to READY_SZ-1;
	signal rst_cpt_s : std_logic;
	signal rd_coeff_addr_s: std_logic_vector(COEFF_ADDR_SZ-1 downto 0);

	signal coeff_s : std_logic_vector(COEFF_SIZE-1 downto 0);

	type data_tab is array (natural range <>) of std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	type coeff_tab is array (natural range <>) of std_logic_vector(COEFF_SIZE-1 downto 0);


	signal coeff_tab_s, coeff_tab_next_s : coeff_tab(READY_SZ-1 downto 0);
	signal coeff2_tab_s : coeff_tab(READY_SZ-1 downto 0);

	signal data_in_en_s : std_logic;
	signal data_i_in_s, data_q_in_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal end_delay_macc_s : std_logic;

	-- last
	signal cpt_store_s, cpt_store_next_s : natural range 0 to NB_THREAD-1;
	signal clr_cpt_store_s : std_logic;
    signal data_i_out_s, data_i_out_next_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
    signal data_q_out_s, data_q_out_next_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
    signal data_i_s, data_q_s : data_tab(NB_THREAD-1 downto 0);
	signal data_en_s : std_logic_vector(NB_THREAD-1 downto 0);
	signal data_en_next : std_logic;
begin

	ready_next_s <= ready_s(READY_SZ-2 downto 0) & ready_s(READY_SZ-1);
	end_next_s <= end_s(READY_SZ-2 downto 0) & end_delay_macc_s;

	coeff_tab_next_s(0) <= coeff_s;
	coeff_tab_next_s(READY_SZ-1 downto 1) <= coeff_tab_s(READY_SZ-2 downto 0);

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				data_in_en_s <= '0';
				end_delay_macc_s <= '0'; 
				data_i_in_s <= (others => '0');
				data_q_in_s <= (others => '0');
			else
				data_in_en_s <= data_en_i;
				end_delay_macc_s <= end_macc_s;
				data_i_in_s <= data_i_i;
				data_q_in_s <= data_q_i;
			end if;
			if reset = '1' then
				ready_s <= (READY_SZ-1 downto 1 => '0') & '1';
				end_s <= (others => '0');
				coeff_tab_s <= (others => (others => '0'));
			elsif data_in_en_s = '1' then
				ready_s <= ready_next_s;
				end_s <= end_next_s;
				coeff_tab_s <= coeff_tab_next_s;
			else
				ready_s <= ready_s;
				end_s <= end_s;
				coeff_tab_s <= coeff_tab_s;
			end if;
		end if;
	end process;

	gen_macc : for i in 0 to NB_THREAD-1 generate
		logic_inst: entity work.firComplex_proc
		generic map (NB_COEFF => NB_COEFF,
			coeff_format => coeff_format,
			DATA_SIZE => DATA_SIZE, DATA_OUT_SIZE => DATA_OUT_SIZE,
			COEFF_SIZE => COEFF_SIZE)
		port map (reset => reset, clk => clk,
			end_i => end_s(i*DECIMATE_FACTOR),
			ready_i => ready_s(i*DECIMATE_FACTOR), 
			coeff_i => coeff_tab_s(i*DECIMATE_FACTOR),
			data_en_i => data_in_en_s, 
			data_i_i => data_i_in_s, data_q_i => data_q_in_s,
			data_en_o => data_en_s(i),
			data_i_o => data_i_s(i), data_q_o => data_q_s(i)
		);
	end generate gen_macc;

	end_macc_s <= '1' when cpt_s = NB_COEFF-1 else '0';
	rst_cpt_s <= '1' when cpt_s = READY_SZ-1 else '0';

	cpt_next_s <= 0 when cpt_s = READY_SZ-1 else cpt_s + 1;
	mux_cpt_s <= cpt_next_s when rst_cpt_s = '0' else 0;
	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				cpt_s <= 0;
			elsif data_en_i = '1' then
				cpt_s <= mux_cpt_s;
			else
				cpt_s <= cpt_s;
			end if;
		end if;
	end process;

	data_en_next <= '1' when data_en_s /= (NB_THREAD-1 downto 0 => '0') else '0';

	clr_cpt_store_s <= '1' when cpt_store_s = NB_THREAD-1 else '0';
	cpt_store_next_s <= 0 when (cpt_store_s = NB_THREAD-1 ) or (clr_cpt_store_s =
	'1') else 
						cpt_store_s + 1;
	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				cpt_store_s <= 0;
			elsif data_en_next = '1' then
				cpt_store_s <= cpt_store_next_s;
			else
				cpt_store_s <= cpt_store_s;
			end if;
		end if;
	end process;

	data_i_out_next_s <= data_i_s(cpt_store_s);
	data_q_out_next_s <= data_q_s(cpt_store_s);

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				data_en_o <= '0';
			else
				data_en_o <= data_en_next;
			end if;
			if reset = '1' then
				data_i_out_s <= (others => '0');
				data_q_out_s <= (others => '0');
			elsif data_en_next = '1' then
				data_i_out_s <= data_i_out_next_s;
				data_q_out_s <= data_q_out_next_s;
			else
				data_i_out_s <= data_i_out_s;
				data_q_out_s <= data_q_out_s;
			end if;
		end if;
	end process;

	data_i_o <= data_i_out_s;
	data_q_o <= data_q_out_s;

	rd_coeff_addr_s <= std_logic_vector(to_unsigned(cpt_s, COEFF_ADDR_SZ));

	ram_coeff: entity work.firComplex_ram
	generic map (DATA => COEFF_SIZE, ADDR => COEFF_ADDR_SZ)
	port map(clk_a => clk_axi, clk_b => clk,
		we_a => wr_coeff_en_i, addr_a => wr_coeff_addr_i,
		din_a => wr_coeff_val_i, dout_a => rd_coeff_val_o,
		addr_b => rd_coeff_addr_s, dout_b => coeff_s
	);

end architecture bhv;

