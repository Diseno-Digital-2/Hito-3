library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_master is
end entity;

architecture test of test_master is
    signal nRst:     std_logic;
    signal clk:      std_logic;                                                         
    signal nCS:      std_logic;                      
    signal SPC:      std_logic;                      
    signal SDI_msr:  std_logic;                     -- SDI master                      
    signal SDO_msr:  std_logic;                     -- SDO master
    signal start:    std_logic;
    signal nWR_RD:    std_logic;
    signal dir_reg:    std_logic_vector(6 downto 0);
    signal dato_wr:    std_logic_vector(7 downto 0);
    signal dato_rd:    std_logic_vector(7 downto 0);
    signal ena_rd:    std_logic;
    signal rdy:    std_logic;

    constant T_clk: time := 20 ns;
  
    signal pos_X: std_logic_vector(1 downto 0);
  
  begin
  
  process
  begin
    clk <= '0';
    wait for T_clk/2;
  
    clk <= '1';
    wait for T_clk/2;
  
  end process;
  
  dut: entity work.master_spi_4_hilos(rtl)
       port map(nRst     => nRst,
                clk      => clk,
                nCS      => nCS,
                SPC      => SPC,
                SDI      => SDI_msr,
                SDO      => SDO_msr,
                start     => start,
                nWR_RD => nWR_RD,
                dir_reg => dir_reg,
                dato_wr => dato_wr,
                dato_rd => dato_rd,
                ena_rd => ena_rd,
                rdy => rdy);
  
  slave: entity work.agente_spi(sim)
         port map(pos_X => pos_X,
                  nCS => nCS,
                  SPC => SPC,
                  SDI => SDO_msr,
                  SDO => SDI_msr);
  
  process
  begin
    nRst <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    --**ESCRITURA DE UN REGISTRO
      nRst <= '1';
      pos_X <= "00";
      nWR_RD <= '0';
      dir_reg <= "0100000";
      dato_wr <= "00000001";
      start <= '1';
      
      for i in 1 to 20 loop
        wait until SPC'event and SPC = '1';
        --start <= '0';
      end loop;
    start <= '0';
    for i in 1 to 5 loop
        wait until SPC'event and SPC = '1';
    
      end loop;
  
    --**LECTURA DE UN REGISTRO
    pos_X <="00";
    nWR_RD <= '1';
    dir_reg <= "1100000";
    start <= '1';
    for i in 1 to 40 loop
      wait until SPC'event and SPC = '1';
  
    end loop;
    start <= '0';
    for i in 1 to 10 loop
        wait until SPC'event and SPC = '1';
    
      end loop;
    assert false
    report "Fone"
    severity failure;
  
  end process;

    -- Reloj (100 MHz)
    clock: process
    begin
      clk <= '0';
      wait for T_clk/2;
      clk <= '1';
      wait for T_clk/2;
    end process;

  end test;
