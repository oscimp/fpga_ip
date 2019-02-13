---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2019
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mean_vector_axi_logic is
	generic (
		ADDR_SIZE : natural := 10;
		ACCUM_SIZE : natural := 10;
		SHIFT_SIZE : natural := 4;
		DATA_SIZE: natural := 16
	);
	port (
		rst_i 	: in std_logic;
		clk_i 	: in std_logic;
		-- configuration
		shift_val_i : in std_logic_vector(SHIFT_SIZE-1 downto 0);
		nb_iter_i	: in std_logic_vector(ACCUM_SIZE-1 downto 0);
		-- input
		data_i_i 	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i 	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i 	: in std_logic;
		data_eof_i 	: in std_logic;
		-- output
		data_i_o 	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o 	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o 	: out std_logic;
		data_eof_o 	: out std_logic
	);
end mean_vector_axi_logic;

architecture Behavioral of mean_vector_axi_logic is
	-- we use 2^SHIFT_SIZE instead of 2^ACCUM_SIZE
	-- because of ceil ie log2(1024) = 10, ceil(log2(10)) = 4
	-- 2^4 = 16 > 10
	constant INTERNAL_DATA_SIZE : natural := DATA_SIZE + (2**SHIFT_SIZE);

	signal first_data_en_s : std_logic;

	signal ready_s : std_logic;
	signal count_s : natural range 0 to 2**ADDR_SIZE-1;	
	--signal count_frame_s : natural range 0 to NB_FRAME;	
	signal count_frame_s : std_logic_vector(ACCUM_SIZE-1 downto 0);

	signal data_en_s : std_logic;
	signal data_eof_s, data_eof_next_s : std_logic;
	signal data_i_s, data_q_s : std_logic_vector(DATA_SIZE-1 downto 0);

	signal dat_add_i_s : std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
	signal dat_add_q_s : std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);

	signal last_frame_s : std_logic;

	-- ram
	signal data_in_i_s : std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
	signal data_in_q_s : std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
	signal d_ram_read_i_s : std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
	signal d_ram_read_q_s : std_logic_vector(INTERNAL_DATA_SIZE-1 downto 0);
	signal write_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal read_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);

	-- prepare transmission
	signal prep_next_tr_s : std_logic;
	constant TEMP_SIZE : natural := INTERNAL_DATA_SIZE;
	signal d_final_i_s : std_logic_vector(TEMP_SIZE-1 downto 0);
	signal d_final_q_s : std_logic_vector(TEMP_SIZE-1 downto 0);
	--constant TEMP_SIZE : natural := INTERNAL_DATA_SIZE-LOG2_NB_ACCUM;
	--signal d_shift_i_s : std_logic_vector(TEMP_SIZE-1 downto 0);
	--signal d_shift_q_s : std_logic_vector(TEMP_SIZE-1 downto 0);
	
begin

	d_i : entity work.mean_vector_axi_shift
	generic map (SHIFT_SIZE => SHIFT_SIZE,
		DATA_I_SIZE => INTERNAL_DATA_SIZE, DATA_O_SIZE => DATA_SIZE)
	port map (shift_i => shift_val_i,
		data_i => d_final_i_s, data_o => data_i_o);

	d_q : entity work.mean_vector_axi_shift
	generic map (SHIFT_SIZE => SHIFT_SIZE,
		DATA_I_SIZE => INTERNAL_DATA_SIZE, DATA_O_SIZE => DATA_SIZE)
	port map (shift_i => shift_val_i,
		data_i => d_final_q_s, data_o => data_q_o);

	first_data_en_s <= data_en_i and ready_s;
	-- latch data from previous block
	-- for security and time propagation
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data_i_s <= (others => '0');
				data_q_s <= (others => '0');
				data_en_s <= '0';
				data_eof_s <= '0';
			else
				data_i_s <= data_i_s;
				data_q_s <= data_q_s;
				data_en_s <= first_data_en_s;
				data_eof_s <= '0';
				if first_data_en_s = '1' then
					data_i_s <= data_i_i;
					data_q_s <= data_q_i;
					data_eof_s <= data_eof_i;
				end if;
			end if;
		end if;
	end process;

	--last_frame_s <= '1' when unsigned(count_frame_s) >= unsigned(nb_iter_i) else '0';
	last_frame_s <= '0' when unsigned(count_frame_s) < unsigned(nb_iter_i)-1 else '1';
	prep_next_tr_s <= data_en_s and last_frame_s;
	data_eof_next_s <= last_frame_s and data_eof_s;

	dat_add_i_s <= std_logic_vector(signed(data_i_s) +
		signed(d_ram_read_i_s));
	dat_add_q_s <= std_logic_vector(signed(data_q_s) +
		signed(d_ram_read_q_s));

	data_in_i_s <= dat_add_i_s when (data_en_s and not last_frame_s) = '1'
		else (others => '0');
	data_in_q_s <= dat_add_q_s when (data_en_s and not last_frame_s) = '1'
		else (others => '0');

	
	-- frame synchro:
	-- wait for the first eof before starting
	-- propagation.
	-- Avoid to propagate a partial frame
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				ready_s <= '0';
			else
				ready_s <= ready_s;
				if (data_en_i and data_eof_i) = '1' then
					ready_s <= '1';
				end if;
			end if;
		end if;
	end process;


	-- when count_frame = NB_FRAME 
	-- ie last accum
	-- serie of data is propagated instead of
	-- storing in a ram
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				d_final_i_s <= (others => '0');
				d_final_q_s <= (others => '0');
				data_en_o <= '0';
				data_eof_o <= '0';
			else
				d_final_i_s <= d_final_i_s;
				d_final_q_s <= d_final_q_s;
				data_en_o <= prep_next_tr_s;
				data_eof_o <= '0';
				if prep_next_tr_s = '1' then
					data_eof_o <= data_eof_next_s;
					d_final_i_s <= dat_add_i_s(TEMP_SIZE-1 downto 0);
					d_final_q_s <= dat_add_q_s(TEMP_SIZE-1 downto 0);
				end if;
			end if;
		end if;
	end process;

	read_addr_s <= std_logic_vector(to_unsigned(count_s, ADDR_SIZE));
	-- counter data part
	-- incr for each new data
	-- reset when eof is received
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				count_s <= 0;
				write_addr_s <= (others => '0');
			else
				count_s <= count_s;
				write_addr_s <= write_addr_s;
				if data_en_s = '1' then
					write_addr_s <= std_logic_vector(to_unsigned(count_s, ADDR_SIZE));
					if data_eof_s = '1' then
						count_s <= 0;
					else
						count_s <= count_s + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- counter frame part
	-- incr for each new eof
	-- reset when overflow
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				count_frame_s <= (others => '0');
			else
				count_frame_s <= count_frame_s;
				if (data_eof_s and data_en_s) = '1' then
					if unsigned(count_frame_s) < unsigned(nb_iter_i)-1 then
						count_frame_s <= std_logic_vector(unsigned(count_frame_s) + 1);
					else
						count_frame_s <= (others => '0');
					end if;
					--if unsigned(count_frame_s) >= unsigned(nb_iter_i) then
					--	count_frame_s <= (others => '0');
					--else
					--	count_frame_s <= std_logic_vector(unsigned(count_frame_s) + 1);
					--end if;
				end if;
			end if;
		end if;
	end process;

	ram_i : entity work.mean_vector_axi_ram
	generic map (DATA => INTERNAL_DATA_SIZE, ADDR => ADDR_SIZE)
	port map (clk_a => clk_i, clk_b => clk_i,
		-- input
		we_a => data_en_s, addr_a => write_addr_s,
		din_a => data_in_i_s, dout_a => open,
		-- output
		we_b => '0', addr_b => read_addr_s,
		din_b => (INTERNAL_DATA_SIZE-1 downto 0 => '0'), 
		dout_b => d_ram_read_i_s);
	ram_q : entity work.mean_vector_axi_ram
	generic map (DATA => INTERNAL_DATA_SIZE, ADDR => ADDR_SIZE)
	port map (clk_a => clk_i, clk_b => clk_i,
		-- input
		we_a => data_en_s, addr_a => write_addr_s,
		din_a => data_in_q_s, dout_a => open,
		-- output
		we_b => '0', addr_b => read_addr_s,
		din_b => (INTERNAL_DATA_SIZE-1 downto 0 => '0'), 
		dout_b => d_ram_read_q_s);
end Behavioral;

