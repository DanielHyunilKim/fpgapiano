----------------------------------------------------------------------------------
-- Company: ENGS 31
-- Engineer: Daniel Kim, Alex Martinez
-- 
-- Create Date: 05/30/2018 09:10:47 PM
-- Design Name: 
-- Module Name: piano_shell - Behavioral
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
use IEEE.numeric_std.ALL;			-- needed for arithmetic

library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity Piano is
port (	mclk	:	in std_logic;	    -- FPGA board master clock (100 MHz)
		key		:	in std_logic_vector(7 downto 0);
		sustain_en    :   in std_logic;
        sound	:	out std_logic;
        spi_sclk    :   out std_logic;
        spi_sync    :   out std_logic);
end Piano; 

ARCHITECTURE behavior of Piano is

-- Constants and Signals
-- Wires
signal wire_to_freqLC    :   std_logic_vector(7 downto 0);
signal wire_to_freqD    :   std_logic_vector(7 downto 0);
signal wire_to_freqE    :   std_logic_vector(7 downto 0);
signal wire_to_freqF    :   std_logic_vector(7 downto 0);
signal wire_to_freqG    :   std_logic_vector(7 downto 0);
signal wire_to_freqA    :   std_logic_vector(7 downto 0);
signal wire_to_freqB    :   std_logic_vector(7 downto 0);
signal wire_to_freqHC    :   std_logic_vector(7 downto 0);

signal wire_to_lookupLC   :   std_logic_vector(15 downto 0);
signal wire_to_lookupD   :   std_logic_vector(15 downto 0);
signal wire_to_lookupE   :   std_logic_vector(15 downto 0);
signal wire_to_lookupF   :   std_logic_vector(15 downto 0);
signal wire_to_lookupG   :   std_logic_vector(15 downto 0);
signal wire_to_lookupA   :   std_logic_vector(15 downto 0);
signal wire_to_lookupB   :   std_logic_vector(15 downto 0);
signal wire_to_lookupHC   :   std_logic_vector(15 downto 0);

signal wire_to_adderLC   :   std_logic_vector(15 downto 0);
signal wire_to_adderD   :   std_logic_vector(15 downto 0);
signal wire_to_adderE   :   std_logic_vector(15 downto 0);
signal wire_to_adderF   :   std_logic_vector(15 downto 0);
signal wire_to_adderG   :   std_logic_vector(15 downto 0);
signal wire_to_adderA   :   std_logic_vector(15 downto 0);
signal wire_to_adderB   :   std_logic_vector(15 downto 0);
signal wire_to_adderHC   :   std_logic_vector(15 downto 0);

signal wire_to_volume   :   std_logic_vector(15 downto 0);
signal wire_to_pmod     :   std_logic_vector(15 downto 0);
signal num_waves   :   unsigned(3 downto 0) := (others => '0');

signal s_axis_phase_tvalid1  :   std_logic := '1';
signal m_axis_data_tvalid1   : std_logic := '1';
signal s_axis_phase_tvalid2  :   std_logic := '1';
signal m_axis_data_tvalid2   : std_logic := '1';
signal s_axis_phase_tvalid3  :   std_logic := '1';
signal m_axis_data_tvalid3   : std_logic := '1';
signal s_axis_phase_tvalid4  :   std_logic := '1';
signal m_axis_data_tvalid4   : std_logic := '1';
signal s_axis_phase_tvalid5  :   std_logic := '1';
signal m_axis_data_tvalid5   : std_logic := '1';
signal s_axis_phase_tvalid6  :   std_logic := '1';
signal m_axis_data_tvalid6   : std_logic := '1';
signal s_axis_phase_tvalid7  :   std_logic := '1';
signal m_axis_data_tvalid7   : std_logic := '1';
signal s_axis_phase_tvalid8  :   std_logic := '1';
signal m_axis_data_tvalid8   : std_logic := '1';

-- Signals for serial clock divider (100 MHz --> 10 MHz)
constant SCLK_DIVIDER_VALUE : integer := 5;
constant COUNT_LEN : integer := 50;
signal sclkdiv: unsigned(count_LEN-1 downto 0) := (others => '0'); -- clock divider counter
signal sclk_unbuf: std_logic := '0';    --unbuffered serial clock
signal sclk: std_logic := '0';          --internal serial clock

-- Signals for sampling clock
signal take_sample  : std_logic := '0';
signal count    : unsigned(16 downto 0) := (others => '0');

-- Component Declarations
COMPONENT FrequencyCounter
PORT(	clk			:	in std_logic;
		key			:	in	std_logic_vector(7 downto 0);
		sustain_en    :   in std_logic;
		take_sample   :   in std_logic;
		lut_input	   : 	out	std_logic_vector(15 downto 0));
END COMPONENT;

COMPONENT dds_compiler_0
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

COMPONENT Adder
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
END COMPONENT;

COMPONENT Volume
  PORT (
    clk		:   in std_logic;
    wave_in    :   in std_logic_vector(15 downto 0);
    num_waves   :  in std_logic_vector(3 downto 0);
    wave_out    :    out std_logic_vector(15 downto 0)
  );
END COMPONENT;

COMPONENT DtoA 
PORT ( 	sclk		:	in 	std_logic;
		take_sample	:	in	std_logic;
        data_in		:	in	std_logic_vector(15 downto 0);
        spi_sclk	:	out std_logic;
        spi_sync	:	out	std_logic;
        spi_DinA	:	out	std_logic);
END COMPONENT;

begin

-- Processes
-- Clock buffer for sclk
Slow_clock_buffer: BUFG
    port map ( I => sclk_unbuf,
                O => sclk);

-- Divide the 100 MHz clock down to 20 Mhz, then toggling flip flop gives final 10 MHz system clock
Serial_clock_divider: process(mclk)
begin
    if rising_edge(mclk) then
        if sclkdiv = SCLK_DIVIDER_VALUE-1 then
            sclkdiv <= (others => '0');
            sclk_unbuf <= NOT(sclk_unbuf);
        else
            sclkdiv <= sclkdiv + 1;
        end if;
    end if;
end process Serial_clock_divider;

-- Further divide clock down to 44.1 kHz take_sample ticks
Sampling_counter: process(sclk)
begin
    if rising_edge(sclk) then
        take_sample <= '0';
        count <= count + 1;
        if (count = 227) then
            count <= (others => '0');
            take_sample <= '1';
        end if;
    end if;
end process;

key_select: process(key)
begin
    if key(0) = '1' then
        wire_to_freqLC <= "00000001";
    else wire_to_freqLC <= "00000000";
    end if;
    if key(1) = '1' then
        wire_to_freqD <= "00000010";
    else wire_to_freqD <= "00000000";
    end if;
    if key(2) = '1' then
        wire_to_freqE <= "00000100";
    else wire_to_freqE <= "00000000";
    end if;
    if key(3) = '1' then
        wire_to_freqF <= "00001000";
    else wire_to_freqF <= "00000000";
    end if;
    if key(4) = '1' then
        wire_to_freqG <= "00010000";
    else wire_to_freqG <= "00000000";
    end if;
    if key(5) = '1' then
        wire_to_freqA <= "00100000";
    else wire_to_freqA <= "00000000";
    end if;
    if key(6) = '1' then
        wire_to_freqB <= "01000000";
    else wire_to_freqB <= "00000000";
    end if;
    if key(7) = '1' then
        wire_to_freqHC <= "10000000";
    else wire_to_freqHC <= "00000000";
    end if;
end process;

num_keys: process(sclk)
begin
    if rising_edge(sclk) then
        num_waves <= (others => '0');
        for i in 0 to 7 loop
            if key(i) = '1' then
                num_waves <= num_waves + 1;
            end if;
        end loop;
    end if;
end process;
    
-- Instantiate Components
freq_counterLC: FrequencyCounter port map(
    clk => sclk,
    key => wire_to_freqLC,
    sustain_en => sustain_en,
    take_sample => take_sample,
    lut_input => wire_to_lookupLC
    );

freq_counterD: FrequencyCounter port map(
    clk => sclk,
    key => wire_to_freqD,
    sustain_en => sustain_en,
    take_sample => take_sample,
    lut_input => wire_to_lookupD
    );

freq_counterE: FrequencyCounter port map(
    clk => sclk,
    key => wire_to_freqE,
    sustain_en => sustain_en,
    take_sample => take_sample,
    lut_input => wire_to_lookupE
    );
    
freq_counterF: FrequencyCounter port map(
        clk => sclk,
        key => wire_to_freqF,
        sustain_en => sustain_en,
        take_sample => take_sample,
        lut_input => wire_to_lookupF
        );
        
freq_counterG: FrequencyCounter port map(
            clk => sclk,
            key => wire_to_freqG,
            sustain_en => sustain_en,
            take_sample => take_sample,
            lut_input => wire_to_lookupG
            );

freq_counterA: FrequencyCounter port map(
    clk => sclk,
    key => wire_to_freqA,
    sustain_en => sustain_en,
    take_sample => take_sample,
    lut_input => wire_to_lookupA
    );

freq_counterB: FrequencyCounter port map(
    clk => sclk,
    key => wire_to_freqB,
    sustain_en => sustain_en,
    take_sample => take_sample,
    lut_input => wire_to_lookupB
    );
    
freq_counterHC: FrequencyCounter port map(
        clk => sclk,
        key => wire_to_freqHC,
        sustain_en => sustain_en,
        take_sample => take_sample,
        lut_input => wire_to_lookupHC
        );
    
lookup_tableLC: dds_compiler_0 port map(
    aclk => sclk,
    s_axis_phase_tvalid => s_axis_phase_tvalid1,
    s_axis_phase_tdata => wire_to_lookupLC,
    m_axis_data_tvalid => m_axis_data_tvalid1,
    m_axis_data_tdata => wire_to_adderLC);
    
lookup_tableD: dds_compiler_0 port map(
        aclk => sclk,
        s_axis_phase_tvalid => s_axis_phase_tvalid2,
        s_axis_phase_tdata => wire_to_lookupD,
        m_axis_data_tvalid => m_axis_data_tvalid2,
        m_axis_data_tdata => wire_to_adderD);

lookup_tableE: dds_compiler_0 port map(
    aclk => sclk,
    s_axis_phase_tvalid => s_axis_phase_tvalid3,
    s_axis_phase_tdata => wire_to_lookupE,
    m_axis_data_tvalid => m_axis_data_tvalid3,
    m_axis_data_tdata => wire_to_adderE);
    
lookup_tableF: dds_compiler_0 port map(
        aclk => sclk,
        s_axis_phase_tvalid => s_axis_phase_tvalid4,
        s_axis_phase_tdata => wire_to_lookupF,
        m_axis_data_tvalid => m_axis_data_tvalid4,
        m_axis_data_tdata => wire_to_adderF);

lookup_tableG: dds_compiler_0 port map(
    aclk => sclk,
    s_axis_phase_tvalid => s_axis_phase_tvalid5,
    s_axis_phase_tdata => wire_to_lookupG,
    m_axis_data_tvalid => m_axis_data_tvalid5,
    m_axis_data_tdata => wire_to_adderG);

lookup_tableA: dds_compiler_0 port map(
    aclk => sclk,
    s_axis_phase_tvalid => s_axis_phase_tvalid6,
    s_axis_phase_tdata => wire_to_lookupA,
    m_axis_data_tvalid => m_axis_data_tvalid6,
    m_axis_data_tdata => wire_to_adderA);

lookup_tableB: dds_compiler_0 port map(
    aclk => sclk,
    s_axis_phase_tvalid => s_axis_phase_tvalid7,
    s_axis_phase_tdata => wire_to_lookupB,
    m_axis_data_tvalid => m_axis_data_tvalid7,
    m_axis_data_tdata => wire_to_adderB);

lookup_tableHC: dds_compiler_0 port map(
    aclk => sclk,
    s_axis_phase_tvalid => s_axis_phase_tvalid8,
    s_axis_phase_tdata => wire_to_lookupHC,
    m_axis_data_tvalid => m_axis_data_tvalid8,
    m_axis_data_tdata => wire_to_adderHC);
      
add: Adder port map(
    clk => sclk,
    waveLC => wire_to_adderLC,
    waveD => wire_to_adderD,
    waveE => wire_to_adderE,
    waveF => wire_to_adderF,
    waveG => wire_to_adderG,
    waveA => wire_to_adderA,
    waveB => wire_to_adderB,
    waveHC => wire_to_adderHC,
    wave_sum => wire_to_volume);

vol: Volume port map(
    clk => sclk,
    num_waves => "0011",
    wave_in => wire_to_volume,
    wave_out => wire_to_pmod);

digital_to_analog: DtoA port map(
    sclk => sclk,
    take_sample => take_sample,
    data_in => wire_to_pmod,
    spi_sclk => spi_sclk,
    spi_sync => spi_sync,
    spi_DinA => sound);

end behavior;    