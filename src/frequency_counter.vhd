----------------------------------------------------------------------------------
-- Company: ENGS 31
-- Engineer: Daniel Kim, Alex Martinez
-- 
-- Create Date: 05/30/2018 09:03:00 PM
-- Design Name: 
-- Module Name: frequency_counter - Behavioral
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

ENTITY FrequencyCounter is 
PORT (	clk          :   in std_logic;
		key           :   in std_logic_vector(7 downto 0);
		sustain_en    :   in std_logic;
		take_sample   :   in std_logic;
		lut_input     :   out std_logic_vector(15 downto 0));
end FrequencyCounter;

ARCHITECTURE behavior of FrequencyCounter is

--Constants
constant N		:	integer := 4096;	--2^12
constant Fs		:	integer := 44100;	--44.1 kHz

--Signals
signal count		:	unsigned(15 downto 0):= (others => '0');
signal count_int	:	integer := 0;
signal m			:	integer := 0;
signal count_en 	:	std_logic:= '0';
type state_type is (idle, key_pressed);
signal current_state, next_state	: state_type := idle;

BEGIN

-- Multiplexer for button pressed
MUXR: process(clk)
begin
    if rising_edge(clk) then
        case Key is
        --LowC: 262 Hz
        when "00000001" =>
  	     m <= 262 * N / Fs;
        --D: 294 Hz
        when "00000010" =>
  	     m <= 294 * N / Fs;
        --E: 330 Hz
        when "00000100" =>
  	     m <= 330 * N / Fs;
        --F: 350 Hz
        when "00001000" =>
  	     m <= 350 * N / Fs;
        --G: 392 Hz
        when "00010000" =>
  	     m <= 392 * N / Fs;
        --A: 440 Hz
        when "00100000" =>
  	     m <= 440 * N / Fs;
        --B: 494 Hz
        when "01000000" =>
  	     m <= 494 * N / Fs;
        --HighC: 523 Hz
        when "10000000" =>
  	     m <= 523 * N / Fs;
        when others =>
            if sustain_en = '1' then
                m <= m;
            else m <= 0;
            end if;
        end case;
    end if;
end process;

-- State update
current_to_next: process(clk)
begin
	if rising_edge(clk) then
    	current_state <= next_state;
    end if;
end process;

-- FSM Controller
state_controller: process(current_state, key, sustain_en)
begin
	count_en <= '0';
	next_state <= current_state;
	case current_state is
    when idle =>
        if (key /= "00000000") then
            next_state <= key_pressed;
        end if;
    when key_pressed =>
    	count_en <= '1';
    	if sustain_en = '1' then
    	   next_state <= key_pressed;
    	elsif (key = "00000000") then
	    	next_state <= idle;
        end if;
    end case;
end process;

-- Counter that generates address values
counter: process(clk)
begin
	if rising_edge(clk) then
	   if take_sample = '1' then
	       if count_en = '1' then
    	       count_int <= count_int + m;
    	       if (count_int >= N) then
    	           count_int <= 0;
    	       end if;
    	    else 
        	   count_int <= 0;
       	    end if;
       	end if;
    end if;
end process;

count <= to_unsigned(count_int, 16);
LUT_Input <= std_logic_vector(count);

end behavior;