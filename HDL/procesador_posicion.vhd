library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity procesador_posicion is
port(nRst: in std_logic;
    clk: in std_logic;
    posicion_in: in std_logic_vector(9 downto 0);
    offset_in: in std_logic_vector(9 downto 0);
    fin_medida: in std_logic;
    fin_offset: in std_logic;  
    posicion_procesada_out: buffer std_logic_vector (9 downto 0);
    fin_procesado: buffer std_logic);


end entity;


architecture rtl of procesador_posicion is 

    signal posicion_ajustada_offset: std_logic_vector (9 downto 0);
    signal posicionT0: std_logic_vector (9 downto 0);
    signal posicionT1: std_logic_vector (9 downto 0);
    signal posicionT2: std_logic_vector (9 downto 0);
    signal posicionT3: std_logic_vector (9 downto 0);
    signal posicionT4: std_logic_vector (9 downto 0);
    signal posicionT5: std_logic_vector (9 downto 0);
    signal posicionT6: std_logic_vector (9 downto 0);
    signal posicionT7: std_logic_vector (9 downto 0);
    signal suma_posiciones : std_logic_vector (17 downto 0); --El valor maximo posible es 512 * 256 = 2^17
    signal primera_medida :std_logic;

begin
process (clk, nRst)
begin
    if nRst = '0' then 
        posicionT0<= (others => '0');
        posicionT1<= (others => '0');
        posicionT2<= (others => '0');
        posicionT3<= (others => '0');
        posicionT4<= (others => '0');
        posicionT5<= (others => '0');
        posicionT6<= (others => '0');
        posicionT7<= (others => '0');
		primera_medida <= '1';
		posicion_ajustada_offset <= (others => '0');

    elsif clk'event and clk ='1' then
        if fin_offset = '1' and fin_medida = '1' then

            posicion_ajustada_offset <= posicion_in - offset_in;


            posicionT0 <= posicion_ajustada_offset;
            posicionT1 <= posicionT0;
            posicionT2 <= posicionT1;
            posicionT3 <= posicionT2;
            posicionT4 <= posicionT3;
            posicionT5 <= posicionT4;
            posicionT6 <= posicionT5;
            posicionT7 <= posicionT6;
	


        end if;
    end if;
end process;



suma_posiciones <=( ((posicionT0(9)&(posicionT0 & "0000000")) + posicionT0) + (PosicionT1 & "000000") +(PosicionT2 & "00000")+
(PosicionT3 & "0000") +(PosicionT4 & "000") +(PosicionT5 & "00") + (PosicionT6 & "0") + PosicionT7);

posicion_procesada_out <=  suma_posiciones (17 downto 8); --Dividir entre 256 = Desplazar 8 bits a la derecha

fin_procesado <= fin_medida when fin_offset = '1' else  '0';

end rtl;

