---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2019
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

--Library UNISIM;
--use UNISIM.vcomponents.all;

entity mean_vector_axi_ram is
generic (
    DATA    : integer := 72;
    ADDR    : integer := 10
);
  port (
    clk_a : in std_logic;
	clk_b : in std_logic;
     -- state machine interface
    we_a  : in std_logic;
    addr_a: in std_logic_vector(ADDR-1 downto 0);
    din_a : in std_logic_vector(DATA-1 downto 0); 
    dout_a : out std_logic_vector(DATA-1 downto 0); 
    we_b  : in std_logic;
    addr_b: in std_logic_vector(ADDR-1 downto 0);
	din_b : in std_logic_vector(DATA-1 downto 0);
    dout_b: out std_logic_vector(DATA-1 downto 0)   
    );
end entity;
 
architecture rtl of mean_vector_axi_ram is
    -- Shared memory
    type mem_type is array ( (2**ADDR)-1 downto 0 ) of std_logic_vector(DATA-1 downto 0);
    shared variable mem : mem_type := (others => (others => '0'));
begin
 
-- Port A
process(clk_a)
begin
    if(clk_a'event and clk_a='1') then
        if(we_a='1') then
            mem(to_integer(unsigned(addr_a))) := din_a;
        end if;
        dout_a <= mem(to_integer(unsigned(addr_a)));
    end if;
end process;
 
-- Port B
process(clk_b)
begin
    if(clk_b'event and clk_b='1') then
        if(we_b='1') then
            mem(to_integer(unsigned(addr_b))) := din_b;
        end if;
        dout_b <= mem(to_integer(unsigned(addr_b)));
    end if;
end process;
 
end architecture rtl;
--end architecture ram_hard;
