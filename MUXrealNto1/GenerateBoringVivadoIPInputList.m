% script to generate the boring list of inputs and generate statements for MUXrealNto1top.vhd
clc, clear all
N = 32

for ii = 0:N - 1
    fprintf("\t\tdata_%d_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');\n",ii)
    fprintf("\t\tdata_%d_en_i  : in STD_LOGIC := '0';\n",ii)
    fprintf("\t\tdata_%d_clk_i : in STD_LOGIC := '0';\n",ii)
    fprintf("\t\tdata_%d_eof_i : in STD_LOGIC := '0';\n",ii)
    fprintf("\t\tdata_%d_rst_i : in STD_LOGIC := '0';\n\n",ii)  
end

ii = 0
   fprintf ("data_i_s(%d) <= data_%d_i_i;\n",ii,ii);
   fprintf ("data_en_s(%d) <= data_%d_en_i;\n",ii,ii);
   fprintf ("data_clk_s(%d) <= data_%d_clk_i;\n",ii,ii);
   fprintf ("data_eof_s(%d) <= data_%d_eof_i;\n",ii,ii);
   fprintf ("data_rst_s(%d) <= data_%d_rst_i;\n",ii,ii);

for ii = 1: N-1 
 fprintf("\tinput%d: if INPUTS > %d generate\n",ii,ii)   
   fprintf ("\t\tdata_i_s(%d) <= data_%d_i_i;\n",ii,ii);
   fprintf ("\t\tdata_en_s(%d) <= data_%d_en_i;\n",ii,ii);
   fprintf ("\t\tdata_clk_s(%d) <= data_%d_clk_i;\n",ii,ii);
   fprintf ("\t\tdata_eof_s(%d) <= data_%d_eof_i;\n",ii,ii);
   fprintf ("\t\tdata_rst_s(%d) <= data_%d_rst_i;\n",ii,ii);
 fprintf("\tend generate input%d;\n",ii);
end
   
    
   

 

