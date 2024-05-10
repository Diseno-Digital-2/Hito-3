LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY offset IS
    PORT (
        nRst : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        dato_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dato_out : BUFFER STD_LOGIC_VECTOR(9 DOWNTO 0);
        fin : IN STD_LOGIC;
        fin_offset : BUFFER STD_LOGIC);
END ENTITY;

ARCHITECTURE rtl OF offset IS
    SIGNAL almacen : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL contador : STD_LOGIC_VECTOR(5 DOWNTO 0);
BEGIN
    PROCESS (clk, nRst)
    BEGIN
        IF nRst = '0' THEN
            almacen <= (OTHERS => '0');
            contador <= "100000";

        ELSIF clk'event AND clk = '1' THEN
            IF fin = '1' AND contador /= 0 THEN
                contador <= contador + 1;
                almacen <= almacen + dato_in;
            END IF;
        END IF;
    END PROCESS;

    fin_offset <= '1' WHEN contador =0 ELSE --El número x"20" es -32 en decimal con signo
        '0';

    dato_out <= almacen(14 DOWNTO 5) WHEN contador = 0 ELSE
        (OTHERS => '0');
	
END ARCHITECTURE;