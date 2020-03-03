library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

Entity firComplex_proc is 
	generic (
		coeff_format : string := "signed";
		NB_COEFF : natural := 128;
		DATA_SIZE : natural := 16;
		DATA_OUT_SIZE : natural := 32;
		COEFF_SIZE : natural := 16
	);
	port 
	(
		-- Syscon signals
		reset		 : in std_logic;
		clk		   : in std_logic;
		-- input data
		ready_i : in std_logic;
		end_i : in std_logic;
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		coeff_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		data_en_i : in std_logic;
		data_i_o : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_q_o : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o : out std_logic
	);
end entity;

architecture bhv of firComplex_proc is
	constant MULT_SZ : natural := DATA_SIZE+COEFF_SIZE;
	constant INT_SZ : natural := MULT_SZ + natural(ceil(log2(real(NB_COEFF))));
	constant ALL_ZERO : std_logic_vector(INT_SZ-1 downto 0) 
		:= (INT_SZ-1 downto 0 => '0');

	signal ready_s : std_logic;
	signal must_rst_s : std_logic;
	-- i part 
	signal data_i_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal mult_i_res : std_logic_vector(MULT_SZ-1 downto 0);
	signal mux_accum_i_s  : std_logic_vector(INT_SZ-1 downto 0);
	signal res_i_s, res_i_next_s : std_logic_vector(INT_SZ-1 downto 0);
	signal final_res_i_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal final_res_i_next_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	-- q part 
	signal data_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal mult_q_res : std_logic_vector(MULT_SZ-1 downto 0);
	signal mux_accum_q_s  : std_logic_vector(INT_SZ-1 downto 0);
	signal res_q_s, res_q_next_s : std_logic_vector(INT_SZ-1 downto 0);
	signal final_res_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal final_res_q_next_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);

	signal data_en_s : std_logic;
	signal end_s : std_logic;
	signal data_out_en_s: std_logic;
begin
	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				data_en_s <= '0';
			else
				data_en_s <= data_en_i;
			end if;
			if reset = '1' then
				ready_s <= '0';
			elsif (data_en_i and ready_i) = '1' then
				ready_s <= '1';
			elsif end_i = '1' then
				ready_s <= '0';
			else
				ready_s <= ready_s;
			end if;
		end if;
	end process;
	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				data_i_s <= (others => '0');
				data_q_s <= (others => '0');
			elsif data_en_i = '1' then
				data_i_s <= data_i_i;
				data_q_s <= data_q_i;
			else
				data_i_s <= data_i_s;
				data_q_s <= data_q_s;
			end if;
		end if;
	end process;

	mult_i_res <= std_logic_vector(signed(data_i_s) * signed(coeff_i));
	mux_accum_i_s <= res_i_s when must_rst_s = '0' else ALL_ZERO;
	res_i_next_s <= std_logic_vector(signed(mult_i_res) + signed(mux_accum_i_s));

	mult_q_res <= std_logic_vector(signed(data_q_s) * signed(coeff_i));
	mux_accum_q_s <= res_q_s when must_rst_s = '0' else ALL_ZERO;
	res_q_next_s <= std_logic_vector(signed(mult_q_res) + signed(mux_accum_q_s));

	process(clk) begin
		if rising_edge(clk) then
			if (reset) = '1' then
				res_i_s <= (others => '0');
				res_q_s <= (others => '0');
			elsif (data_en_s and ready_s) = '1' then
				res_i_s <= res_i_next_s;
				res_q_s <= res_q_next_s;
			else
				res_i_s <= res_i_s;
				res_q_s <= res_q_s;
			end if;
		end if;
	end process;

	process(clk) begin
		if rising_edge(clk) then
			if (reset = '1') then
				end_s <= '0';
			else
				end_s <= end_i;
			end if;
			if reset = '1' then
				must_rst_s <= '0';
			elsif (ready_s and data_en_s) = '1' then
				must_rst_s <= end_i;
			else
				must_rst_s <= must_rst_s;
			end if;
		end if;
	end process;

	gt_size: if DATA_OUT_SIZE > INT_SZ generate
		final_res_i_next_s <= (DATA_OUT_SIZE-1 downto INT_SZ =>	res_i_s(INT_SZ-1))&res_i_s;
		final_res_q_next_s <= (DATA_OUT_SIZE-1 downto INT_SZ =>	res_q_s(INT_SZ-1))&res_q_s;
	end generate gt_size;
	same_size: if DATA_OUT_SIZE = INT_SZ generate
		final_res_i_next_s <= res_i_s;
		final_res_q_next_s <= res_q_s;
	end generate same_size;
	less_size: if DATA_OUT_SIZE < INT_SZ generate
		final_res_i_next_s <= res_i_s(DATA_OUT_SIZE-1 downto 0);
		final_res_q_next_s <= res_q_s(DATA_OUT_SIZE-1 downto 0);
	end generate less_size;

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				data_en_o <= '0';
			else
				data_en_o <= data_out_en_s;
			end if;
			if reset = '1' then
				final_res_i_s <= (others => '0');
				final_res_q_s <= (others => '0');
			elsif (data_out_en_s) = '1' then
				final_res_i_s <= final_res_i_next_s;
				final_res_q_s <= final_res_q_next_s;
			else
				final_res_i_s <= final_res_i_s;
				final_res_q_s <= final_res_q_s;
			end if;
		end if;
	end process;
	data_i_o <= final_res_i_s;
	data_q_o <= final_res_q_s;

	data_out_en_s <= data_en_s and end_s;

end architecture bhv;

