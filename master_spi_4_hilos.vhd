library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity master_spi_4_hilos is
port(nRst:     in     std_logic;
     clk:      in     std_logic;                       -- 50 MHz
     -- Ctrl_SPI
     start:    in     std_logic;                       -- Orden de ejecucion (si rdy = 1 ) => rdy  <= 0 hasta fin, cuando rdy <= 1
     nWR_RD:   in     std_logic;                       -- Escritura (0) o lectura (1)
     dir_reg:  in     std_logic_vector(6 downto 0);    -- direccion de acceso; si bit 7 = '1' (autoincremento) y RD, se considera el valor de long
     dato_wr:  in     std_logic_vector(7 downto 0);    -- dato a escribir (solo escrituras de 1 bit)
     dato_rd:  buffer std_logic_vector(7 downto 0);    -- valor del byte leido
     ena_rd:   buffer std_logic;                       -- valida a nivel alto a dato_rd -> Ignorar en operacion de escritura
     rdy:      buffer std_logic;                       -- unidad preparada para aceptar start
     -- bus SPI
     nCS:      buffer std_logic;                      -- chip select
     SPC:      buffer std_logic;                      -- clock SPI
     SDI:      in     std_logic;                      -- Master Data input (connected to slave SDO)
     SDO:      buffer std_logic);                     -- Master Data Output (connected to slave SDI)
     
end entity;

architecture rtl of master_spi_4_hilos is
 --Reloj del bus
 signal cnt_SPC:     std_logic_vector(2 downto 0);
 signal fdc_cnt_SPC: std_logic;
 signal SPC_posedge: std_logic;
 signal SPC_negedge: std_logic;

 constant SPC_LH: natural := 5; 
 
 -- Contador de bits y bytes transmitidos
 signal cnt_bits_SPC: std_logic_vector(5 downto 0);

 -- Sincro SDI y Registro de transmision y recepcion
 signal SDI_meta, SDI_syn: std_logic;
 signal reg_SPI: std_logic_vector(16 downto 0);

 -- Para el control
 signal no_bytes: std_logic_vector(2 downto 0);
 signal fin: std_logic;

begin
  -- Generacion de nCS:
  process(nRst, clk)
  begin
    if nRst = '0' then
      nCS <= '1';

    elsif clk'event and clk = '1' then
      if start = '1' and nCS = '1' then  --Si nCs ya está a nivel bajo significa que hay una transferencia en marcha
        nCS <= '0';

      elsif fin = '1' then
        nCS <= '1';

      end if;
    end if;
  end process;
  
  rdy <= nCS;

  -- Generacion de SPC:
  process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_SPC <= (1 => '1', others => '0');
      SPC <= '1';

    elsif clk'event and clk = '1' then
      if nCS = '1' then 
        cnt_SPC <= (1 => '1', others => '0');
        SPC <= '1';

      elsif fdc_cnt_SPC = '1' then                --No se tiene en cuenta el CS setup time ya que el periodo del reloj es mucho mayor
        SPC <= not SPC;                           --y por lo tanto cuando nCs se pone a nivel bajo SPC está medio periodo en nivel alto
        cnt_SPC <= (0 => '1', others => '0');

      else
        cnt_SPC <= cnt_SPC + 1;

      end if;
    end if;
  end process;

  fdc_cnt_SPC <= '1' when cnt_SPC = SPC_LH else
                 '0';

  SPC_posedge <= SPC when cnt_SPC = 1 else
                 '0'; 

  SPC_negedge <= not SPC when cnt_SPC = 1 else
                 '0'; 

  -- Cuenta bits y bytes (empieza a contar los bits desde el momento en el que se activa nCS):
  process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_bits_SPC <= (others => '0');
      
    elsif clk'event and clk = '1' then  
      if SPC_posedge = '1' then            --Cuenta el número de bits intercambiado en la trasnferencia en los niveles altos de SPC
        cnt_bits_SPC <= cnt_bits_SPC + 1;

      elsif nCS = '1' then
        cnt_bits_SPC <= (others => '0');

      end if;
    end if;
  end process;

  -- Registro
  process(nRst, clk)
  begin
    if nRst = '0' then
      reg_SPI <= (others => '0');
      SDI_syn <= '0';
      SDI_meta <= '0';

    elsif clk'event and clk = '1' then  
      SDI_meta <= SDI;
      SDI_syn <= SDI_meta;
      
      if start = '1' and nCS = '1' then
        reg_SPI <= '0'& nWR_RD & dir_reg & dato_wr;    --Escribe la dirección del registro donde se desea escribir y el byte a escribir
 
      elsif SPC_negedge = '1' then                     --En los niveles bajos de SPC desplaza el registro un bit a la izquierda
        reg_SPI(16 downto 1) <= reg_SPI(15 downto 0);

      elsif SPC_posedge = '1' then                     --En lso niveles altos de SPC lee el siguiente bit de la linea SDI
        reg_SPI(0) <= SDI_syn;

      end if;
    end if;
  end process;

  ena_rd <= (not nCS and fin) when cnt_bits_SPC(5 downto 3) =  3                               else  --COMPLETAR **Cuando acaba la transferencia del último byte de lectura se activa la lectura
            SPC_negedge       when cnt_bits_SPC(5 downto 3) > 1 and cnt_bits_SPC(2 downto 0) = "000" else  --COMPLETAR **Cuando se lee el segundo byte se activa la lectura
            '0';

  dato_rd <= reg_SPI(7 downto 0);

  SDO <= reg_SPI(16);

  -- Control heuristico
  process(nRst, clk)
  begin
    if nRst = '0' then
      no_bytes <= (others => '0');

    elsif clk'event and clk = '1' then  
      if start = '1' and nCS = '1' then
        if nWR_RD = '0' then
          no_bytes <= "010";                 --COMPLETAR  **En las escrituras se escribe un primer byte con la dirección + MS + RW 
                                         --           **El segundo byte es la información que se escribe en la dirección ya indicada
        else
          no_bytes <= "011";                 --COMPLETAR  **En las lecturas se escribe un primer byte con la dirección + MS + RW 
                                         --           **Los siguientes dos bytes los lee del sensor
        end if;
      end if;
    end if;
  end process;

  fin <= '1' when cnt_bits_SPC(5 downto 3) = no_bytes  else  --COMPLETAR  **Divide entre 8 el número de bits contados para obtener el número de bytes contados
         '0';
 
end rtl;
