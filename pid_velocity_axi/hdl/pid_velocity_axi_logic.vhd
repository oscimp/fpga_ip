library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

--
-- Implementation of a PI in velocity form.
-- Formulation of PID in velocity form:
-- u(k) = u(k-1) + Kp * [e(k) - e(k-1) + T/Ti*e(k)] + Kp * [Td/T (e(k) - 2*e(k-1) + e(k-2))]
-- If Derivative action is null, i.e.: Td = 0:
-- u(k) = u(k-1) + Kp * [e(k) - e(k-1) + T/Ti*e(k)]
-- u(k) = u(k-1) + Kp*e(k) - Kp*e(k-1) + Kp*T/Ti*e(k)
-- u(k) = u(k-1) + (Kp + Kp*T/Ti)*e(k) - Kp*e(k-1)
--

entity pid_velocity_axi_logic is
	generic (
		K_SIZE : integer := 8;
		K_SR : integer := 0;
		UN_SR : integer := 4;
		DATA_IN_SIZE : natural := 14;
		DATA_OUT_SIZE : natural := 32
	);
	port (
		--syscon signals
		clk_i : in std_logic;
		reset : in std_logic;
		--data
		data_i : in std_logic_vector(DATA_IN_SIZE - 1 downto 0);
		data_en_i : in std_logic;
		data_o : out std_logic_vector(DATA_OUT_SIZE - 1 downto 0);
		data_en_o : out std_logic;
		--settings
		setpoint_i : in std_logic_vector(DATA_IN_SIZE - 1 downto 0);
		k1_i : in std_logic_vector(K_SIZE - 1 downto 0);
		k2_i : in std_logic_vector(K_SIZE - 1 downto 0);
		sign_i : in std_logic
	);
end entity;

architecture behavioral of pid_velocity_axi_logic is
	-- Return static size or difference between input and output size
	-- if in_size > out_size
	function comp_unused_slice(in_size, out_size : natural) return natural is
	begin
		if (in_size > out_size) then
			return (in_size - out_size + 1);
		else
			return(1);
		end if;
	end function comp_unused_slice;

	--
	constant ERR_SZ : natural := DATA_IN_SIZE + 1;
	signal data_in_s : signed(ERR_SZ - 1 downto 0);
	signal setpoint_s : signed(ERR_SZ - 1 downto 0);
	signal err_s : signed(ERR_SZ - 1 downto 0); -- Error @ n
	signal err1_s : signed(ERR_SZ - 1 downto 0); -- Error @ n-1
	signal data_en_s : std_logic;
	signal data1_en_s : std_logic;
	-- signal data2_en_s : std_logic;
	-- k1, k2
	constant K_MULT_SZ : natural := ERR_SZ + K_SIZE;
	constant K_MULT_RES_SZ : natural := K_MULT_SZ - K_SR;
	signal k1err_a_s : signed(K_MULT_SZ - 1 downto 0); -- Async product k1*err
	signal k1err_s : signed(K_MULT_RES_SZ - 1 downto 0); -- Product k1*err
	signal k2err1_a_s : signed(K_MULT_SZ - 1 downto 0); -- Async product k2*err1
	signal k2err1_s : signed(K_MULT_RES_SZ - 1 downto 0); -- Product k2*err1
	-- u_n = u_n1 + k1*er_n + k2*er_n1
	constant UN_SZ : natural := K_MULT_RES_SZ + 2;
	constant UN_RES_SZ : natural := UN_SZ - UN_SR;
	signal un_a_s : signed(UN_SZ - 1 downto 0); -- Async theoritical output @ n
	signal un_s : signed(UN_RES_SZ - 1 downto 0); -- Theoritical output @ n

	-- size of the dropped part of input signal
	constant MSB_SIZE : natural := comp_unused_slice(UN_RES_SZ, DATA_OUT_SIZE);
	-- dropped part of the I input signal
	signal msb_s : std_logic_vector(MSB_SIZE - 1 downto 0);
	-- check is high slice is fully 0 and 1
	signal is_zero, is_one : boolean;

begin
	data_in_s <= signed(data_i(DATA_IN_SIZE - 1) & data_i);
	setpoint_s <= signed(setpoint_i(DATA_IN_SIZE - 1) & setpoint_i);

	-- Generate error signal
	process (clk_i) begin
		if rising_edge(clk_i) then
			if data_en_i = '1' then
				if sign_i = '0' then
					err_s <= data_in_s - setpoint_s; --negative sign
				else
					err_s <= setpoint_s - data_in_s; --positive sign
				end if;
			end if;

			if reset = '1' then
				err_s <= (others => '0');
			end if;
		end if;
	end process;

	-- generate delayed error signal
	process (clk_i) begin
		if rising_edge(clk_i) then
			if data_en_i = '1' then
				err1_s <= err_s;
			end if;

			if reset = '1' then
				err1_s <= (others => '0');
			end if;
		end if;
	end process;

	-- Generate data_en_s signal
	process (clk_i) begin
		if rising_edge(clk_i) then
			data_en_s <= data_en_i;

			if reset = '1' then
				data_en_s <= '0';
			end if;
		end if;
	end process;

	--  Generate k1*er_n and k2*er_n1
	k1err_a_s <= signed(k1_i) * err_s;
	k2err1_a_s <= signed(k2_i) * err1_s;
	process (clk_i)
	begin
		if rising_edge(clk_i) then
			if data_en_s = '1' then
				k1err_s <= k1err_a_s(K_MULT_SZ - 1 downto K_SR);
				k2err1_s <= k2err1_a_s(K_MULT_SZ - 1 downto K_SR);
			end if;

			if reset = '1' then
				k1err_s <= (others => '0');
				k2err1_s <= (others => '0');
			end if;
		end if;
	end process;

	-- Generate data1_en_s signal
	process (clk_i)
	begin
		if rising_edge(clk_i) then
			data1_en_s <= data_en_s;

			if reset = '1' then
				data1_en_s <= '0';
			end if;
		end if;
	end process;

	-- Generate un_s signal: u_n = u_n1 + k1*er_n + k2*er_n1
	--un_a_s <= std_logic_vector((U_MULT_RES_SZ downto 0 => '0') + un1_s + k1err_s + k2err1_s);
	un_a_s <= un_s + k1err_s + k2err1_s;
	process (clk_i) begin
		if rising_edge(clk_i) then
			if data1_en_s = '1' then
				un_s <= un_a_s(UN_SZ - 1 downto UN_SR);
			end if;

			if reset = '1' then
				un_s <= (others => '0');
			end if;
		end if;
	end process;

	-- Generate data2_en_s signal
	-- process (clk_i)
	-- begin
	-- 	if rising_edge(clk_i) then
	-- 		data2_en_s <= data1_en_s;

	-- 		if reset = '1' then
	-- 			data2_en_s <= '0';
	-- 		end if;
	-- 	end if;
	-- end process;

	-- Generate data_en_o signal
	process (clk_i)
	begin
		if rising_edge(clk_i) then
			data_en_o <= data1_en_s;

			if reset = '1' then
				data_en_o <= '0';
			end if;
		end if;
	end process;

	-- Generate data output signal
	lt_size : if DATA_OUT_SIZE < UN_RES_SZ generate
		msb_s <= std_logic_vector(un_s(UN_RES_SZ - 1 downto UN_RES_SZ - MSB_SIZE));
		is_zero <= msb_s = (MSB_SIZE - 1 downto 0 => '0');
		is_one <= msb_s = (MSB_SIZE - 1 downto 0 => '1');
		check_sature : process (un_s, msb_s, is_zero, is_one) begin
			-- no overflow
			if is_one or is_zero then
				data_o <= std_logic_vector(un_s(DATA_OUT_SIZE - 1 downto 0));
			-- negative overflow
			elsif msb_s(MSB_SIZE - 1) = '1' then
				data_o <= '1' & (DATA_OUT_SIZE - 2 downto 0 => '0');
			-- positive overflow
			else
				data_o <= '0' & (DATA_OUT_SIZE - 2 downto 0 => '1');
			end if;
		end process check_sature;
	end generate lt_size;
	--
	gt_size : if DATA_OUT_SIZE > UN_RES_SZ generate
		data_o <= (DATA_OUT_SIZE - 1 downto UN_RES_SZ => un_s(UN_RES_SZ - 1))
			& std_logic_vector(un_s(UN_RES_SZ - 1 downto 0));
	end generate gt_size;
	--
	same_size : if DATA_OUT_SIZE = UN_RES_SZ generate
		data_o <= std_logic_vector(un_s);
	end generate same_size;

end behavioral;