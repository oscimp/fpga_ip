library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_pwmaxi is
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- conf
		enable_i    : in std_logic;
		duty_i      : in std_logic_vector(31 downto 0);
		period_i    : in std_logic_vector(31 downto 0);
		prescaler_i : in std_logic_vector(31 downto 0);
		-- out
		pwm1_o : out std_logic;
		pwm2_o : out std_logic
	);
end top_pwmaxi;

architecture Behavioral of top_pwmaxi is
begin
	dutInvertN : entity work.pwm_logic
	generic map (COUNTER_SIZE => 32 )
	port map (
		clk => clk_i, reset => rst_i,
		enable_i => enable_i, invert_i => '0',
		prescaler_i => prescaler_i,
		duty_i => duty_i, period_i => period_i,
		pwm_o => pwm1_o
	);

	dutInvert : entity work.pwm_logic
	generic map (COUNTER_SIZE => 32)
	port map (
		clk => clk_i, reset => rst_i,
		enable_i => enable_i, invert_i => '1',
		prescaler_i => prescaler_i,
		duty_i => duty_i, period_i => period_i,
		pwm_o => pwm2_o
	);

end Behavioral;
