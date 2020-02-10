library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity pwm_cpt is 
generic(
	CPT_SIZE : natural := 32
);
port (
	clk_i     : in std_logic;
	reset_i   : in std_logic;
	enable_i  : in std_logic;
	max_cpt_i : in std_logic_vector(CPT_SIZE-1 downto 0);
	tick_o    : out std_logic
);
end entity pwm_cpt;

Architecture bhv of pwm_cpt is
	signal cpt_s, max_cpt_s : unsigned(CPT_SIZE-1 downto 0);
	signal clr_cpt_s, rst_s : std_logic;
begin
	max_cpt_s <= unsigned(max_cpt_i) - 1;
	rst_s <= '1' when (reset_i or not enable_i) = '1' else '0';

	clr_cpt_s <= '1' when cpt_s = (CPT_SIZE-1 downto 0 => '0') else '0';

	tick_o <= clr_cpt_s;
	prescaler : process(clk_i) 
	begin
		if rising_edge(clk_i) then
			if (rst_s or clr_cpt_s) = '1' then
				cpt_s <= max_cpt_s;
			else
				cpt_s <= cpt_s - 1;
			end if;
		end if;
	end process prescaler;

end architecture bhv;
