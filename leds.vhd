library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity leds is
port(nRst: in std_logic;
    clk: in std_logic;
    posicion:   in std_logic_vector(9 downto 0);
    fin: in std_logic;
    LEDs: buffer std_logic_vector(7 downto 0));                 
end entity;

architecture rtl of leds is
    constant escalon: natural:= 34;
    signal posicion_reg: std_logic_vector(9 downto 0);

begin

    process(nRst, clk)
    begin
        if nRst = '0' then
            posicion_reg <= (others=>'0');

        elsif clk'event and clk = '1' then
            if fin = '1' then
                posicion_reg <= posicion;

            end if;

        end if;
    end process;
   



    LEDs <=  not(x"80") when posicion_reg <= -238 else
             not(x"C0") when posicion_reg <= -204 else
             not(x"E0") when posicion_reg <= -170 else
             not(x"F0") when posicion_reg <= -136 else
             not(x"F8") when posicion_reg <= -102 else
             not(x"FC") when posicion_reg <= -68 else
             not(x"FE") when posicion_reg <= -34 else
             not(x"FF") when posicion_reg <  0 else
	     not(x"FF") when posicion_reg < 34 else
	     not(x"01") when posicion_reg >= 238 else
             not(x"03") when posicion_reg >= 204 else
             not(x"07") when posicion_reg >= 170 else
             not(x"0F") when posicion_reg >= 136 else
             not( x"1F") when posicion_reg >= 102 else
             not(x"3F") when posicion_reg >= 68 else
             not(x"7F") when posicion_reg >= 34 else   
             not(x"00") when nRst = '0' else
             not(x"00");
end rtl;

