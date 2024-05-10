LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY leds IS
    PORT (
        nRst : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        posicion : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        fin : IN STD_LOGIC;
        LEDs : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0));
END ENTITY;

ARCHITECTURE rtl OF leds IS
    CONSTANT escalon : NATURAL := 34;

BEGIN

    LEDs <= NOT(x"01") WHEN posicion <= - 238 ELSE
        NOT(x"03") WHEN posicion <= - 204 ELSE
        NOT(x"07") WHEN posicion <= - 170 ELSE
        NOT(x"0F") WHEN posicion <= - 136 ELSE
        NOT(x"1F") WHEN posicion <= - 102 ELSE
        NOT(x"3F") WHEN posicion <= - 68 ELSE
        NOT(x"7F") WHEN posicion <= - 34 ELSE
        NOT(x"FF") WHEN posicion <= 34 ELSE
        NOT(x"FC") WHEN posicion <= 68 ELSE
        NOT(x"F8") WHEN posicion <= 102 ELSE
        NOT(x"F0") WHEN posicion <= 136 ELSE
        NOT(x"E0") WHEN posicion <= 170 ELSE
        NOT(x"C0") WHEN posicion <= 204 ELSE
        NOT(x"80") WHEN posicion <= 272 ELSE
        NOT(x"FF");
END rtl;