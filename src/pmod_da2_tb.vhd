--------------------------------------------------------------------------------
-- Engineer:        Eric Hansen
-- Course:	 		Engs 31 16X
--
-- Create Date:     07/22/2016
-- Design Name:   
-- Module Name:     pmod_ad1_tb.vhd
-- Project Name:    Lab5
-- Target Device:  
-- Tool versions:  
-- Description:     VHDL Test Bench for module: pmod_ad1
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;
 
ENTITY DtoA_tb IS
END DtoA_tb;
 
ARCHITECTURE behavior OF DtoA_tb IS 

component DtoA
PORT ( 	sclk		:	in 	std_logic;
		take_sample	:	in	std_logic;
        data_in		:	in	std_logic_vector(15 downto 0);
        spi_sclk	:	out std_logic;
        spi_sync	:	out	std_logic;
        spi_DinA	:	out	std_logic);
end component; 

   --Inputs
    signal sclk : std_logic := '0';
    signal take_sample : std_logic := '0';
    signal data_in : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
    signal spi_sclk : std_logic := '0';
    signal spi_sync : std_logic := '1';
    signal spi_DinA : std_logic := '0';
     
    -- Clock period definitions
    constant sclk_period : time := 1 us;		   -- 1 MHz serial clock
    constant sampling_count_tc : integer := 25;    -- to achieve a 40 kHz sampling rate, for testing
	
	-- Data definitions
	constant TxData : std_logic_vector(15 downto 0) := "0111000001101001";
	signal bit_count : integer := 15;

	-- Internal definitions
	signal sampling_count : integer := 0;
	
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
 
uut: DtoA port map(
        sclk => sclk, 
        take_sample => take_sample,
        data_in => data_in,
        
        -- SPI bus interface to Pmod AD1
        spi_sclk => spi_sclk,
        spi_sync => spi_sync,
        spi_DinA => spi_DinA );
        
   -- Clock process definitions
   clk_process: process
   begin
		sclk <= '0';
		wait for sclk_period/2;
		sclk <= '1';
		wait for sclk_period/2;
   end process;
 
   -- Stimulus process:  testbench pretends to the top level
   stim_proc_1: process(sclk)
   begin
    if rising_edge(sclk) then
        if sampling_count < sampling_count_tc-1 then
            sampling_count <= sampling_count + 1;
            take_sample <= '0';
        else
            sampling_count <= 0;
            take_sample <= '1';      -- push take_sample to interface to initiate a conversion
            data_in <= TxData;
        end if;
    end if;
   end process stim_proc_1;

   -- Stimulus process:  testbench pretends to be the D/A converter   
   stim_proc_2: process(spi_sclk)  
   begin
    if falling_edge(spi_sclk) then   
        if spi_sync = '0' then		 
			if bit_count = 0 then bit_count <= 15;
			else bit_count <= bit_count - 1;
			end if;		
		end if;		
    end if;
   end process stim_proc_2;
END;