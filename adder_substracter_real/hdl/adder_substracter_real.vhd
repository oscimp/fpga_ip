library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity adder_substracter_real is 
	generic (
		format : string := "signed";
		opp : string := "add";
		DATA_SIZE : natural := 16
	);
	port 
	(
		-- input data
		data1_i				: in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_i			: in std_logic;
		data1_sof_i			: in std_logic := '0';
		data1_eof_i			: in std_logic := '0';
		data1_clk_i			: in std_logic;
		data1_rst_i			: in std_logic;
		data2_i				: in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_i			: in std_logic;
		data2_sof_i			: in std_logic := '0';
		data2_eof_i			: in std_logic := '0';
		data2_clk_i			: in std_logic;
		data2_rst_i			: in std_logic;
		-- for the next component
		data_o				: out std_logic_vector(DATA_SIZE downto 0);		
		data_en_o			: out std_logic;
		data_sof_o			: out std_logic;
		data_eof_o			: out std_logic;
		data_clk_o			: out std_logic;
		data_rst_o			: out std_logic
	);
end entity;
Architecture adder_substracter_real_1 of adder_substracter_real is
	signal data_in_s, data_s : std_logic_vector(DATA_SIZE downto 0);
	signal data_en_s, data_eof_s, data_sof_s : std_logic;
	signal data1_s, data2_s : std_logic_vector(DATA_SIZE-1 downto 0);

	signal data11_en_s, data21_en_s : std_logic;
	signal data11_sof_s, data21_sof_s : std_logic;
	signal data11_eof_s, data21_eof_s : std_logic;
	signal data11_s, data21_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal d1_en_s, d2_en_s : std_logic;
	signal d1_sof_s, d2_sof_s : std_logic;
	signal d1_eof_s, d2_eof_s : std_logic;
	-- resize before operation
	signal d1_s, d2_s : std_logic_vector(DATA_SIZE downto 0);
begin
	data_clk_o <= data1_clk_i;
	data_rst_o <= data1_rst_i;

	process(data1_clk_i)
	begin
		if rising_edge(data1_clk_i) then
			data11_en_s <= data1_en_i;
			if data1_en_i = '1' then
				data11_s <= data1_i;
				data11_sof_s <= data1_sof_i;
				data11_eof_s <= data1_eof_i;
			else
				data11_s <= data11_s;
				data11_sof_s <= '0';
				data11_eof_s <= '0';
			end if;
		end if;
	end process;

	process(data2_clk_i)
	begin
		if rising_edge(data2_clk_i) then
			data21_en_s <= data2_en_i;
			if data2_en_i = '1' then
				data21_s <= data2_i;
				data21_sof_s <= data2_sof_i;
				data21_eof_s <= data2_eof_i;
			else
				data21_s <= data21_s;
				data21_sof_s <= '0';
				data21_eof_s <= '0';
			end if;
		end if;
	end process;


	-- resynchro
	process(data1_clk_i)
	begin
		if rising_edge(data1_clk_i) then

            if (data11_en_s = '1') then
            	data1_s <= data11_s;
            	d1_en_s <= '1';
            	d1_sof_s <= data11_sof_s;
            	d1_eof_s <= data11_eof_s;
			else
				data1_s <= data1_s;
            	d1_en_s <= d1_en_s;
            	d1_sof_s <= d1_sof_s;
            	d1_eof_s <= d1_eof_s;
            end if;
            if (data21_en_s = '1') then
            	data2_s <= data21_s;
            	d2_en_s <= '1';
            	d2_sof_s <= data21_sof_s;
            	d2_eof_s <= data21_eof_s;
			else
            	data2_s <= data2_s;
            	d2_en_s <= d2_en_s;
            	d2_sof_s <= d2_sof_s;
            	d2_eof_s <= d2_eof_s;
			end if;

			if (data11_en_s and d2_en_s) = '1' then
            	data_en_s <= '1';
				data_sof_s <= data11_sof_s and d2_sof_s;
				data_eof_s <= data11_eof_s and d2_eof_s;
                d1_en_s <= '0';
                d2_en_s <= '0';
				d1_sof_s <= '0';
				d2_sof_s <= '0';
				d1_eof_s <= '0';
				d2_eof_s <= '0';
            elsif (data21_en_s and d1_en_s) = '1' then
                data_en_s <= '1';
				data_sof_s <= d1_sof_s and data21_sof_s;
				data_eof_s <= d1_eof_s and data21_eof_s;
                d1_en_s <= '0';
                d2_en_s <= '0';
				d1_eof_s <= '0';
				d2_eof_s <= '0';
				d1_sof_s <= '0';
				d2_sof_s <= '0';
            elsif (data11_en_s and data21_en_s) = '1' then
                data_en_s <= '1';
				data_sof_s <= data11_sof_s and data21_sof_s;
				data_eof_s <= data11_eof_s and data21_eof_s;
                d1_en_s <= '0';
                d2_en_s <= '0';
				d1_sof_s <= '0';
				d2_sof_s <= '0';
				d1_eof_s <= '0';
				d2_eof_s <= '0';
            else
                data_en_s <= '0';
                data_sof_s <= '0';
                data_eof_s <= '0';
            end if;
		end if;
	end process;

	signed_prod: if format = "signed" generate
		d1_s <= data1_s(DATA_SIZE-1) & data1_s;
		d2_s <= data2_s(DATA_SIZE-1) & data2_s;
		opp_sub: if opp /= "add" generate
			data_in_s <= std_logic_vector(signed(data1_s) - signed(d2_s));
		end generate opp_sub;
		opp_add: if opp = "add" generate
			data_in_s <= std_logic_vector(signed(data1_s) + signed(d2_s));
		end generate opp_add;
	end generate signed_prod;
	unsigned_prod: if format /= "signed" generate
		d1_s <= '0' & data1_s;
		d2_s <= '0' & data2_s;
		opp_sub: if opp /= "add" generate
			data_in_s <= std_logic_vector(unsigned(d1_s) - unsigned(d2_s));
		end generate opp_sub;
		opp_add: if opp = "add" generate
			data_in_s <= std_logic_vector(unsigned(d1_s) + unsigned(d2_s));
		end generate opp_add;
	end generate unsigned_prod;

	data_o <= data_s;

	process(data1_clk_i)
	begin
		if rising_edge(data1_clk_i) then
			data_en_o <= data_en_s;
			if data_en_s = '1' then
				data_s <= data_in_s;
				data_sof_o <= data_sof_s;
				data_eof_o <= data_eof_s;
			else
				data_s <= data_s;
				data_sof_o <= '0';
				data_eof_o <= '0';
			end if;
		end if;
	end process;
end architecture adder_substracter_real_1;

