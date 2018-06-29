----------------------------------------------------------------------------------
-- Company: ENGS 31
-- Engineer: Daniel Kim, Alex Martinez
-- 
-- Create Date: 05/31/2018 10:50:23 PM
-- Design Name: 
-- Module Name: Volume - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Volume is 
PORT (	clk		:   in std_logic;
		wave_in	:   in std_logic_vector(15 downto 0);
		num_waves :   in std_logic_vector(3 downto 0);
        wave_out:	out std_logic_vector(15 downto 0)
		);
end Volume;

ARCHITECTURE behavior of Volume is

-- Signal
signal wave_in_unsigned	: unsigned(15 downto 0) := (others => '0');
signal wave_out_unsigned	: unsigned(27 downto 0) := (others => '0');

type multiplier is array (7 downto 0) of unsigned (11 downto 0);
constant mult_array : multiplier := (to_unsigned(4095, 12),
                                    to_unsigned(2896, 12),
                                    to_unsigned(2365, 12),
                                    to_unsigned(2048, 12),
                                    to_unsigned(1832, 12),
                                    to_unsigned(1672, 12),
                                    to_unsigned(1548, 12),
                                    to_unsigned(1448, 12)
                                    );

BEGIN

volume: process(num_waves, wave_in)
begin
	if num_waves = "0000" then
	   wave_out_unsigned <= (others => '0');
	else
	   wave_out_unsigned <= unsigned(wave_in) * mult_array(to_integer(unsigned(num_waves)-1));
    end if;
end process;

-- Outputs
wave_out <= std_logic_vector(wave_out_unsigned(27 downto 12));

END behavior;
