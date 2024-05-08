library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_hito3_completo is
end entity;

architecture test of test_hito3_completo is

    signal nRst:         std_logic;
    signal clk:         std_logic;                       -- 50 MHz
    signal LEDs:  std_logic_vector(7 downto 0);

    signal fin: std_logic;
    signal fin_offset: std_logic;
    signal fin_procesado: std_logic;

    signal posicion: std_logic_vector(9 downto 0);
    signal posicion_procesada: std_logic_vector(9 downto 0);
    signal offset: std_logic_vector(9 downto 0);
    constant T_clk: time := 20 ns;

begin

    U2: entity work.offset(rtl)
    port map (  nRst=> nRst,
                clk => clk,
                dato_in => posicion,
                dato_out => offset,
                fin =>fin,
                fin_offset => fin_offset); 


    
    U3: entity work.procesador_posicion(rtl)
    port map(nRst => nRst,
            clk => clk,
            posicion_in => posicion,
            offset_in => offset,
            fin_medida => fin,
            fin_offset => fin_offset, 
            posicion_procesada_out => posicion_procesada,
            fin_procesado => fin_procesado);
        
        


    U4: entity work.leds(rtl)
    port map(nRst => nRst,
            posicion => posicion_procesada,
            clk => clk,
            fin => fin_procesado,
            LEDs => LEDs);


process
  begin
    clk <= '0';
    wait for T_clk/2;
  
    clk <= '1';
    wait for T_clk/2;
  
  end process;

process
    variable posicion_offset: std_logic_vector (9 downto 0) := "1100000000"; --256

  begin
    nRst <= '0';
    posicion <= (others => '0');
    fin <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait until clk'event and clk = '1';

    for j in 1 to 33 loop

        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';
        nRst<= '0';
        posicion <= (others =>'0');
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        nRst<= '1';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        for a in 1 to 32 loop
            posicion <= posicion_offset;
            fin <= '1';
            wait until clk'event and clk = '1';
            fin <= '0';

        end loop;

            posicion_offset := posicion_offset + 15;
            posicion<= "1100000000"; -- -256
        for i in 1 to 33 loop

          wait until clk'event and clk = '1';
          
          posicion<= posicion + 16;
	      fin <= '1';
	      wait until clk'event and clk = '1';
	      fin <= '0';
	   

        end loop;
            
    end loop;

end process;
end test;