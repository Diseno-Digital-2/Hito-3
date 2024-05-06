library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_spi is
    generic(
        fdc_cnt_5ms: natural:= 250000
        );
    port(nRst:     in     std_logic;
         clk:      in     std_logic;                       -- 50 MHz
         -- Ctrl_SPI
         --ini:      in std_logic;          --Inidica al controlador que inicie la operación
         posicion: buffer std_logic_vector(9 downto 0); --Entrega los dos bytes leídos del sensor  
         start:    buffer     std_logic;                       -- Orden de ejecucion (si rdy = 1 ) => rdy  <= 0 hasta fin, cuando rdy <= 1
         nWR_RD:   buffer     std_logic;                       -- Escritura (0) o lectura (1)
         dir_reg:  buffer    std_logic_vector(6 downto 0);     -- direccion de acceso; si bit 7 = '1' (autoincremento) y RD, se considera el valor de long
         dato_wr:  buffer std_logic_vector(7 downto 0);        -- dato a escribir (solo escrituras de 1 bit)
         fin:      buffer std_logic;
         dato_rd:  in std_logic_vector(7 downto 0);    -- valor del byte leido
         ena_rd:   in std_logic;                       -- valida a nivel alto a dato_rd -> Ignorar en operacion de escritura
         rdy:      in std_logic);                       -- unidad preparada para aceptar start
         
end entity;

architecture rtl of controlador_spi is
    --type t_estado is(reset_1ro, reset_2do, reset_3ro, reposo, byte_1ro, escribir, leer_1ro, leer_2do);
    type t_estado is(reset_1ro, reset_2do, reset_3ro, reposo, leer_1ro, leer_2do);
    signal estado: t_estado;
    signal op: std_logic;   --Almacena el tipo de operación durante la transferencia

    --Tic 5 ms
    signal tic_5ms: std_logic;
    signal cnt_5ms: std_logic_vector(17 downto 0);
    signal ena_cnt: std_logic;
    --constant fcd_cnt_5ms: natural:=250000;

    --Bytes leídos del sensor
    signal posicion_L: std_logic_vector(7 downto 0);
    signal posicion_H: std_logic_vector(7 downto 0);    

begin



    process(nRst, clk)
    begin
        if nRst = '0' then
            estado <= reset_1ro;
            dato_wr <= (others => '0');
            nWR_RD <= '0';
            start <= '0';
            posicion_L <= (others => '0');
            posicion_H <= (others => '0');
            ena_cnt <= '0';
            fin <= '0';

        elsif clk'event and clk = '1' then
            case estado is
                when reset_1ro =>
                    if rdy = '1' and start = '0' then
                        nWR_RD <= '0';
                        dir_reg <= "0100001";
                        dato_wr <= x"00";
                        start <= '1';
                        estado <= reset_2do;

                    end if;

                when reset_2do=>
                    start <= '0';
                    if rdy = '1' and rdy'last_value='0' then
                        nWR_RD <= '0';
                        dir_reg <= "0100011";
                        dato_wr <= x"80";
                        start <= '1';
                        estado <= reset_3ro;

                    end if;

                when reset_3ro=>
                    start <= '0';
                if rdy = '1'and rdy'last_value='0' and start = '0' then
                    nWR_RD <= '0';
                    dir_reg <= "0100000";
                    dato_wr <= x"61";
                    start <= '1';
                    estado <= reposo;

                end if;

                when reposo => --Ordena una lectura cada 5 ms 
                    fin <= '0';
                    start <= '0';
                    ena_cnt <= '1';

                    if tic_5ms = '1' and rdy = '1' then
                        nWR_RD <= '1';
                        dir_reg <= "1101000";  --Situa el puntero del sensor en el registro OUT_X_L (0x28) y activa el incremento del puntero
                        start <= '1';
                        estado <= leer_1ro;

                    end if;
                --when byte_1ro =>
                --when escribir =>;
                when leer_1ro=>
                    start <= '0';

                    if ena_rd = '1' then
                        posicion_L <= dato_rd;
                        estado <= leer_2do;

                    end if ;
                when leer_2do=>
                    if ena_rd = '1' then
                        posicion_H <= dato_rd;
                        fin <= '1';
                        estado <= reposo;

                    end if ;
                when others=>
            end case;
        end if;
    end process;

    posicion <= posicion_H(7 downto 0) & posicion_L(7 downto 6);

    --Generador del tic de 5 ms
    process(nRst,clk)
    begin
        if nRst = '0' then
            cnt_5ms <= (0 => '1', others => '0');

        elsif clk'event and clk = '1' then
            if ena_cnt = '0' then
                cnt_5ms <= (0 => '1', others => '0');

            elsif tic_5ms = '1' then
                cnt_5ms <= (0 => '1', others => '0');

            else
                cnt_5ms <= cnt_5ms + 1;

            end if;
        end if;
    end process;

    tic_5ms <= '1' when cnt_5ms(17 downto 0) = fdc_cnt_5ms else
               '0';
end rtl;
