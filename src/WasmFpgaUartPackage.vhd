library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
  use work.WasmFpgaUartWshBn_Package.all;

package WasmFpgaUartPackage is

    constant MAX_STATE_HIGH_IDX : natural  := 7;
    constant MAX_STRING_HIGH_IDX : natural := 127;

    constant stateIdle : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(0,MAX_STATE_HIGH_IDX+1);
    constant stateExit : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(1,MAX_STATE_HIGH_IDX+1);
    constant stateError : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(255,MAX_STATE_HIGH_IDX+1);

   procedure println (constant value : in string;
                      signal state : inout unsigned(MAX_STATE_HIGH_IDX downto 0);
                      signal count : inout natural range 0 to MAX_STRING_HIGH_IDX;
                      signal Uart_Adr : out std_logic_vector(23 downto 0);
                      signal Uart_Sel : out std_logic_vector(3 downto 0);
                      signal Uart_DatIn: in std_logic_vector(31 downto 0);
                      signal Uart_We : out std_logic;
                      signal Uart_Stb : out std_logic;
                      signal Uart_Cyc : out std_logic_vector(0 downto 0);
                      signal Uart_DatOut : out std_logic_vector(31 downto 0);
                      signal Uart_Ack : in std_logic);

end package;

package body WasmFpgaUartPackage is

   procedure println (constant value : in string;
                      signal state : inout unsigned(MAX_STATE_HIGH_IDX downto 0);
                      signal count : inout integer range 0 to MAX_STRING_HIGH_IDX;
                      signal Uart_Adr : out std_logic_vector(23 downto 0);
                      signal Uart_Sel : out std_logic_vector(3 downto 0);
                      signal Uart_DatIn: in std_logic_vector(31 downto 0);
                      signal Uart_We : out std_logic;
                      signal Uart_Stb : out std_logic;
                      signal Uart_Cyc : out std_logic_vector(0 downto 0);
                      signal Uart_DatOut : out std_logic_vector(31 downto 0);
                      signal Uart_Ack : in std_logic) is
       constant stateTransmit0 : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(2,MAX_STATE_HIGH_IDX+1);
       constant stateTransmit1 : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(5,MAX_STATE_HIGH_IDX+1);
       constant stateTransmit2 : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(3,MAX_STATE_HIGH_IDX+1);
       constant stateTransmit3 : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(6,MAX_STATE_HIGH_IDX+1);
       constant stateTransmit4 : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(7,MAX_STATE_HIGH_IDX+1);
       constant stateTransmit5 : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(8,MAX_STATE_HIGH_IDX+1);
       constant stateTransmit6 : unsigned(MAX_STATE_HIGH_IDX downto 0) := to_unsigned(9,MAX_STATE_HIGH_IDX+1);
   begin
       case state is
           when stateIdle =>
               count <= 1;
               state <= stateTransmit0;
           when stateTransmit0 =>
                Uart_Cyc <= "1";
                Uart_Stb <= '1';
                Uart_Sel <= (others => '1');
                Uart_We <= '1';
                Uart_Adr <= WASMFPGAUART_ADR_TxDataReg;
                Uart_DatOut <= std_logic_vector(to_unsigned(character'pos(value(count)), Uart_DatOut'LENGTH));
                state <= stateTransmit1;
           when stateTransmit1 =>
                if ( Uart_Ack = '1' ) then
                    Uart_Cyc <= (others => '0');
                    Uart_Stb <= '0';
                    Uart_Adr <= (others => '0');
                    Uart_Sel <= (others => '0');
                    Uart_We <= '0';
                    state <= stateTransmit2;
                end if;
           when stateTransmit2 =>
                Uart_Cyc <= "1";
                Uart_Stb <= '1';
                Uart_Sel <= (others => '1');
                Uart_We <= '1';
                Uart_Adr <= WASMFPGAUART_ADR_ControlReg;
                Uart_DatOut <= (31 downto 1 => '0') & WASMFPGAUART_VAL_TxDoRun;
                state <= stateTransmit3;
           when stateTransmit3 =>
                if ( Uart_Ack = '1' ) then
                    Uart_Cyc <= (others => '0');
                    Uart_Stb <= '0';
                    Uart_Adr <= (others => '0');
                    Uart_Sel <= (others => '0');
                    Uart_We <= '0';
                    state <= stateTransmit4;
                end if;
           when stateTransmit4 =>
                Uart_Cyc <= "1";
                Uart_Stb <= '1';
                Uart_Sel <= (others => '1');
                Uart_We <= '1';
                Uart_Adr <= WASMFPGAUART_ADR_StatusReg;
                state <= stateTransmit5;
           when stateTransmit5 =>
                if ( Uart_Ack = '1' ) then
                    Uart_Cyc <= "0";
                    Uart_Stb <= '0';
                    Uart_Adr <= (others => '0');
                    Uart_Sel <= (others => '0');
                    Uart_We <= '0';
                    if (Uart_DatIn(0) = WASMFPGAUART_VAL_TxIsNotBusy) then
                        state <= stateTransmit6;
                    else
                        state <= stateTransmit4;
                    end if;
                end if;
           when stateTransmit6 =>
               if (count = value'LENGTH) then
                   state <= stateExit;
               else
                   count <= count + 1;
                   state <= stateTransmit0;
               end if;
           when stateExit =>
                state <= stateExit;
           when others =>
               state  <= stateError;
       end case;
	end;

end package body;
