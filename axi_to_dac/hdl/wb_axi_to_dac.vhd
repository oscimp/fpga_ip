library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_axi_to_dac is 
    generic(
        id        : natural := 1;
        wb_size   : natural := 16 -- Data port size for wishbone
    );
    port 
    (
		-- Syscon signals
		reset     : in std_logic ;
		clk       : in std_logic ;
		-- Wishbone signals
		wbs_add       : in std_logic_vector(1 downto 0);
		wbs_write     : in std_logic ;
		wbs_writedata : in std_logic_vector( wb_size-1 downto 0);
		wbs_read     : in std_logic ;
		wbs_readdata  : out std_logic_vector( wb_size-1 downto 0);
		data_a_o : out std_logic_vector(wb_size-1 downto 0);
		data_a_en_o : out std_logic;
		data_b_o : out std_logic_vector(wb_size-1 downto 0);
		data_b_en_o : out std_logic
    );
end entity wb_axi_to_dac;


-----------------------------------------------------------------------
Architecture wb_axi_to_dac_1 of wb_axi_to_dac is
-----------------------------------------------------------------------
	constant REG_ID     : std_logic_vector := "00";
	constant REG_DATA_A : std_logic_vector :="01";
	constant REG_DATA_B : std_logic_vector :="10";
	signal data_a_s : std_logic_vector(wb_size-1 downto 0);
	signal data_b_s : std_logic_vector(wb_size-1 downto 0);
	signal readdata_s : std_logic_vector(wb_size-1 downto 0);
begin
    data_a_o <= data_a_s;
    data_b_o <= data_b_s;
	wbs_readdata <= readdata_s;
	-- manage register
	write_bloc : process(clk, reset)   -- write DEPUIS l'iMx
	begin
		 if reset = '1' then 
			 data_a_s <= (others => '0');
			data_a_en_o <= '0';
			data_b_s <= (others => '0');
			data_b_en_o <= '0';
		 elsif rising_edge(clk) then
			data_a_s <= data_a_s;
			data_a_en_o <= '0';
			data_b_s <= data_b_s;
			data_b_en_o <= '0';
			if wbs_write = '1' then
                case wbs_add is
                when REG_DATA_A =>
                    data_a_s <= wbs_writedata;
                    data_a_en_o <= '1';
                when REG_DATA_B =>
                    data_b_s <= wbs_writedata;
                    data_b_en_o <= '1';
                when others =>
                end case;
            end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk, reset)
	begin
		 if reset = '1' then 
			 readdata_s <= (others => '0');
		 elsif rising_edge(clk) then
		 	readdata_s <= readdata_s;
			if wbs_read = '1' then
                case wbs_add is
                when REG_DATA_A =>
					readdata_s <= data_a_s;
                when REG_DATA_B =>
					readdata_s <= data_b_s;
                when others =>
                end case;
            end if;
		 end if;
	end process read_bloc;



end architecture wb_axi_to_dac_1;

