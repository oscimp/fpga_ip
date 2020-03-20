library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity pidv3_axi_logic is 
	generic (
		P_SIZE : integer := 16;
		PSR : integer := 12; --PSR_SIZE
		I_SIZE : integer := 16;
		ISR : integer := 18;
		D_SIZE : integer := 16;
		DSR : integer := 10;
		DATA_IN_SIZE : natural := 14;
		DATA_OUT_SIZE : natural := 14
	);
	port
	(
		--syscon signals
		clk_i    : in std_logic;
		reset   : in std_logic;
		--data
		data_i	 : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_o	 : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o: out std_logic;
		--settings
		--implementer le sens
		setpoint_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		kp_i	   : in std_logic_vector(P_SIZE-1 downto 0);
		ki_i	   : in std_logic_vector(I_SIZE-1 downto 0);
		kd_i	   : in std_logic_vector(D_SIZE-1 downto 0);
		sign_i	   : in std_logic;
		int_rst_i  : in std_logic
	);
end entity;

Architecture behavioral of pidv3_axi_logic is
	--sig
	constant ERR_SZ : natural := DATA_IN_SIZE+1;
	signal data_in_s  : std_logic_vector(ERR_SZ-1 downto 0);
	signal setpoint_s : std_logic_vector(ERR_SZ-1 downto 0);
	signal error_s 	  : std_logic_vector(ERR_SZ-1 downto 0);
	signal data_en_s  : std_logic;
	signal data2_en_s : std_logic;
	signal data_en_out_s : std_logic;
	-- p --
	constant P_MULT_SZ 	: natural := ERR_SZ + P_SIZE;
	constant P_RES_SZ 	: natural := P_MULT_SZ-PSR;
	signal P_temp_s	  	: std_logic_vector(P_MULT_SZ-1 downto 0);
	signal P_s 	  		: std_logic_vector(P_RES_SZ-1 downto 0);

	-- i --
	--signal I_desat_s  : std_logic_vector(33-1 downto 0);
	constant I_MULT_SZ	: natural := ERR_SZ + I_SIZE;
	constant I_RES_SZ 	: natural := I_MULT_SZ-ISR;
	signal I_sum_s	  	: std_logic_vector(I_MULT_SZ downto 0); --somme avec overflow detect
    signal I_temp_s      : std_logic_vector(I_MULT_SZ-1 downto 0); --somme utile
	signal I_s	  		: std_logic_vector(I_RES_SZ-1 downto 0);
	--signal I_s	  : std_logic_vector(33-1 downto 0);

	function sel(P, I: natural) return natural is
	begin
		if (P >= I) then
			return(P);
		else
			return(I);
		end if;
	end function sel;
	constant PID_SZ   : natural  := sel(P_RES_SZ, I_RES_SZ);

	signal p_pid_s 	  : std_logic_vector(PID_SZ-1 downto 0);
	signal i_pid_s 	  : std_logic_vector(PID_SZ-1 downto 0);
	signal pid_sum_s  : std_logic_vector(PID_SZ downto 0);	--v_k
	signal pid_out_s  : std_logic_vector(PID_SZ-1 downto 0); 	--u_k
	
begin
	data_in_s <= data_i(DATA_IN_SIZE-1)&data_i; --msb extension (-> sign bit)
	setpoint_s <= setpoint_i(DATA_IN_SIZE-1)&setpoint_i;

	--error signal
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			data_en_s <= '0';
			if reset = '1' then
				error_s <= (others => '0');
			else
				error_s <= error_s;
				if data_en_i = '1' then
					if sign_i = '0' then
						error_s <= std_logic_vector(signed(data_in_s) - signed(setpoint_s)); --negative sign
					else
						error_s <= std_logic_vector(signed(setpoint_s) - signed(data_in_s)); --positive sign
					end if;
					data_en_s <= '1';
				end if;
			end if;
		end if;
	end process;

	--proportional part
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			data2_en_s <= '0';
			if reset = '1' then
				P_s  <= (others => '0');
			else
				P_s <= P_s;
				if data_en_s = '1' then
					P_s <= P_temp_s(P_MULT_SZ-1 downto PSR); 
					data2_en_s <= '1' ;
				end if;
			end if;
		end if;
	end process;
	P_temp_s <= std_logic_vector(signed(kp_i)*signed(error_s));

	--integral part
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if (reset or int_rst_i) = '1' then --ici aussi le reset_int
				I_s <= (others => '0');
                I_temp_s <= (others => '0');
			else 
				I_s <= I_s;
                I_temp_s <= I_temp_s;
				if data_en_s = '1' then
					if (I_sum_s(I_MULT_SZ downto I_MULT_SZ-1) = "01") then
						I_temp_s <= '0' & (I_MULT_SZ-2 downto 0 => '1');
					elsif (I_sum_s(I_MULT_SZ downto I_MULT_SZ-1) = "10") then
						I_temp_s <= '1' & (I_MULT_SZ-2 downto 0 => '0');
                    else
						I_temp_s <= I_sum_s(I_MULT_SZ-1 downto 0);
					end if;
					I_s <= I_temp_s(I_MULT_SZ-1 downto ISR);
				end if;
			end if;
		end if;
	end process;
	I_sum_s <= std_logic_vector( (I_MULT_SZ downto 0 => '0') + signed(I_temp_s) + (signed(ki_i)*signed(error_s)) );

	--derivative --none for the moment

	--sum + sat + integr desat
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			data_en_o <= '0';
			if reset = '1' then
				pid_out_s <= (others => '0');
			else 
				pid_out_s <= pid_out_s;
				if data2_en_s ='1' then
					data_en_o <= '1';
					if (pid_sum_s(PID_SZ downto PID_SZ -1) = "01") then
						pid_out_s <= '0' & ( PID_SZ-2 downto 0 =>'1'); 
					elsif ( pid_sum_s (PID_SZ downto PID_SZ-1) = "10") then
						pid_out_s <=  '1' & (PID_SZ-2 downto 0 => '0');
                    else
						pid_out_s <= pid_sum_s(PID_SZ-1 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	p_diff_size : if P_RES_SZ < PID_SZ generate
		p_pid_s <= (PID_SZ-1 downto P_RES_SZ => P_s(P_RES_SZ-1)) & P_s;
	end generate p_diff_size;
	p_same_size : if P_RES_SZ = PID_SZ generate
		p_pid_s <= P_s;
	end generate p_same_size;
	i_diff_size : if I_RES_SZ < PID_SZ generate
		i_pid_s <= (PID_SZ-1 downto I_RES_SZ => I_s(I_RES_SZ-1)) & I_s;
	end generate i_diff_size;
	i_same_size : if I_RES_SZ = PID_SZ generate
		i_pid_s <= I_s;
	end generate i_same_size;

	pid_sum_s <= std_logic_vector( (PID_SZ downto 0 => '0') + signed(p_pid_s) + signed(i_pid_s));

	--output
	lt_size : if DATA_OUT_SIZE < PID_SZ generate
		data_o <= pid_out_s(DATA_OUT_SIZE-1 downto 0);
	end generate lt_size;
	gt_size : if DATA_OUT_SIZE > PID_SZ generate
		data_o <= (DATA_OUT_SIZE-1 downto PID_SZ => pid_out_s(PID_SZ-1))
			&pid_out_s(DATA_OUT_SIZE-1 downto 0);
	end generate gt_size;
	same_size : if DATA_OUT_SIZE = PID_SZ generate
		data_o <= pid_out_s;
	end generate same_size;

end behavioral;
