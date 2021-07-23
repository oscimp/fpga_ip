-- package declaration section
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package mylib is
    type STD_LOGIC_VECTOR_ARRAY_T is array (natural range <>) of std_logic_vector;
    type STD_LOGIC_ARRAY_T is array(natural range <>) of std_logic;
    type PORT_IN_T is record
        data_i_i	:  std_logic_vector;
		data_q_i	:  std_logic_vector;
		data_en_i	:  std_logic;
		data_clk_i	:  std_logic;
		data_eof_i	:  std_logic;
		data_rst_i	:  std_logic;
    end record PORT_IN_T;
    type PORT_ARRAY_T is array (natural range <>) of PORT_IN_T; 
    function log2_int( i : natural) return integer;    
end package;

package body mylib is
function log2_int( i : natural) return integer is
    variable temp    : integer := i;
    variable ret_val : integer := 0; 
  begin					
    while temp > 1 loop
      ret_val := ret_val + 1;
      temp    := temp / 2;     
    end loop;
    return ret_val;   
end function;
end package body;