---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2018/12/16
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity dataReal_to_ram_top is
	generic (
		DATA_FORMAT : string := "signed";
		USE_EOF : boolean := true;
		NB_WAY : natural := 4;
		NB_SAMPLE : natural := 1024;
		INPUT_SIZE : natural := 32;
		DATA_SIZE : natural := 32;
		AXI_SIZE : natural := 32;
		ADDR_SIZE : natural := 12;
		RD_ADDR_SIZE : natural := 12;
		CHAN_MUX_SZ  : natural := 12;
		PKT_MUX_SZ   : natural := 12
	);
	port (
		cpu_clk_i           : in std_logic;
		rst_i               : in std_logic;
		-- Syscon signals
		data_clk_i			: in std_logic_vector(NB_WAY-1 downto 0);
		data_rst_i			: in std_logic_vector(NB_WAY-1 downto 0);
		--communication signals
		--config
		start_acquisition_i : std_logic;
		busy_o 				: out std_logic;
		-- results
		res_o 			    : out std_logic_vector(AXI_SIZE-1 downto 0);
		ram_incr_i          : in std_logic;
		ram_reinit_i        : in std_logic;
		-- input
		data_i	    		: in std_logic_vector((NB_WAY*INPUT_SIZE)-1 downto 0);
		data_en_i			: in std_logic_vector(NB_WAY-1 downto 0);
		data_eof_i			: in std_logic_vector(NB_WAY-1 downto 0)
	);
end dataReal_to_ram_top;

architecture Behavioral of dataReal_to_ram_top is
	function prod_nb_iter(in_size, axi_size, nb_way: natural) return natural is
	begin
		if (in_size <= axi_size / 2 and nb_way /= 1) then
			if ((nb_way mod 2) /= 0) then
				return ((nb_way / 2) + 1);
			else
				return (nb_way / 2);
			end if;
		else
			return(nb_way);
		end if;
	end function prod_nb_iter;
	constant NB_ITER         : natural := prod_nb_iter(DATA_SIZE, AXI_SIZE, NB_WAY);
	constant HLF_WAY         : natural := NB_WAY/2;

	signal busy_s            : std_logic_vector(NB_WAY-1 downto 0);
	signal busy_out_s        : std_logic;
	signal start_s           : std_logic;
	type res_tab is array (natural range <>) of std_logic_vector(AXI_SIZE-1 downto 0);
	signal res_s             : res_tab(NB_WAY-1 downto 0);
	signal mux_complex_s     : res_tab(NB_WAY-1 downto 0);

	-- address manipulation
	constant NB_PKT_PER_SAMP : natural := 2**PKT_MUX_SZ;

	signal incr_chan_s     : std_logic;
	signal incr_addr_s     : std_logic;
	signal ram_addr_s      : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ram_addr_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal select_chan_s   : std_logic_vector(CHAN_MUX_SZ-1 downto 0);
	signal select_chan_next_s   : std_logic_vector(CHAN_MUX_SZ-1 downto 0);
	signal select_s        : std_logic_vector(PKT_MUX_SZ-1 downto 0);
	signal select_next_s   : std_logic_vector(PKT_MUX_SZ-1 downto 0);

begin

	-- select channel addr part
	mux_1chan: if NB_WAY = 1 generate
		select_chan_next_s <= "0";
		incr_addr_s <= incr_chan_s;
	end generate mux_1chan;

	mux_chan: if NB_WAY /= 1 generate
 		incr_addr_s <= '1' when incr_chan_s = '1' and unsigned(select_chan_s) >= NB_WAY-1 else '0';
		process(incr_chan_s, select_chan_s) begin
			select_chan_next_s <= select_chan_s;
			if incr_chan_s = '1' then
				if unsigned(select_chan_s) >= NB_WAY-1 then
					select_chan_next_s <= (others => '0');
				else
					select_chan_next_s <=
						std_logic_vector(unsigned(select_chan_s) + 1);
				end if;
			end if;
		end process;
	end generate mux_chan;

	-- select ram addr part
	process(ram_addr_s, incr_addr_s) begin
		if incr_addr_s = '1' then
			ram_addr_next_s <= std_logic_vector(unsigned(ram_addr_s) + 1);
		else
			ram_addr_next_s <= ram_addr_s;
		end if;
	end process;

	-- select sub slv part
	mux_1word: if NB_PKT_PER_SAMP = 1 generate
		select_next_s <= "0";
		incr_chan_s <= '1';
	end generate mux_1word;
	mux_manyWord: if NB_PKT_PER_SAMP /= 1 generate
		select_next_s <= std_logic_vector(unsigned(select_s) + 1);
		incr_chan_s <= '1' when unsigned(select_s) >= NB_PKT_PER_SAMP - 1 else '0';
	end generate mux_manyWord;

	process(cpu_clk_i) begin
        if rising_edge(cpu_clk_i) then
            if rst_i = '1' then
                ram_addr_s <= (others => '0');
                select_chan_s <= (others => '0');
                select_s <= (others => '0');
			else
                ram_addr_s <= ram_addr_s;
                select_chan_s <= select_chan_s;
                select_s <= select_s;
            	if ram_reinit_i = '1' then
                	ram_addr_s <= (others => '0');
                	select_chan_s <= (others => '0');
                	select_s <= (others => '0');
            	elsif (ram_incr_i = '1') then
            	    ram_addr_s <= ram_addr_next_s;
            	    select_chan_s <= select_chan_next_s;
            	    select_s <= select_next_s;
            	end if;
            end if;
        end if;
    end process;

	busy_o <= busy_out_s or start_s;
	busy_out_s <= '0' when busy_s = (NB_WAY-1 downto 0 => '0') else '1';

	process(cpu_clk_i) begin
		if rising_edge(cpu_clk_i) then
			if (busy_out_s or rst_i) = '1' then
				start_s <= '0';
			elsif start_acquisition_i = '1' then
				start_s <= '1';
			else
				start_s <= start_s;
			end if;
		end if;
	end process;
	
	subtop_loop : for i in 0 to NB_WAY-1 generate
		data_subtop_inst : entity work.dataReal_to_ram_subtop
		generic map(USE_EOF => USE_EOF, DATA_FORMAT => DATA_FORMAT,
			DATA_SIZE => DATA_SIZE, INPUT_SIZE => INPUT_SIZE,
			NB_WAY => NB_WAY,
			AXI_SIZE => AXI_SIZE, NB_SAMPLE => NB_SAMPLE,
			SELECT_SZ => PKT_MUX_SZ, ADDR_SIZE => ADDR_SIZE)
		port map (data_clk_i => data_clk_i(i), cpu_clk_i => cpu_clk_i,
			cpu_rst_i => rst_i, data_rst_i => data_rst_i(i),
			start_acq_i => start_acquisition_i, busy_o => busy_s(i),
			-- output
			result_addr_i => ram_addr_s, select_word_i => select_s,
			data_o => res_s(i),
			-- results
			data_i => data_i(((i+1)*INPUT_SIZE)-1 downto i*INPUT_SIZE),
			data_en_i => data_en_i(i), data_eof_i => data_eof_i(i));
	end generate subtop_loop;

---
--- for output we consider 2 case :
--- 1/ for DATA_SIZE >= AXI_SIZE NB_WAY == NB_ITER and use direct or
---    mux depending on the nb pkt to send for one sample
--- 2/ for DATA_SIZE < AXI_SIZE NB_WAY == NB_ITER * 2 and to consecutive
---    channel are merged to provide one AXI_SIZE bit pkt. Since res_s
---    is extended to AXI_SIZE we use only DATA_SIZE lsb
---
	-- 1 / DATA_SIZE >= AXI_SIZE direct access to sample (managed by submodule)
	--     or DATA_SIZE < AXI_SIZE but NB_WAY = 1 -> 2 consecutive sample
	--     are merged to have DATA_SIZE == AXI_SIZE -> direct access
	simple_mux: if (NB_WAY = NB_ITER) generate
		res_o <= res_s(to_integer(unsigned(select_chan_s)));
	end generate simple_mux;

	-- 2 / DATA_SIZE < AXI_SIZE and NB_WAY > 1 we need to merge to consecutive
	--     channel to have DATA_SIZE = AXI_SIZE with one increment for two
	--     set of sample (rest of logic in submodule)
	complex_mux: if (NB_WAY /= 1 and DATA_SIZE < AXI_SIZE) generate
		res_o <= mux_complex_s(to_integer(unsigned(select_chan_s)));

		--    a/ NB_WAY even we merge simply two consecutive channel
		even_way: if (NB_ITER = HLF_WAY) generate
			even_loop: for i in 0 to HLF_WAY-1 generate
				mux_complex_s(i) <= res_s((2*i)+1)(DATA_SIZE-1 downto 0)
									& res_s(2*i)(DATA_SIZE-1 downto 0);
				mux_complex_s(NB_ITER+i) <= res_s((2*i)+1)(AXI_SIZE-1 downto DATA_SIZE)
									& res_s(2*i)(AXI_SIZE-1 downto DATA_SIZE);
			end generate even_loop;
		end generate even_way;

		-- b/ NB_WAY odd: a trick is mandatory to have first part equivalent to
		--     a/, the last channel and the first to the next set in one pkt
		--        and finaly merge to two consecutive sample
		odd_way: if (NB_ITER /= HLF_WAY) generate
			odd_loop: for i in 0 to HLF_WAY-1 generate
				mux_complex_s(i) <= res_s((2*i)+1)(DATA_SIZE-1 downto 0)
									& res_s(2*i)(DATA_SIZE-1 downto 0);
				mux_complex_s(NB_ITER+i) <= res_s((2*i)+2)(AXI_SIZE-1 downto DATA_SIZE)
									& res_s((2*i)+1)(AXI_SIZE-1 downto DATA_SIZE);
			end generate odd_loop;
			mux_complex_s(NB_ITER -1) <= res_s(0)(AXI_SIZE-1 downto DATA_SIZE)
							& res_s(NB_WAY-1)(DATA_SIZE-1 downto 0);

		end generate odd_way;
	end generate complex_mux;

end Behavioral;
