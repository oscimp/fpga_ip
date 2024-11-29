---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2018/11/30
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.all;

entity dataReal_logic is
	generic (
		USE_EOF     : boolean := true;
		DATA_FORMAT : string := "signed";
		NB_SAMPLE   : natural := 1024;
		NB_WAY		: natural := 12;
		INPUT_SIZE  : natural := 32;
		DATA_SIZE   : natural := 32;
		AXI_SIZE    : natural := 32;
		SELECT_SZ   : natural := 1;
		ADDR_SIZE   : natural := 12
	);
	port (
		cpu_clk_i     : in std_logic;
		cpu_rst_i     : in std_logic;
		-- Syscon signals
		data_clk_i    : in std_logic ;
		data_rst_i    : in std_logic ;
		-- results
		data_o        : out std_logic_vector((AXI_SIZE)-1 downto 0);
		result_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		select_word_i : in std_logic_vector(SELECT_SZ-1 downto 0);
		-- in
		data_i      : in std_logic_vector(INPUT_SIZE-1 downto 0);
		data_en_i     : in std_logic;
		data_eof_i    : in std_logic
	);
end dataReal_logic;

architecture Behavioral of dataReal_logic is
	function prod_out_ram_size(in_size, axi_size : natural) return natural is
	begin
		if (in_size <= axi_size/2) then
			return(axi_size);
		else
			return(in_size);
		end if;
	end function prod_out_ram_size;
	constant RAM_SIZE                : natural := DATA_SIZE;
	constant OUTPUT_RAM              : natural := prod_out_ram_size(DATA_SIZE, AXI_SIZE);
	signal start_acq2_s              : std_logic;
	signal start_acq4_s, start_acq_s : std_logic;
	signal busy_sync_s       : std_logic;
	-- ram write
	-- data resized and merged
	signal data_s, data_ping_s, data_pong_s : std_logic_vector(RAM_SIZE-1 downto 0);
	signal en_odd_s, en_even_s       : std_logic;

	signal data_en_s, en_ping_s, en_pong_s, en_even_ping_s, en_even_pong_s, en_odd_ping_s, en_odd_pong_s    : std_logic;
	signal sample_cpt_s              : std_logic_vector(ADDR_SIZE downto 0);

	-- ram read
	signal ram_data_s, ram_ping_data_s, ram_pong_data_s : std_logic_vector(OUTPUT_RAM-1 downto 0);
	constant NB_PKT                  : natural := 2**SELECT_SZ;
	type mux_array is array (natural range 0 to NB_PKT-1) of
                std_logic_vector(AXI_SIZE-1 downto 0);
    signal array_val: mux_array;

begin

	data_resizer : entity work.dataReal_resizer
		generic map (IN_SZ => INPUT_SIZE,
			OUT_SZ => DATA_SIZE, DATA_FORMAT => DATA_FORMAT)
		port map (data_i => data_i,
			data_o => data_s);

	with_eof: if USE_EOF = true generate
		start_acq_s <= '1' when (start_acq4_s and data_eof_i) = '1' else '0';
	end generate with_eof;
	without_eof: if USE_EOF /= true generate
		start_acq_s <= start_acq4_s;
	end generate without_eof;

	data_en_s <= data_en_i;
	
	ram_data_s <= ram_pong_data_s when sample_cpt_s(ADDR_SIZE) = '0' else ram_ping_data_s;

	process(data_clk_i) begin
		if rising_edge(data_clk_i) then
		    en_ping_s <= '0';
			en_pong_s <= '0';
			if data_rst_i = '1' then
				sample_cpt_s <= (others => '0');
			elsif data_en_s = '1' then
				sample_cpt_s <= std_logic_vector(unsigned(sample_cpt_s) + 1);
				if (sample_cpt_s(ADDR_SIZE) = '0') then
				    en_ping_s <= '1';
				    en_pong_s <= '0';
				    data_ping_s <= data_s;
				end if;
				if (sample_cpt_s(ADDR_SIZE) = '1') then
				    en_ping_s <= '0';
				    en_pong_s <= '1';
				    data_pong_s <= data_s;
				end if;
			else
				sample_cpt_s <= sample_cpt_s;
			end if;
		end if;
	end process;

	-------------------------
	-- RAM access for READ --
	-------------------------
	direct_addr: if NB_PKT = 1 generate
		data_o <= ram_data_s;
	end generate direct_addr;
	shift_addr: if NB_PKT /= 1 generate
	    mux_loop : for i in 0 to NB_PKT-1 generate
        	array_val(i) <= ram_data_s(((i + 1) * AXI_SIZE) - 1 downto AXI_SIZE * i);
    	end generate mux_loop;
    	data_o <= array_val(to_integer(unsigned(select_word_i)));
	end generate shift_addr;

	---------
	-- RAM --
	---------
	-- if 16bits and one way it's possible to merge to consecutive sample
	--   by using two RAM (1 for odd, 1 for even)
	--   (based on addr lsb bit)
	half_axi_bits: if RAM_SIZE = AXI_SIZE/2 generate
		en_even_ping_s <= en_ping_s and sample_cpt_s(0);
		en_even_pong_s <= en_pong_s and sample_cpt_s(0);
		ram_even_ping: entity work.dataReal_to_ram_pingpong_storage
		generic map (DATA => RAM_SIZE, ADDR => ADDR_SIZE-1)
		port map (clk_a => data_clk_i, clk_b => cpu_clk_i,
			rst_b => cpu_rst_i,
			-- state machine interface
			we_a   => en_even_ping_s, addr_a(ADDR_SIZE-2 downto 0) => sample_cpt_s(ADDR_SIZE-1 downto 1), din_a => data_ping_s,
			addr_b => result_addr_i(ADDR_SIZE-2 downto 0), dout_b => ram_ping_data_s(RAM_SIZE-1 downto 0));
    	ram_even_pong: entity work.dataReal_to_ram_pingpong_storage
		generic map (DATA => RAM_SIZE, ADDR => ADDR_SIZE-1)
		port map (clk_a => data_clk_i, clk_b => cpu_clk_i,
			rst_b => cpu_rst_i,
			-- state machine interface
			we_a   => en_even_pong_s, addr_a(ADDR_SIZE-2 downto 0) => sample_cpt_s(ADDR_SIZE-1 downto 1), din_a => data_pong_s,
			addr_b => result_addr_i(ADDR_SIZE-2 downto 0), dout_b => ram_pong_data_s(RAM_SIZE-1 downto 0));

		en_odd_ping_s <= en_ping_s and not sample_cpt_s(0);
		en_odd_pong_s <= en_pong_s and not sample_cpt_s(0);
		ram_odd_ping: entity work.dataReal_to_ram_pingpong_storage
		generic map (DATA => RAM_SIZE, ADDR => ADDR_SIZE-1)
		port map (clk_a => data_clk_i, clk_b => cpu_clk_i,
			rst_b => cpu_rst_i,
			-- state machine interface
			we_a   => en_odd_ping_s, addr_a(ADDR_SIZE-2 downto 0) => sample_cpt_s(ADDR_SIZE-1 downto 1), din_a => data_ping_s,
			addr_b => result_addr_i(ADDR_SIZE-2 downto 0), dout_b => ram_ping_data_s(OUTPUT_RAM-1 downto RAM_SIZE));
    	ram_odd_pong: entity work.dataReal_to_ram_pingpong_storage
		generic map (DATA => RAM_SIZE, ADDR => ADDR_SIZE-1)
		port map (clk_a => data_clk_i, clk_b => cpu_clk_i,
			rst_b => cpu_rst_i,
			-- state machine interface
			we_a   => en_odd_pong_s, addr_a(ADDR_SIZE-2 downto 0) => sample_cpt_s(ADDR_SIZE-1 downto 1), din_a => data_pong_s,
			addr_b => result_addr_i(ADDR_SIZE-2 downto 0), dout_b => ram_pong_data_s(OUTPUT_RAM-1 downto RAM_SIZE));
	end generate half_axi_bits;

	-- for other case (RAM_SIZE > AXI_SIZE /2 or more than one channel)
	--    use direct RAM output
	--    when RAM_SIZE == AXI_SIZE/2 ram output is extented by adding 0
	--    to AXI_SIZE
	gteq_axi_bits: if RAM_SIZE /= AXI_SIZE/2 generate
		ram_msb_ping: entity work.dataReal_to_ram_pingpong_storage
		generic map (DATA => RAM_SIZE, ADDR => ADDR_SIZE)
		port map (clk_a => data_clk_i, clk_b => cpu_clk_i,
			rst_b => cpu_rst_i,
			-- state machine interface
			we_a   => en_ping_s, addr_a => sample_cpt_s(ADDR_SIZE-1 downto 0), din_a => data_ping_s,
			addr_b => result_addr_i, dout_b => ram_ping_data_s(RAM_SIZE-1 downto 0));
			
    	ram_msb_pong: entity work.dataReal_to_ram_pingpong_storage
		generic map (DATA => RAM_SIZE, ADDR => ADDR_SIZE)
		port map (clk_a => data_clk_i, clk_b => cpu_clk_i,
			rst_b => cpu_rst_i,
			-- state machine interface
			we_a   => en_pong_s, addr_a => sample_cpt_s(ADDR_SIZE-1 downto 0), din_a => data_pong_s,
			addr_b => result_addr_i, dout_b => ram_pong_data_s(RAM_SIZE-1 downto 0));
	end generate gteq_axi_bits;

end Behavioral;
