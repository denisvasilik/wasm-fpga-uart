

-- ========== WebAssembly Uart Block( UartBlk) ========== 

-- This block describes the WebAssembly Uart block.
-- BUS: 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaUartWshBn_Package.all;

entity UartBlk_WasmFpgaUart is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        Adr : in std_logic_vector(23 downto 0);
        Sel : in std_logic_vector(3 downto 0);
        DatIn : in std_logic_vector(31 downto 0);
        We : in std_logic;
        Stb : in std_logic;
        Cyc : in  std_logic_vector(0 downto 0);
        UartBlk_DatOut : out std_logic_vector(31 downto 0);
        UartBlk_Ack : out std_logic;
        UartBlk_Unoccupied_Ack : out std_logic;
        UartRxRun : out std_logic;
        UartTxRun : out std_logic;
        WRegPulse_ControlReg : out std_logic;
        UartRxDataPresent : in std_logic;
        UartRxBusy : in std_logic;
        UartTxBusy : in std_logic;
        TxDataByte : out std_logic_vector(7 downto 0);
        RxDataByte : in std_logic_vector(7 downto 0)
     );
end UartBlk_WasmFpgaUart;



architecture arch_for_synthesys of UartBlk_WasmFpgaUart is

    -- ---------- block variables ---------- 
    signal PreMuxAck_Unoccupied : std_logic;
    signal UnoccupiedDec : std_logic_vector(1 downto 0);
    signal UartBlk_PreDatOut : std_logic_vector(31 downto 0);
    signal UartBlk_PreAck : std_logic;
    signal UartBlk_Unoccupied_PreAck : std_logic;
    signal PreMuxDatOut_ControlReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_ControlReg : std_logic;
    signal PreMuxDatOut_StatusReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_StatusReg : std_logic;
    signal PreMuxDatOut_TxDataReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_TxDataReg : std_logic;
    signal PreMuxDatOut_RxDataReg : std_logic_vector(31 downto 0);
    signal PreMuxAck_RxDataReg : std_logic;

    signal WriteDiff_ControlReg : std_logic;
    signal ReadDiff_ControlReg : std_logic;
     signal DelWriteDiff_ControlReg: std_logic;


    signal WriteDiff_StatusReg : std_logic;
    signal ReadDiff_StatusReg : std_logic;


    signal WriteDiff_TxDataReg : std_logic;
    signal ReadDiff_TxDataReg : std_logic;


    signal WriteDiff_RxDataReg : std_logic;
    signal ReadDiff_RxDataReg : std_logic;


    signal WReg_UartRxRun : std_logic;
    signal WReg_UartTxRun : std_logic;
    signal WReg_TxDataByte : std_logic_vector(7 downto 0);

begin 

    -- ---------- block DatOut mux ----------

    gen_unoccupied_ack : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_Unoccupied <= '0';
            UnoccupiedDec <= "00";
        elsif rising_edge(Clk) then
            UnoccupiedDec(0) <= UnoccupiedDec(1); 
            UnoccupiedDec(1)  <= (Cyc(0)  and Stb);
            PreMuxAck_Unoccupied <= UnoccupiedDec(1) and not UnoccupiedDec(0);
        end if;
    end process;

    UartBlk_DatOut <= UartBlk_PreDatOut;
    UartBlk_Ack <=  UartBlk_PreAck;
    UartBlk_Unoccupied_Ack <= UartBlk_Unoccupied_PreAck;

    mux_data_ack_out : process (Cyc, Adr, 
                                PreMuxDatOut_ControlReg,
                                PreMuxAck_ControlReg,
                                PreMuxDatOut_StatusReg,
                                PreMuxAck_StatusReg,
                                PreMuxDatOut_TxDataReg,
                                PreMuxAck_TxDataReg,
                                PreMuxDatOut_RxDataReg,
                                PreMuxAck_RxDataReg,
                                PreMuxAck_Unoccupied
                                )
    begin 
        UartBlk_PreDatOut <= x"0000_0000"; -- default statements
        UartBlk_PreAck <= '0'; 
        UartBlk_Unoccupied_PreAck <= '0';
        if ( (Cyc(0) = '1') 
              and (unsigned(Adr) >= unsigned(WASMFPGAUART_ADR_BLK_BASE_UartBlk) )
              and (unsigned(Adr) <= (unsigned(WASMFPGAUART_ADR_BLK_BASE_UartBlk) + unsigned(WASMFPGAUART_ADR_BLK_SIZE_UartBlk) - 1)) )
        then 
            if ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAUART_ADR_ControlReg)) ) then
                 UartBlk_PreDatOut <= PreMuxDatOut_ControlReg;
                UartBlk_PreAck <= PreMuxAck_ControlReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAUART_ADR_StatusReg)) ) then
                 UartBlk_PreDatOut <= PreMuxDatOut_StatusReg;
                UartBlk_PreAck <= PreMuxAck_StatusReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAUART_ADR_TxDataReg)) ) then
                 UartBlk_PreDatOut <= PreMuxDatOut_TxDataReg;
                UartBlk_PreAck <= PreMuxAck_TxDataReg;
            elsif ( (unsigned(Adr)/4)*4  = ( unsigned(WASMFPGAUART_ADR_RxDataReg)) ) then
                 UartBlk_PreDatOut <= PreMuxDatOut_RxDataReg;
                UartBlk_PreAck <= PreMuxAck_RxDataReg;
            else 
                UartBlk_PreAck <= PreMuxAck_Unoccupied;
                UartBlk_Unoccupied_PreAck <= PreMuxAck_Unoccupied;
            end if;
        end if;
    end process;


    -- ---------- block functions ---------- 


    -- .......... ControlReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_ControlReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_ControlReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_ControlReg) ) then 
            WriteDiff_ControlReg <=  We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            WriteDiff_ControlReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_ControlReg) ) then 
            ReadDiff_ControlReg <= not We and Stb and Cyc(0) and not PreMuxAck_ControlReg;
        else
            ReadDiff_ControlReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_ControlReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
             DelWriteDiff_ControlReg <= '0'; 
            PreMuxAck_ControlReg <= '0';
            WReg_UartRxRun <= '0';
            WReg_UartTxRun <= '0';
        elsif rising_edge(Clk) then
             DelWriteDiff_ControlReg <= WriteDiff_ControlReg;
            PreMuxAck_ControlReg <= WriteDiff_ControlReg or ReadDiff_ControlReg; 
            if (WriteDiff_ControlReg = '1') then
                if (Sel(0) = '1') then WReg_UartRxRun <= DatIn(1); end if;
                if (Sel(0) = '1') then WReg_UartTxRun <= DatIn(0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_ControlReg0 : process (
            WReg_UartRxRun,
            WReg_UartTxRun
            )
    begin 
         PreMuxDatOut_ControlReg <= x"0000_0000";
         PreMuxDatOut_ControlReg(1) <= WReg_UartRxRun;
         PreMuxDatOut_ControlReg(0) <= WReg_UartTxRun;
    end process;



    WRegPulse_ControlReg <= DelWriteDiff_ControlReg;

    UartRxRun <= WReg_UartRxRun;
    UartTxRun <= WReg_UartTxRun;

    -- .......... StatusReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_StatusReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_StatusReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_StatusReg) ) then 
            WriteDiff_StatusReg <=  We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            WriteDiff_StatusReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_StatusReg) ) then 
            ReadDiff_StatusReg <= not We and Stb and Cyc(0) and not PreMuxAck_StatusReg;
        else
            ReadDiff_StatusReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_StatusReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_StatusReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_StatusReg <= WriteDiff_StatusReg or ReadDiff_StatusReg; 
        end if;
    end process;

    mux_premuxdatout_StatusReg0 : process (
            UartRxDataPresent,
            UartRxBusy,
            UartTxBusy
            )
    begin 
         PreMuxDatOut_StatusReg <= x"0000_0000";
         PreMuxDatOut_StatusReg(2) <= UartRxDataPresent;
         PreMuxDatOut_StatusReg(1) <= UartRxBusy;
         PreMuxDatOut_StatusReg(0) <= UartTxBusy;
    end process;





    -- .......... TxDataReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_TxDataReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_TxDataReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_TxDataReg) ) then 
            WriteDiff_TxDataReg <=  We and Stb and Cyc(0) and not PreMuxAck_TxDataReg;
        else
            WriteDiff_TxDataReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_TxDataReg) ) then 
            ReadDiff_TxDataReg <= not We and Stb and Cyc(0) and not PreMuxAck_TxDataReg;
        else
            ReadDiff_TxDataReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_TxDataReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_TxDataReg <= '0';
            WReg_TxDataByte <= "00000000";
        elsif rising_edge(Clk) then
            PreMuxAck_TxDataReg <= WriteDiff_TxDataReg or ReadDiff_TxDataReg; 
            if (WriteDiff_TxDataReg = '1') then
                if (Sel(0) = '1') then WReg_TxDataByte(7 downto 0) <= DatIn(7 downto 0); end if;
            else
            end if;
        end if;
    end process;

    mux_premuxdatout_TxDataReg0 : process (
            WReg_TxDataByte
            )
    begin 
         PreMuxDatOut_TxDataReg <= x"0000_0000";
         PreMuxDatOut_TxDataReg(7 downto 0) <= WReg_TxDataByte;
    end process;




    TxDataByte <= WReg_TxDataByte;

    -- .......... RxDataReg, Width: 32, Type: Synchronous  .......... 

    ack_imdt_part_RxDataReg0 : process (Adr, We, Stb, Cyc, PreMuxAck_RxDataReg)
    begin 
        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_RxDataReg) ) then 
            WriteDiff_RxDataReg <=  We and Stb and Cyc(0) and not PreMuxAck_RxDataReg;
        else
            WriteDiff_RxDataReg <= '0';
        end if;

        if ( (unsigned(Adr)/4)*4 = unsigned(WASMFPGAUART_ADR_RxDataReg) ) then 
            ReadDiff_RxDataReg <= not We and Stb and Cyc(0) and not PreMuxAck_RxDataReg;
        else
            ReadDiff_RxDataReg <= '0';
        end if;
    end process;

    reg_syn_clk_part_RxDataReg0 : process (Clk, Rst)
    begin 
        if (Rst = '1') then 
            PreMuxAck_RxDataReg <= '0';
        elsif rising_edge(Clk) then
            PreMuxAck_RxDataReg <= WriteDiff_RxDataReg or ReadDiff_RxDataReg; 
        end if;
    end process;

    mux_premuxdatout_RxDataReg0 : process (
            RxDataByte
            )
    begin 
         PreMuxDatOut_RxDataReg <= x"0000_0000";
         PreMuxDatOut_RxDataReg(7 downto 0) <= RxDataByte;
    end process;






end architecture;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaUartWshBn_Package.all;

-- ========== Wishbone for WasmFpgaUart (WasmFpgaUartWishbone) ========== 

entity WasmFpgaUartWshBn is
    port (
        Clk : in std_logic;
        Rst : in std_logic;
        WasmFpgaUartWshBnDn : in T_WasmFpgaUartWshBnDn;
        WasmFpgaUartWshBnUp : out T_WasmFpgaUartWshBnUp;
        WasmFpgaUartWshBn_UnOccpdRcrd : out T_WasmFpgaUartWshBn_UnOccpdRcrd;
        WasmFpgaUartWshBn_UartBlk : out T_WasmFpgaUartWshBn_UartBlk;
        UartBlk_WasmFpgaUartWshBn : in T_UartBlk_WasmFpgaUartWshBn
     );
end WasmFpgaUartWshBn;



architecture arch_for_synthesys of WasmFpgaUartWshBn is

    component UartBlk_WasmFpgaUart is
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            Adr : in std_logic_vector(23 downto 0);
            Sel : in std_logic_vector(3 downto 0);
            DatIn : in std_logic_vector(31 downto 0);
            We : in std_logic;
            Stb : in std_logic;
            Cyc : in  std_logic_vector(0 downto 0);
            UartBlk_DatOut : out std_logic_vector(31 downto 0);
            UartBlk_Ack : out std_logic;
            UartBlk_Unoccupied_Ack : out std_logic;
            UartRxRun : out std_logic;
            UartTxRun : out std_logic;
            WRegPulse_ControlReg : out std_logic;
            UartRxDataPresent : in std_logic;
            UartRxBusy : in std_logic;
            UartTxBusy : in std_logic;
            TxDataByte : out std_logic_vector(7 downto 0);
            RxDataByte : in std_logic_vector(7 downto 0)
         );
    end component; 


    -- ---------- internal wires ----------

    signal Sel : std_logic_vector(3 downto 0);
    signal UartBlk_DatOut : std_logic_vector(31 downto 0);
    signal UartBlk_Ack : std_logic;
    signal UartBlk_Unoccupied_Ack : std_logic;


begin 


    -- ---------- Connect register instances ----------

    i_UartBlk_WasmFpgaUart :  UartBlk_WasmFpgaUart
     port map (
        Clk => Clk,
        Rst => Rst,
        Adr => WasmFpgaUartWshBnDn.Adr,
        Sel => Sel,
        DatIn => WasmFpgaUartWshBnDn.DatIn,
        We =>  WasmFpgaUartWshBnDn.We,
        Stb => WasmFpgaUartWshBnDn.Stb,
        Cyc => WasmFpgaUartWshBnDn.Cyc,
        UartBlk_DatOut => UartBlk_DatOut,
        UartBlk_Ack => UartBlk_Ack,
        UartBlk_Unoccupied_Ack => UartBlk_Unoccupied_Ack,
        UartRxRun => WasmFpgaUartWshBn_UartBlk.UartRxRun,
        UartTxRun => WasmFpgaUartWshBn_UartBlk.UartTxRun,
        WRegPulse_ControlReg => WasmFpgaUartWshBn_UartBlk.WRegPulse_ControlReg,
        UartRxDataPresent => UartBlk_WasmFpgaUartWshBn.UartRxDataPresent,
        UartRxBusy => UartBlk_WasmFpgaUartWshBn.UartRxBusy,
        UartTxBusy => UartBlk_WasmFpgaUartWshBn.UartTxBusy,
        TxDataByte => WasmFpgaUartWshBn_UartBlk.TxDataByte,
        RxDataByte => UartBlk_WasmFpgaUartWshBn.RxDataByte
     );


    Sel <= WasmFpgaUartWshBnDn.Sel;                                                      

    WasmFpgaUartWshBn_UnOccpdRcrd.forRecord_Adr <= WasmFpgaUartWshBnDn.Adr;
    WasmFpgaUartWshBn_UnOccpdRcrd.forRecord_Sel <= Sel;
    WasmFpgaUartWshBn_UnOccpdRcrd.forRecord_We <= WasmFpgaUartWshBnDn.We;
    WasmFpgaUartWshBn_UnOccpdRcrd.forRecord_Cyc <= WasmFpgaUartWshBnDn.Cyc;

    -- ---------- Or all DataOuts and Acks of blocks ----------

     WasmFpgaUartWshBnUp.DatOut <= 
        UartBlk_DatOut;

     WasmFpgaUartWshBnUp.Ack <= 
        UartBlk_Ack;

     WasmFpgaUartWshBn_UnOccpdRcrd.Unoccupied_Ack <= 
        UartBlk_Unoccupied_Ack;





end architecture;



