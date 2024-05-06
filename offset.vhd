library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity offset is
port(nRst: in std_logic;
    clk: in std_logic;
    dato_in: in std_logic_vector(9 downto 0);
    dato_out: buffer std_logic_vector(9 downto 0);
    fin: in std_logic;
    fin_offset: buffer std_logic);                 
end entity;

architecture rtl of offset is
    signal almacen: std_logic_vector(13 downto 0);
    signal contador: std_logic_vector(5 downto 0);
begin
    process(clk, nRst)
    begin
        if nRst = '0' then
            almacen <= (others => '0');
            contador <= (others => '0');

        elsif clk'event and clk = '1' then
            if fin = '1' and contador < x"20" then
                contador <= contador + 1;
                almacen <= almacen + dato_in; 

            end if;
        end if;
    end process;
    
    fin_offset <= '1' when contador = -32 else  --El número x"20" es -32 en decimal con signo
                  '0';

    dato_out <= almacen(13)&almacen(13 downto 5) when contador = -32 else  
            (others => '0');

end architecture;
