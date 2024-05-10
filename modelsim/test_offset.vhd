library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_offset is
end entity;

architecture test of test_offset is
    signal nRst:     std_logic;
    signal clk:      std_logic;
    signal fin:      std_logic; 
    signal fin_offset:      std_logic;
    signal dato_out:      std_logic_vector(9 downto 0);
    signal dato_in:      std_logic_vector(9 downto 0);
    constant T_clk: time := 20 ns;
begin

    dut: entity work.offset(rtl)
    port map(clk => clk,
            nRst => nRst,
            fin => fin,
            fin_offset => fin_offset,
            dato_in => dato_in,
            dato_out => dato_out

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
    fin <= '0';
    dato_in <= (others => '0');
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait until clk'event and clk = '1';
    for i in 1 to 33 loop
        wait until clk'event and clk = '1';
        dato_in <= dato_in + 1;
        fin <= '1';
        wait until clk'event and clk = '1';
        fin <= '0';
        end loop;

        assert false
        report "Fone"
        severity failure;
  end process;
  
end test;

