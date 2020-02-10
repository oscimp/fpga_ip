library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity pwm_logic is 
generic(
	COUNTER_SIZE : natural := 32
);
port (
	-- CANDR
	reset  : in std_logic;
	clk    : in std_logic;
	-- conf
	enable_i    : in std_logic;
	invert_i    : in std_logic;
	duty_i      : in std_logic_vector(COUNTER_SIZE-1 downto 0);
	period_i    : in std_logic_vector(COUNTER_SIZE-1 downto 0);
	prescaler_i : in std_logic_vector(COUNTER_SIZE-1 downto 0);
	-- out signals
	pwm_o       : out std_logic 
);
end entity pwm_logic;

Architecture bhv of pwm_logic is
	signal pwm_reg   : std_logic;
	signal tick_s    : std_logic;
	signal nb_tick_s : unsigned(COUNTER_SIZE-1 downto 0);
begin
	pwm_o <= (pwm_reg xor invert_i) and enable_i;
	pwm_reg <= '1' when nb_tick_s < unsigned(duty_i)
			else '0';

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				nb_tick_s <= (others => '0');
			elsif (tick_s = '1') then
				if nb_tick_s < unsigned(period_i) -1 then
					nb_tick_s <= nb_tick_s + 1;
				else 
					nb_tick_s <= (others => '0');
				end if;
			end if;
		end if;
	end process;

	pwm_cpt_inst : entity work.pwm_cpt
	generic map (CPT_SIZE => COUNTER_SIZE)
	port map (clk_i => clk, reset_i => reset,
		enable_i => enable_i,
		max_cpt_i => prescaler_i, tick_o => tick_s);
end architecture bhv;

