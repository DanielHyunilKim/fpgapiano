----------------------------------------------------------------------------------
-- Company: ENGS 31
-- Engineer: Daniel Kim, Alex Martinez
-- 
-- Create Date: 05/31/2018 10:50:23 PM
-- Design Name: 
-- Module Name: Adder - Behavioral
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

ENTITY Adder is 
PORT (	clk		:   in std_logic;
		waveLC	:   in std_logic_vector(15 downto 0);
		waveD	:   in std_logic_vector(15 downto 0);
		waveE	:   in std_logic_vector(15 downto 0);
		waveF	:   in std_logic_vector(15 downto 0);
        waveG   :   in std_logic_vector(15 downto 0);
        waveA   :   in std_logic_vector(15 downto 0);
        waveB	:   in std_logic_vector(15 downto 0);
        waveHC   :   in std_logic_vector(15 downto 0);
        wave_sum:	out std_logic_vector(15 downto 0)
		);
end Adder;

ARCHITECTURE behavior of Adder is

-- Signal
signal wave_unsignedLC	: unsigned(15 downto 0) := (others => '0');
signal wave_unsignedD	: unsigned(15 downto 0) := (others => '0');
signal wave_unsignedE	: unsigned(15 downto 0) := (others => '0');
signal wave_unsignedF	: unsigned(15 downto 0) := (others => '0');
signal wave_unsignedG	: unsigned(15 downto 0) := (others => '0');
signal wave_unsignedA	: unsigned(15 downto 0) := (others => '0');
signal wave_unsignedB	: unsigned(15 downto 0) := (others => '0');
signal wave_unsignedHC	: unsigned(15 downto 0) := (others => '0');
signal wave_sum_unsigned	: unsigned(15 downto 0) := (others => '0');

BEGIN

add: process(clk)
begin
	if rising_edge(clk) then
        wave_sum_unsigned <= wave_unsignedLC + wave_unsignedD + wave_unsignedE + wave_unsignedF + wave_unsignedG + wave_unsignedA + wave_unsignedB + wave_unsignedHC;    
	end if;
end process;

-- Inputs
wave_unsignedLC <= unsigned(waveLC);
wave_unsignedD <= unsigned(waveD);
wave_unsignedE <= unsigned(waveE);
wave_unsignedF <= unsigned(waveF);
wave_unsignedG <= unsigned(waveG);
wave_unsignedA <= unsigned(waveA);
wave_unsignedB <= unsigned(waveB);
wave_unsignedHC <= unsigned(waveHC);

-- Outputs
wave_sum <= std_logic_vector(wave_sum_unsigned);

END behavior;