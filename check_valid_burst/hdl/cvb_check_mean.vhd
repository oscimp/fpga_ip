library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cvb_check_mean is
generic (
	ACCUM_SIZE: integer := 32;
	DATA	 : integer := 72;
	ADDR	 : integer := 10
);
port (
	clk_i    : in std_logic;
	rst_i    : in std_logic;

	start_mean_offset_i : in std_logic_vector(ADDR-1 downto 0);
	max_allowed_val_i : in std_logic_vector(ACCUM_SIZE-1 downto 0);

	data_en_i : in std_logic;
	data_addr_i : in std_logic_vector(ADDR-1 downto 0);
	data_i_i : in std_logic_vector(DATA-1 downto 0);
	data_q_i : in std_logic_vector(DATA-1 downto 0);
	data_eof_i : in std_logic;

	frame_valid_o : out std_logic

);
end entity;

architecture bhv of cvb_check_mean is

	signal dat_i_in_s : std_logic_vector(DATA-1 downto 0);
	signal dat_q_in_s : std_logic_vector(DATA-1 downto 0);
	signal in_mean_s : std_logic;

	signal neg_to_pos_i_s : std_logic_vector(DATA-1 downto 0);
	signal neg_to_pos_q_s : std_logic_vector(DATA-1 downto 0);

	-- accum
	signal accum_i_s, accum_i_next_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
	signal accum_q_s, accum_q_next_s : std_logic_vector(ACCUM_SIZE-1 downto 0);

	-- last --
	signal frame_valid_s : std_logic;
begin

	-- check if current position if before or after mean start offset
	in_mean_s <= '0' when unsigned(data_addr_i) < unsigned(start_mean_offset_i)-1
		else '1';

	-- abs --
	neg_to_pos_i_s <= data_i_i when data_i_i(DATA-1) = '0' else
		std_logic_vector(unsigned(not(data_i_i))+1);
	neg_to_pos_q_s <= data_q_i when data_q_i(DATA-1) = '0' else
		std_logic_vector(unsigned(not(data_q_i))+1);

	-- use 0 before start mean or use data input values
	dat_i_in_s <= (DATA-1 downto 0 => '0') when in_mean_s = '0' else
		neg_to_pos_i_s;
	dat_q_in_s <= (DATA-1 downto 0 => '0') when in_mean_s = '0' else
		neg_to_pos_q_s;

	
	accum_i_next_s <= 
				std_logic_vector(unsigned(accum_i_s) + unsigned(dat_i_in_s));
	accum_q_next_s <= 
				std_logic_vector(unsigned(accum_q_s) + unsigned(dat_q_in_s));
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			accum_i_s <= accum_i_s;
			accum_q_s <= accum_q_s;
			if (data_en_i = '1') then
				accum_i_s <= accum_i_next_s;
				accum_q_s <= accum_q_next_s;
			end if;

			if (rst_i or data_eof_i) = '1' then
				accum_i_s <= (others => '0');
				accum_q_s <= (others => '0');
			end if;
		end if;
	end process;


	-- last
	-- check if accum content if allowed --
	-- and output if valid or not when eof is high
	process(accum_i_s, accum_q_s, max_allowed_val_i)
	begin
		if (unsigned(accum_i_s) <= unsigned(max_allowed_val_i)) and
				(unsigned(accum_q_s) <= unsigned(max_allowed_val_i)) then
			frame_valid_s <= '1';
		else
			frame_valid_s <= '0';
		end if;
	end process;
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if data_eof_i = '1' then
				frame_valid_o <= frame_valid_s;
			else
				frame_valid_o <= '0';
			end if;
		end if;
	end process;

end architecture bhv;
