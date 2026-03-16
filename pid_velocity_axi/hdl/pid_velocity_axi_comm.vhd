---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2019/04/20
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity pid_velocity_axi_comm is 
    generic(
		P_SIZE    : integer := 14;
		I_SIZE    : integer := 14;
		D_SIZE    : integer := 14;
		SETPOINT_SIZE : natural := 32;
        BUS_SIZE : natural := 32 -- Data port size
    );
    port 
    (
		-- Syscon signals
		reset       : in std_logic ;
		clk         : in std_logic ;
		-- comm signals
		addr_i      : in std_logic_vector(2 downto 0);
		wr_en_i     : in std_logic ;
		writedata_i : in std_logic_vector( BUS_SIZE-1 downto 0);
		rd_en_i     : in std_logic ;
		readdata_o  : out std_logic_vector( BUS_SIZE-1 downto 0);
		-- logic signals
		kp_o        : out std_logic_vector(P_SIZE-1 downto 0);
		ki_o        : out std_logic_vector(I_SIZE-1 downto 0);
		kd_o        : out std_logic_vector(D_SIZE-1 downto 0);
		sign_o      : out std_logic;
		setpoint_o  : out std_logic_vector(SETPOINT_SIZE-1 downto 0);
		int_rst_o   : out std_logic;
		is_input_o  : out std_logic_vector(5 downto 0)
    );
end entity pid_velocity_axi_comm;

Architecture pid_velocity_axi_comm_1 of pid_velocity_axi_comm is
	constant REG_KP       : std_logic_vector(2 downto 0) := "000";
	constant REG_KI       : std_logic_vector(2 downto 0) := "001";
	constant REG_KD       : std_logic_vector(2 downto 0) := "010";
	constant REG_SETPOINT : std_logic_vector(2 downto 0) := "011";
	constant REG_SIGN     : std_logic_vector(2 downto 0) := "100";
	constant REG_INT_RST  : std_logic_vector(2 downto 0) := "101";
	constant REG_INPUT    : std_logic_vector(2 downto 0) := "110";

	signal readdata_s      : std_logic_vector(BUS_SIZE-1 downto 0);
	signal readdata_next_s : std_logic_vector(BUS_SIZE-1 downto 0);

	signal setpoint_s : std_logic_vector(SETPOINT_SIZE-1 downto 0);
	signal kp_s       : std_logic_vector(P_SIZE-1 downto 0);
	signal ki_s       : std_logic_vector(I_SIZE-1 downto 0);
	signal kd_s       : std_logic_vector(D_SIZE-1 downto 0);
	signal sign_s     : std_logic;
	signal int_rst_s  : std_logic;
	signal is_input_s : std_logic_vector(5 downto 0);
begin
	readdata_o <= readdata_s;

	kp_o       <= kp_s;
	ki_o       <= ki_s;
	kd_o       <= kd_s;
	sign_o     <= sign_s;
	setpoint_o <= setpoint_s;
	int_rst_o  <= int_rst_s;
	is_input_o <= is_input_s;


	-- manage register
	write_bloc : process(clk)   -- write DEPUIS l'iMx
	begin
		 if rising_edge(clk) then
			if reset = '1' then 
				kp_s <= (others => '0');
				ki_s <= (others => '0');
				kd_s <= (others => '0');
				setpoint_s <= (others => '0');
				sign_s <= '0';
				int_rst_s <= '0';
				is_input_s <= "111111";
		 	else
				kp_s <= kp_s;
				ki_s <= ki_s;
				kd_s <= kd_s;
				setpoint_s <= setpoint_s;
				sign_s <= sign_s;
				int_rst_s <= int_rst_s;
				is_input_s <= is_input_s;
				if (wr_en_i = '1' ) then
					case addr_i is
					when REG_KP =>
						kp_s <= writedata_i(P_SIZE-1 downto 0);
					when REG_KI =>
						ki_s <= writedata_i(I_SIZE-1 downto 0);
					when REG_KD =>
						kd_s <= writedata_i(D_SIZE-1 downto 0);
					when REG_SETPOINT =>
						setpoint_s <= writedata_i(SETPOINT_SIZE-1 downto 0);
					when REG_SIGN =>
						sign_s <= writedata_i(0);
					when REG_INT_RST =>
						int_rst_s <= writedata_i(0);
					when REG_INPUT =>
						is_input_s <= writedata_i(5 downto 0);
					when others =>
					end case;
				end if;
			end if;
		 end if;
	end process write_bloc;

	read_async: process(addr_i, kp_s, ki_s, kd_s, setpoint_s, sign_s, is_input_s) begin
		case addr_i is
		when REG_KP =>
			readdata_next_s <= (BUS_SIZE-1 downto P_SIZE => kp_s(P_SIZE-1)) & kp_s;
		when REG_KI =>
			readdata_next_s <= (BUS_SIZE-1 downto I_SIZE => ki_s(P_SIZE-1)) & ki_s;
		when REG_KD =>
			readdata_next_s <= (BUS_SIZE-1 downto D_SIZE => kd_s(P_SIZE-1)) & kd_s;
		when REG_SETPOINT =>
			readdata_next_s <= (BUS_SIZE-1 downto SETPOINT_SIZE => setpoint_s(SETPOINT_SIZE-1)) & setpoint_s;
		when REG_SIGN =>
			readdata_next_s <= (BUS_SIZE-1 downto 1 => '0') & sign_s;
		when REG_INPUT =>
			readdata_next_s <= (BUS_SIZE-1 downto 6 => '0') & is_input_s;
		when others =>
			readdata_next_s <= (others => '1');
		end case;
	end process read_async;

	read_bloc : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				readdata_s <= (others => '0');
			elsif rd_en_i = '1' then
				readdata_s <= readdata_next_s;
			else
				readdata_s <= readdata_s;
			end if;
		end if;
	end process read_bloc;

end architecture pid_velocity_axi_comm_1;

