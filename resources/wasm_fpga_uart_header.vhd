


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package WasmFpgaUartWshBn_Package is


-- type decalarations ---------------------------------                    

    type WasmFpgaUart_arr_of_std_logic_vector_2_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_3_t is                                        
      array (natural range <>) of std_logic_vector(1 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_4_t is                                        
      array (natural range <>) of std_logic_vector(3 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_5_t is                                        
      array (natural range <>) of std_logic_vector(4 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_6_t is                                        
      array (natural range <>) of std_logic_vector(5 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_7_t is                                        
      array (natural range <>) of std_logic_vector(6 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_8_t is                                        
      array (natural range <>) of std_logic_vector(7 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_9_t is                                        
      array (natural range <>) of std_logic_vector(8 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_10_t is                                    
      array (natural range <>) of std_logic_vector(9 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_11_t is                                    
      array (natural range <>) of std_logic_vector(10 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_12_t is                                    
      array (natural range <>) of std_logic_vector(11 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_13_t is                                    
      array (natural range <>) of std_logic_vector(12 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_14_t is                                    
      array (natural range <>) of std_logic_vector(13 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_15_t is                                    
      array (natural range <>) of std_logic_vector(14 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_16_t is                                    
      array (natural range <>) of std_logic_vector(15 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_24_t is                                    
      array (natural range <>) of std_logic_vector(23 downto 0);     

    type WasmFpgaUart_arr_of_std_logic_vector_32_t is                                    
      array (natural range <>) of std_logic_vector(31 downto 0);    


    type T_WasmFpgaUartWshBnDn is
    record
        Adr :   std_logic_vector(23 downto 0);
        Sel :   std_logic_vector(3 downto 0);
        DatIn :   std_logic_vector(31 downto 0);
        We :   std_logic;
        Stb :   std_logic;
        Cyc :   std_logic_vector(0 downto 0);
    end record;

    type array_of_T_WasmFpgaUartWshBnDn is
      array (natural range <>) of T_WasmFpgaUartWshBnDn;


    type T_WasmFpgaUartWshBnUp is
    record
        DatOut :   std_logic_vector(31 downto 0);
        Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaUartWshBnUp is
      array (natural range <>) of T_WasmFpgaUartWshBnUp;

    type T_WasmFpgaUartWshBn_UnOccpdRcrd is
    record
        forRecord_Adr :   std_logic_vector(23 downto 0);
        forRecord_Sel :   std_logic_vector(3 downto 0);
        forRecord_We :   std_logic;
        forRecord_Cyc :   std_logic_vector(0 downto 0);
        Unoccupied_Ack :   std_logic;
    end record;

    type array_of_T_WasmFpgaUartWshBn_UnOccpdRcrd is
      array (natural range <>) of T_WasmFpgaUartWshBn_UnOccpdRcrd;

    type T_WasmFpgaUartWshBn_UartBlk is
    record
        UartRxRun :   std_logic;
        UartTxRun :   std_logic;
        WRegPulse_ControlReg :   std_logic;
        TxDataByte :   std_logic_vector(7 downto 0);
        RxDataByte :   std_logic_vector(7 downto 0);
    end record;

    type array_of_T_WasmFpgaUartWshBn_UartBlk is
      array (natural range <>) of T_WasmFpgaUartWshBn_UartBlk;


    type T_UartBlk_WasmFpgaUartWshBn is
    record
        UartRxDataPresent :   std_logic;
        UartRxBusy :   std_logic;
        UartTxBusy :   std_logic;
    end record;

    type array_of_T_UartBlk_WasmFpgaUartWshBn is
      array (natural range <>) of T_UartBlk_WasmFpgaUartWshBn;




    -- ---------- WebAssembly Uart Block( UartBlk ) ----------
    -- BUS: 

    constant WASMFPGAUART_ADR_BLK_BASE_UartBlk                                                       : std_logic_vector(23 downto 0) := x"000000";
    constant WASMFPGAUART_ADR_BLK_SIZE_UartBlk                                                       : std_logic_vector(23 downto 0) := x"000020";

        -- ControlReg: Control Register 
        constant WASMFPGAUART_WIDTH_ControlReg                                                       : integer := 32;
        constant WASMFPGAUART_ADR_ControlReg                                                         : std_logic_vector(23 downto 0) := std_logic_vector(x"000000" + unsigned(WASMFPGAUART_ADR_BLK_BASE_UartBlk));

            -- 
            constant WASMFPGAUART_BUS_MASK_UartRxRun                                                 : std_logic_vector(31 downto 0) := x"00000002";

                -- Do nothing.
                constant WASMFPGAUART_VAL_RxDoNotRun                                                 : std_logic := '0';
                -- Get RX data.
                constant WASMFPGAUART_VAL_RxDoRun                                                    : std_logic := '1';


            -- 
            constant WASMFPGAUART_BUS_MASK_UartTxRun                                                 : std_logic_vector(31 downto 0) := x"00000001";

                -- Do nothing.
                constant WASMFPGAUART_VAL_TxDoNotRun                                                 : std_logic := '0';
                -- Send TX data.
                constant WASMFPGAUART_VAL_TxDoRun                                                    : std_logic := '1';


        -- StatusReg: Status Register 
        constant WASMFPGAUART_WIDTH_StatusReg                                                        : integer := 32;
        constant WASMFPGAUART_ADR_StatusReg                                                          : std_logic_vector(23 downto 0) := std_logic_vector(x"000004" + unsigned(WASMFPGAUART_ADR_BLK_BASE_UartBlk));

            -- 
            constant WASMFPGAUART_BUS_MASK_UartRxDataPresent                                         : std_logic_vector(31 downto 0) := x"00000002";

                -- UART RX data is not present.
                constant WASMFPGAUART_VAL_RxDataIsNotPresent                                         : std_logic := '0';
                -- UART RX data is present.
                constant WASMFPGAUART_VAL_RxDataIsPresent                                            : std_logic := '1';


            -- 
            constant WASMFPGAUART_BUS_MASK_UartRxBusy                                                : std_logic_vector(31 downto 0) := x"00000002";

                -- UART RX is idle.
                constant WASMFPGAUART_VAL_RxIsNotBusy                                                : std_logic := '0';
                -- UART RX is busy.
                constant WASMFPGAUART_VAL_RxIsBusy                                                   : std_logic := '1';


            -- 
            constant WASMFPGAUART_BUS_MASK_UartTxBusy                                                : std_logic_vector(31 downto 0) := x"00000001";

                -- UART TX is idle.
                constant WASMFPGAUART_VAL_TxIsNotBusy                                                : std_logic := '0';
                -- UART TX is busy.
                constant WASMFPGAUART_VAL_TxIsBusy                                                   : std_logic := '1';


        -- TxDataReg: UART TX Data Register 
        constant WASMFPGAUART_WIDTH_TxDataReg                                                        : integer := 32;
        constant WASMFPGAUART_ADR_TxDataReg                                                          : std_logic_vector(23 downto 0) := std_logic_vector(x"000008" + unsigned(WASMFPGAUART_ADR_BLK_BASE_UartBlk));

            -- UART TX data byte

            constant WASMFPGAUART_BUS_MASK_TxDataByte                                                : std_logic_vector(31 downto 0) := x"000000FF";

        -- RxDataReg: UART RX Data Register 
        constant WASMFPGAUART_WIDTH_RxDataReg                                                        : integer := 32;
        constant WASMFPGAUART_ADR_RxDataReg                                                          : std_logic_vector(23 downto 0) := std_logic_vector(x"00000C" + unsigned(WASMFPGAUART_ADR_BLK_BASE_UartBlk));

            -- UART RX data byte

            constant WASMFPGAUART_BUS_MASK_RxDataByte                                                : std_logic_vector(31 downto 0) := x"000000FF";




end WasmFpgaUartWshBn_Package;
