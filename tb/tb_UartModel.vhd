----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/25/2015 03:34:51 PM
-- Design Name: 
-- Module Name: tb_UartModel - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tb_UartModel is
    port ( 
        Clk : in std_logic;
        Rst : in std_logic;
        UartTxRun : in std_logic;
        UartTxBusy : out std_logic;
        UartTx : out std_logic
    );
end tb_UartModel;

architecture Behavioral of tb_UartModel is

  signal BaudCount : integer range 0 to 53 := 0; 
  signal En16xBaud : std_logic := '0';
  
  signal DataCount : unsigned(3 downto 0);
  signal DataByte : std_logic_vector(9 downto 0);

begin

  BaudRateGenerator : process(Clk, Rst) is
  begin
    if( Rst = '1' ) then
      En16xBaud <= '0';
      BaudCount <= 0;
    elsif rising_edge(Clk) then
        BaudCount <= BaudCount + 1;
        En16xBaud <= '0';
        if( BaudCount = (53 * 16) ) then
            BaudCount <= 0;
            En16xBaud <= '1';
        end if;
    end if;
  end process;

    UartTransmitter : process (Clk, Rst) is
    begin
        if (Rst = '1') then
            UartTxBusy <= '1';
            UartTx <= '1';
            DataByte <= "0100010001"; -- 10 Bits = start bit (0), 8 data bits, stop bit (1)
        elsif rising_edge(Clk) then
            if( UartTxRun = '1' and En16xBaud = '1') then
                UartTx <= DataByte(9);
                DataByte <= DataByte(8 downto 0) & DataByte(9);
                UartTxBusy <= '1';
                DataCount <= DataCount + 1;
                if( DataCount = DataByte'LENGTH ) then
                    DataCount <= (others => '0');
                end if;
            elsif( UartTxRun = '0' ) then
                DataCount <= (others => '0');
                UartTxBusy <= '0';
                UartTx <= '1';
            end if;
        end if;
    end process;

end Behavioral;
