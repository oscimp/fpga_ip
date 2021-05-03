library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

Entity cordicAtan_impl is 
	generic (
		NB_ITER : natural := 25;
		SHIFT_V : natural := 10;
		ATAN_SIZE : natural := 10;
		ALPHA_SIZE : natural := 8;
		DATA_SIZE : natural := 8
	);
	port (
		-- Syscon signals
		clk			: in std_logic;
		-- sign		
		sign_i		: in std_logic_vector(3 downto 0);
		sign_o		: out std_logic_vector(3 downto 0);
		-- input data
		data_en_i	: in std_logic;
		data_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_atan_i : in std_logic_vector(ALPHA_SIZE-1 downto 0);
		-- output data
		data_en_o	: out std_logic;
		data_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_atan_o : out std_logic_vector(ALPHA_SIZE-1 downto 0)
	);
end entity;

Architecture bhv of cordicAtan_impl is
	constant SCALE_VAL      : natural := NB_ITER-1;
    constant SCALE_FACTOR   : real := 2**real(SCALE_VAL);
    constant RATAN          : real := ARCTAN(real(2**(-real(SHIFT_V))))  * SCALE_FACTOR;
	constant val_alpha_s    : signed(ALPHA_SIZE-1 downto 0) := to_signed(natural(RATAN), ALPHA_SIZE);


	constant T_SZ_SHIFT     : natural := DATA_SIZE-SHIFT_V;
	signal s_alpha_next_s   : signed(ALPHA_SIZE-1 downto 0);

	signal sign_s	        : std_logic_vector(3 downto 0);
	signal sign_next_s      : std_logic;

	signal i_div_s          : signed(T_SZ_SHIFT-1 downto 0);
	signal q_div_s          : signed(T_SZ_SHIFT-1 downto 0);
	signal s_i_div_s        : signed(T_SZ_SHIFT-1 downto 0);
	signal s_q_div_s        : signed(T_SZ_SHIFT-1 downto 0);
	signal s_alpha_s        : signed(ALPHA_SIZE-1 downto 0);
	signal data_i_next_s    : signed(DATA_SIZE-1 downto 0);
	signal data_q_next_s    : signed(DATA_SIZE-1 downto 0);
	signal data_atan_next_s : signed(ALPHA_SIZE-1 downto 0);

	signal data_i_s         : signed(DATA_SIZE-1 downto 0);
	signal data_q_s         : signed(DATA_SIZE-1 downto 0);
	signal data_atan_s      : signed(ALPHA_SIZE-1 downto 0);
begin

	i_div_s <= signed(data_i_i(DATA_SIZE-1 downto SHIFT_V));
	q_div_s <= signed(data_q_i(DATA_SIZE-1 downto SHIFT_V));

	sign_next_s <= data_i_i(DATA_SIZE-1) xor data_q_i(DATA_SIZE-1);

	s_i_div_s <= i_div_s     when sign_next_s = '1' else -i_div_s;
	s_q_div_s <= q_div_s     when sign_next_s = '1' else -q_div_s;
	s_alpha_s <= val_alpha_s when sign_next_s = '1' else -val_alpha_s;
	
	data_i_next_s    <= signed(data_i_i) - s_q_div_s;
	data_q_next_s    <= signed(data_q_i) + s_i_div_s;
	data_atan_next_s <= signed(data_atan_i) - s_alpha_s;

	process(clk)
	begin
		if rising_edge(clk) then
			sign_s <= sign_i;
			data_i_s <= data_i_next_s;
			data_q_s <= data_q_next_s;
			data_atan_s <= data_atan_next_s;
			data_en_o <= data_en_i;
		end if;
	end process;

	data_q_o    <= std_logic_vector(data_q_s);
	data_i_o    <= std_logic_vector(data_i_s);
	data_atan_o <= std_logic_vector(data_atan_s);
	sign_o      <= sign_s;

end architecture bhv;

