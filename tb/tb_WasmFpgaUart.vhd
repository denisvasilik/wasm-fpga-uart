library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.tb_types.all;

entity tb_WasmFpgaUart is
    generic (
        stimulus_path : string := "../../../../../simstm/";
        stimulus_file : string := "WasmFpgaUart.stm"
    );
end;

architecture behavioural of tb_WasmFpgaUart is

    constant CLK100M_PERIOD : time := 10 ns;

    signal Clk100M : std_logic := '0';
    signal Rst : std_logic := '1';
    signal nRst : std_logic := '0';

    signal WasmFpgaUart_FileIo : T_WasmFpgaUart_FileIo;
    signal FileIo_WasmFpgaUart : T_FileIo_WasmFpgaUart;

    signal UartModel_FileIo : T_UartModel_FileIo;
    signal FileIo_UartModel : T_FileIo_UartModel;

    signal UartRx : std_logic := '0';
    signal UartTx : std_logic := '0';

begin

	nRst <= not Rst;

    Clk100MGen : process is
    begin
        Clk100M <= not Clk100M;
        wait for CLK100M_PERIOD / 2;
    end process;

    RstGen : process is
    begin
        Rst <= '1';
        wait for 100ns;
        Rst <= '0';
        wait;
    end process;

    tb_FileIo_i : entity work.tb_FileIo
        generic map (
            stimulus_path => stimulus_path,
            stimulus_file => stimulus_file
        )
        port map (
            Clk => Clk100M,
            Rst => Rst,
            WasmFpgaUart_FileIo => WasmFpgaUart_FileIo,
            FileIo_WasmFpgaUart => FileIo_WasmFpgaUart,
            UartModel_FileIo => UartModel_FileIo,
            FileIo_UartModel => FileIo_UartModel
        );

    WasmFpgaUart_i : entity work.WasmFpgaUart
        port map (
            Clk => Clk100M,
            nRst => nRst,
            Adr => FileIo_WasmFpgaUart.Adr,
            Sel => FileIo_WasmFpgaUart.Sel,
            DatIn => FileIo_WasmFpgaUart.DatIn,
            We => FileIo_WasmFpgaUart.We,
            Stb => FileIo_WasmFpgaUart.Stb,
            Cyc => FileIo_WasmFpgaUart.Cyc,
            DatOut => WasmFpgaUart_FileIo.DatOut,
            Ack => WasmFpgaUart_FileIo.Ack,
            UartRx => UartRx,
            UartTx => UartTx
       );

    tb_UartModel_i : entity work.tb_UartModel
    port map (
        Clk => Clk100M,
        Rst => Rst,
        UartTxRun => FileIo_UartModel.UartTxRun,
        UartTxBusy => UartModel_FileIo.UartTxBusy,
        UartTx => UartRx
    );

end;
