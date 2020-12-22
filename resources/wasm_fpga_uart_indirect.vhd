

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WasmFpgaUartWshBn_Package.all;

entity tb_WasmFpgaUartWshBn is
end tb_WasmFpgaUartWshBn;

architecture arch_for_test of tb_WasmFpgaUartWshBn is

    component tbs_WshFileIo is              
    generic (                               
         inp_file  : string;                
         outp_file : string                 
        );                                  
    port(                                   
        clock        : in    std_logic;     
        reset        : in    std_logic;     
        WshDn        : out   T_WshDn;       
        WshUp        : in    T_WshUp        
        );                                  
    end component;                          



    component WasmFpgaUartWshBn is
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            WasmFpgaUartWshBnDn : in T_WasmFpgaUartWshBnDn;
            WasmFpgaUartWshBnUp : out T_WasmFpgaUartWshBnUp;
            WasmFpgaUartWshBn_UnOccpdRcrd : out T_WasmFpgaUartWshBn_UnOccpdRcrd;
            WasmFpgaUartWshBn_UartBlk : out T_WasmFpgaUartWshBn_UartBlk;
            UartBlk_WasmFpgaUartWshBn : in T_UartBlk_WasmFpgaUartWshBn
         );
    end component; 


    signal Clk : std_logic := '0';                                         
    signal Rst : std_logic := '1';                                         



    signal WshDn : T_WshDn;
    signal WshUp : T_WshUp;
    signal Wsh_UnOccpdRcrd : T_Wsh_UnOccpdRcrd;
    signal Wsh_UartBlk : T_Wsh_UartBlk;
    signal UartBlk_Wsh : T_UartBlk_Wsh;



begin 


    i_tbs_WshFileIo : tbs_WshFileIo            
    generic map (                              
        inp_file  => "tb_mC_stimuli.txt",      
        outp_file => "src/tb_mC_trace.txt")    
    port map (                                 
        clock   => Clk,                        
        reset   => Rst,                        
        WshDn   => WshDn,                      
        WshUp   => WshUp                       
    );                                         



    -- ---------- map wishbone component ---------- 

    i_WasmFpgaUartWshBn :  WasmFpgaUartWshBn
     port map (
        WshDn => WshDn,
        WshUp => WshUp,
        Wsh_UnOccpdRcrd => Wsh_UnOccpdRcrd,
        Wsh_UartBlk => Wsh_UartBlk,
        UartBlk_Wsh => UartBlk_Wsh
        );

    -- ---------- assign defaults to all wishbone inputs ---------- 

    -- ------------------- general additional signals ------------------- 

    -- ------------------- UartBlk ------------------- 
    -- ControlReg  
    -- StatusReg  
    UartBlk_Wsh.UartRxDataPresent <= '0';
    UartBlk_Wsh.UartRxBusy <= '0';
    UartBlk_Wsh.UartTxBusy <= '0';
    -- TxDataReg  
    -- RxDataReg  



    WshDn.Clk <= Clk;                                                  
    WshDn.Rst <= Rst;                                                  
    -- ---------- drive testbench time --------------------                       
    Clk   <= TRANSPORT NOT Clk AFTER 12500 ps;  -- 40Mhz                       
    Rst   <= TRANSPORT '0' AFTER 100 ns;                                       


end architecture;

