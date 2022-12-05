library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity add_constReal_logic is
	generic (
		format       : string  := "signed";
		DATA_OUT_SIZE: natural := 18;
		DATA_IN_SIZE : natural := 16
	);
	port (
		-- Syscon signals
		rst_i     : in std_logic;
		clk_i     : in std_logic;
		-- config
		add_val   : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		-- input data
		data_i    : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i : in std_logic;
		-- for the next component
		data_o    : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o : out std_logic
	);
end entity;
Architecture bhv of add_constReal_logic is
	-- return true when all bits are equal to '0'
	-- ie similar to reduce or + compare
	function all_zero(slv : in std_logic_vector) return boolean is
		variable res_v : std_logic := '0';
	begin
		for i in slv'range loop
			res_v := res_v or slv(i);
		end loop;
		return res_v = '0';
	end function;

	-- return true when all bits are equal to '0' or to '1'
	-- ie similar to reduce or + and followed by a compare
	function check_corrupt(slv: in std_logic_vector) return boolean is
		variable res_or_v  : std_logic := '0';
		variable res_and_v : std_logic := '1';
	begin
		for i in slv'range loop
			res_and_v := res_and_v and slv(i);
			res_or_v  := res_or_v or slv(i);
		end loop;
		return res_and_v = '1' or res_or_v = '0';
	end function;

	-- addition result with enough bits (DATA_IN_SIZE + 1)
	signal data_add_s                : std_logic_vector(DATA_IN_SIZE downto 0);
	-- data_add_s delayed by one clock cycle
	signal data_res_s                : std_logic_vector(DATA_IN_SIZE downto 0);
	-- data with sature when DATA_OUT_SIZE < DATA_IN_SIZE + 1
	signal data_s                    : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	-- comb + sync overflow detection
	signal overflow_s, overflow_d0_s : boolean;
	-- comb + sync data_add_s MSB
	signal msb_s, msb_d0_s           : std_logic;
begin
	msb_s <= data_add_s(DATA_IN_SIZE); -- A+B MSB

	-- when result MSB must be dropped
	lt_size: if DATA_OUT_SIZE < DATA_IN_SIZE + 1 generate
		-- signed
		lt_signed_size: if format = "signed" generate
			-- check overflow (all MSB including new MSB must be same)
			overflow_s <= not check_corrupt(data_add_s(DATA_IN_SIZE downto DATA_OUT_SIZE-1));
			-- when overflow: use MSB from res to force max/min value or prop result
			data_o <= msb_d0_s & (DATA_OUT_SIZE-2 downto 0 => not msb_d0_s) when overflow_d0_s
					else data_s;
		end generate lt_signed_size;
		-- unsigned
		lt_unsigned_size: if format /= "signed" generate
			-- check is all removed bits are equal to '0'
			overflow_s <= not all_zero(data_add_s(DATA_IN_SIZE downto DATA_OUT_SIZE));
			-- when overflow set max possible value or prop result
			data_o <= (DATA_OUT_SIZE-1 downto 0 => '1') when overflow_d0_s
					else data_s;
		end generate lt_unsigned_size;
	end generate lt_size;

	-- no truncation: nothing special
	gte_size: if DATA_OUT_SIZE >= DATA_IN_SIZE + 1 generate
		overflow_s <= false;
		data_o     <= data_s;
	end generate gte_size;

	-- addition
	-- signed
	signed_op: if format = "signed" generate
		-- resize both members by adding one bit
		data_add_s <= std_logic_vector(resize(signed(data_i), DATA_IN_SIZE+1)
				+ resize(signed(add_val), DATA_IN_SIZE + 1));
		-- resize both members by adding one bit
		data_s     <= std_logic_vector(resize(signed(data_res_s), DATA_OUT_SIZE));
	end generate signed_op;
	-- unsigned
	unsigned_op: if format /= "signed" generate
		-- resize both members by adding one bit
		data_add_s <= std_logic_vector(resize(unsigned(data_i), DATA_IN_SIZE+1)
				+ resize(unsigned(add_val), DATA_IN_SIZE + 1));
		-- resize both members by adding one bit
		data_s     <= std_logic_vector(resize(unsigned(data_res_s), DATA_OUT_SIZE));
	end generate unsigned_op;

	-- add a delay (reduce timing constraints)
	process(clk_i) begin
		if rising_edge(clk_i) then
			data_en_o <= data_en_i;
			if data_en_i = '1' then
				data_res_s    <= data_add_s;
				overflow_d0_s <= overflow_s;
				msb_d0_s      <= msb_s;
			end if;
			if rst_i = '1' then
				data_res_s    <= (others => '0');
				data_en_o     <= '0';
				overflow_d0_s <= false;
				msb_d0_s      <= '0';
			end if;
		end if;
	end process;
end architecture bhv;

