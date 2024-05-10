library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
    generic(fdc_cnt_5ms : natural := 250000);
port(nRst:     in     std_logic;
    clk:      in     std_logic;                       -- 50 MHz
    LEDs: buffer std_logic_vector(7 downto 0);
    -- bus SPI
    nCS:      buffer std_logic;                      -- chip select
    SPC:      buffer std_logic;                      -- clock SPI
    SDI:      in     std_logic;                      -- Master Data input (connected to slave SDO)
    SDO:      buffer std_logic);      
     
end entity;

architecture estructural of top is
    signal start: std_logic;
    signal nWR_RD: std_logic;
    signal dir_reg: std_logic_vector(6 downto 0);
    signal dato_wr: std_logic_vector(7 downto 0);
    signal dato_rd: std_logic_vector(7 downto 0);
    signal ena_rd: std_logic;
    signal rdy: std_logic;
    signal fin: std_logic;
    signal fin_offset: std_logic;
    signal fin_procesado: std_logic;

    signal posicion: std_logic_vector(9 downto 0);
    signal posicion_procesada: std_logic_vector(9 downto 0);
    signal offset: std_logic_vector(9 downto 0);
    --constant fcd_cnt_5ms: natural:=250000;

begin

    U0: entity work.master_spi_4_hilos(rtl)
    port map(nRst => nRst,
            clk => clk,
            start => start,
            nWR_RD => nWR_RD,
            dir_reg => dir_reg,
            dato_wr => dato_wr,
            dato_rd => dato_rd,
            ena_rd => ena_rd,
            rdy => rdy,
            nCS => nCS,
            SPC => SPC,
            SDI => SDI,
            SDO => SDO);


    U1: entity work.controlador_spi(rtl)
    generic map(fdc_cnt_5ms => fdc_cnt_5ms)
    port map(nRst => nRst,
            clk => clk,
            start => start,
            nWR_RD => nWR_RD,
            dir_reg => dir_reg,
            dato_wr => dato_wr,
            dato_rd => dato_rd,
            ena_rd => ena_rd,
            rdy => rdy,
            fin => fin,
            posicion => posicion);


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


end estructural;
