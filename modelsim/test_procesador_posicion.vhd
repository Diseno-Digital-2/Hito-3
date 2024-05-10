library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_procesador_posicion is
end entity;

architecture test of test_procesador_posicion is

    signal nRst: std_logic;
    signal clk: std_logic;
    signal posicion_in: std_logic_vector(9 downto 0);
    signal offset_in: std_logic_vector(9 downto 0);
    signal fin_medida: std_logic;
    signal fin_offset: std_logic;  
    signal posicion_procesada_out: std_logic_vector (9 downto 0);
    signal fin_procesado: std_logic;

    constant T_clk: time := 20 ns;
begin

    dut: entity work.procesador_posicion(rtl)
    port map(clk => clk,
            nRst => nRst,
            posicion_in => posicion_in,
            offset_in => offset_in,
            fin_medida => fin_medida,
            fin_offset => fin_offset,
            posicion_procesada_out => posicion_procesada_out,
            fin_procesado => fin_procesado

    );

process
  begin
    clk <= '0';
    wait for T_clk/2;
  
    clk <= '1';
    wait for T_clk/2;
  
  end process;

process
  begin
    nRst <= '0';
    posicion_in <= (others => '0');
    offset_in <= (others => '0');
    fin_medida <= '0';
    fin_offset <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait until clk'event and clk = '1';

    fin_medida <= '1';
    fin_offset <= '1';

    wait until clk'event and clk = '1';

    fin_medida <= '0';

     
    wait until clk'event and clk = '1';

    posicion_in <= "1100000000"; -- -256
    offset_in <= "1100000000"; -- -256
    fin_medida <= '1';


    wait until clk'event and clk = '1';

    fin_medida <= '0';

    wait until clk'event and clk = '1';

    for j in 1 to 33 loop

        

        for i in 1 to 33 loop

          wait until clk'event and clk = '1';
          
          posicion_in <= posicion_in + 16;
	  fin_medida <= '1';
	  wait until clk'event and clk = '1';
	  fin_medida <= '0';
	   

        end loop;

	offset_in <= offset_in + 16; 


        posicion_in <= "1011110000"; -- -272
        wait until clk'event and clk = '1';
            
    end loop;

end process;
end test;