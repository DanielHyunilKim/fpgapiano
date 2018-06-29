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
 
ENTITY FrequencyCounter_tb IS
END FrequencyCounter_tb;
 
ARCHITECTURE behavior OF FrequencyCounter_tb IS 

component FrequencyCounter
port (-- interface to top level
       clk			:	in std_logic;
       take_sample	:	in std_logic;
		key			:	in	std_logic_vector(7 downto 0);
		lut_input	: 	out	std_logic_vector(15 downto 0));

end component; 

   --Inputs
    signal clk : std_logic := '0';
    signal take_sample : std_logic := '0';
    signal key : std_logic_vector(7 downto 0) := "00000000";
    signal lut_input : std_logic_vector(15 downto 0) := "0000000000000000" ;

 	constant clk_period : time := 1 ns;
	
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
 
uut: FrequencyCounter port map(
        clk => clk, 
        take_sample => take_sample,
        key => key,
        lut_input => lut_input
        );

   -- Clock process definitions
   clk_process: process
   begin
		clk <= '0';
		wait for clk_period;
		clk <= '1';
		wait for clk_period;
   end process;
 
 process
 begin
 	wait for clk_period*5;
    
    take_sample <= '1';
    Key <= "00000001";
    wait for clk_period*15;
    
    take_sample <= '0';
    wait for clk_period*15;
    Key <= "00000000";
    wait for clk_period*10;
    
    take_sample <= '1';
    Key <= "00000010";
    wait for clk_period*15;
    take_sample <= '0';
    wait for clk_period*15;
    Key <= "00000000";
    wait for clk_period*10;
    
    take_sample <= '1';
    Key <= "00000100";
    wait for clk_period*15;
    take_sample <= '0';
    wait for clk_period*15;
    Key <= "00000000";
    wait;
    
end process;
  
END;