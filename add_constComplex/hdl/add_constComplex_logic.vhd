library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity add_constComplex_logic is 
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
		data_i_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i : in std_logic;
		-- for the next component
		data_q_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_i_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o : out std_logic
	);
end entity;
Architecture bhv of add_constComplex_logic is
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
	signal data_add_i_s, data_add_q_s    : std_logic_vector(DATA_IN_SIZE downto 0);
	-- data_add_s delayed by one clock cycle
	signal data_res_i_s, data_res_q_s    : std_logic_vector(DATA_IN_SIZE downto 0);
	-- data with sature when DATA_OUT_SIZE < DATA_IN_SIZE + 1
	signal data_i_s, data_q_s            : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	-- comb + sync overflow detection
	signal overflow_i_s, overflow_i_d0_s : boolean;
	signal overflow_q_s, overflow_q_d0_s : boolean;
	-- comb + sync data_add_s MSB
	signal msb_i_s, msb_i_d0_s           : std_logic;
	signal msb_q_s, msb_q_d0_s           : std_logic;
begin
	msb_i_s <= data_add_i_s(DATA_IN_SIZE); -- A+B MSB
	msb_q_s <= data_add_q_s(DATA_IN_SIZE); -- A+B MSB

	-- when result MSB must be dropped
	lt_size: if DATA_OUT_SIZE < DATA_IN_SIZE + 1 generate
		-- signed
		lt_signed_size: if format = "signed" generate
			-- check overflow (all MSB including new MSB must be same)
			overflow_i_s <= not check_corrupt(data_add_i_s(DATA_IN_SIZE downto DATA_OUT_SIZE-1));
			overflow_q_s <= not check_corrupt(data_add_q_s(DATA_IN_SIZE downto DATA_OUT_SIZE-1));
			-- when overflow: use MSB from res to force max/min value or prop result
			data_i_o <= msb_i_d0_s & (DATA_OUT_SIZE-2 downto 0 => not msb_i_d0_s) when overflow_i_d0_s
					else data_i_s;
			data_q_o <= msb_q_d0_s & (DATA_OUT_SIZE-2 downto 0 => not msb_q_d0_s) when overflow_q_d0_s
					else data_q_s;
		end generate lt_signed_size;
		-- unsigned
		lt_unsigned_size: if format /= "signed" generate
			-- check is all removed bits are equal to '0'
			overflow_i_s <= not all_zero(data_add_i_s(DATA_IN_SIZE downto DATA_OUT_SIZE));
			overflow_q_s <= not all_zero(data_add_q_s(DATA_IN_SIZE downto DATA_OUT_SIZE));
			-- when overflow set max possible value or prop result
			data_i_o <= (DATA_OUT_SIZE-1 downto 0 => '1') when overflow_i_d0_s
					else data_i_s;
			data_q_o <= (DATA_OUT_SIZE-1 downto 0 => '1') when overflow_q_d0_s
					else data_q_s;
		end generate lt_unsigned_size;
	end generate lt_size;

	-- no truncation: nothing special
	gte_size: if DATA_OUT_SIZE >= DATA_IN_SIZE + 1 generate
		overflow_i_s <= false;
		overflow_q_s <= false;
		data_i_o     <= data_i_s;
		data_q_o     <= data_q_s;
	end generate gte_size;

	-- addition
	-- signed
	signed_op: if format = "signed" generate
		-- resize both members by adding one bit
		data_add_i_s <= std_logic_vector(resize(signed(data_i_i), DATA_IN_SIZE+1)
				+ resize(signed(add_val), DATA_IN_SIZE + 1));
		data_add_q_s <= std_logic_vector(resize(signed(data_q_i), DATA_IN_SIZE+1)
				+ resize(signed(add_val), DATA_IN_SIZE + 1));
		-- resize both members by adding one bit
		data_i_s <= std_logic_vector(resize(signed(data_res_i_s), DATA_OUT_SIZE));
		data_q_s <= std_logic_vector(resize(signed(data_res_q_s), DATA_OUT_SIZE));
	end generate signed_op;
	-- unsigned
	unsigned_op: if format /= "signed" generate
		-- resize both members by adding one bit
		data_add_i_s <= std_logic_vector(resize(unsigned(data_i_i), DATA_IN_SIZE+1)
				+ resize(unsigned(add_val), DATA_IN_SIZE + 1));
		data_add_q_s <= std_logic_vector(resize(unsigned(data_q_i), DATA_IN_SIZE+1)
				+ resize(unsigned(add_val), DATA_IN_SIZE + 1));
		-- resize both members by adding one bit
		data_i_s <= std_logic_vector(resize(unsigned(data_res_i_s), DATA_OUT_SIZE));
		data_q_s <= std_logic_vector(resize(unsigned(data_res_q_s), DATA_OUT_SIZE));
	end generate unsigned_op;

	-- add a delay (reduce timing constraints)
	process(clk_i) begin
		if rising_edge(clk_i) then
			data_en_o <= data_en_i;
			if data_en_i = '1' then
				data_res_i_s    <= data_add_i_s;
				data_res_q_s    <= data_add_q_s;
				overflow_i_d0_s <= overflow_i_s;
				overflow_q_d0_s <= overflow_q_s;
				msb_i_d0_s      <= msb_i_s;
				msb_q_d0_s      <= msb_q_s;
			end if;
			if rst_i = '1' then
				data_res_i_s    <= (others => '0');
				data_res_q_s    <= (others => '0');
				data_en_o       <= '0';
				overflow_i_d0_s <= false;
				overflow_q_d0_s <= false;
				msb_i_d0_s      <= '0';
				msb_q_d0_s      <= '0';
			end if;
		end if;
	end process;
end architecture bhv;

