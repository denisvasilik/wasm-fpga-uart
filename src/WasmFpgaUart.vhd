library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WasmFpgaUart is
    generic (
        -- clock_cycles = frequenz / (16 * baud_rate)
        --
        -- 650 @ 100MHz (actually 651 including zero) -> baud rate 9600
        -- 53 @ 100MHz (actually 54 including zero) -> baud rate 115200
        -- 44 @ 83.33 MHz (actually 45 including zero) -> baud rate 115200
        ClockCycles : integer := 53
    );
    port (
      Clk : in std_logic;
      nRst : in std_logic;
      Adr : in std_logic_vector(23 downto 0);
      Sel : in std_logic_vector(3 downto 0);
      DatIn : in std_logic_vector(31 downto 0);
      We : in std_logic;
      Stb : in std_logic;
      Cyc : in  std_logic_vector(0 downto 0);
      DatOut : out std_logic_vector(31 downto 0);
      Ack : out std_logic;
      UartRx : in std_logic;
      UartTx : out std_logic
    );
end;

architecture WasmFpgaUartDefault of WasmFpgaUart is

  signal Rst : std_logic;
  signal ControlRegPulse : std_logic;

  --
  signal UartRxRun : std_logic;
  signal UartRxBusy : std_logic;
  signal UartRxDataByte : std_logic_vector(7 downto 0);
  signal UartRxDataPresent : std_logic;
  signal UartTxRun : std_logic;
  signal UartTxBusy: std_logic;
  signal UartTxDataByte: std_logic_vector(7 downto 0);

  -- Signals used to connect UART_TX6
  signal UartTxDataIn : std_logic_vector(7 downto 0);
  signal WriteToUartTx : std_logic;
  signal UartTxDataPresent : std_logic;
  signal UartTxHalfFull : std_logic;
  signal UartTxFull : std_logic;
  signal UartRxDataPresentInternal : std_logic;
  signal UartRxDataOutInternal : std_logic_vector(7 downto 0);

  -- Signals used to connect UART_RX6
  signal ReadFromUartRx : std_logic;
  signal UartRxHalfFull : std_logic;
  signal UartRxFull : std_logic;

  -- Signals used to define baud rate
  signal BaudCount : integer range 0 to ClockCycles := 0;
  signal En16xBaud : std_logic := '0';

  signal FifoWriteEnableAsync : std_logic;
  signal FifoReadEnableAsync : std_logic;
  signal FifoDataIn : std_logic_vector(7 downto 0);
  signal FifoWriteEnable : std_logic;
  signal FifoReadEnable : std_logic;
  signal FifoDataOut : std_logic_vector(7 downto 0);
  signal FifoFull : std_logic;
  signal FifoEmpty : std_logic;
  signal UartSenderTxData : std_logic_vector(7 downto 0);
  signal UartSenderState : unsigned(3 downto 0);

  constant UartSender0 : natural := 0;
  constant UartSender1 : natural := 1;
  constant UartSender2 : natural := 2;
  constant UartSenderError0 : natural := 3;

  signal UartRamCopyState : unsigned(0 downto 0);

  constant UartRamCopyState0 : natural := 0;
  constant UartRamCopyState1 : natural := 1;

  signal UartReceiverState : unsigned(1 downto 0);

  constant UartReceiverState0 : natural := 0;
  constant UartReceiverState1 : natural := 1;
  constant UartReceiverState2 : natural := 2;

  component uart_tx6
    port (
      data_in : in std_logic_vector(7 downto 0);
      en_16_x_baud : in std_logic;
      serial_out : out std_logic;
      buffer_write : in std_logic;
      buffer_data_present : out std_logic;
      buffer_half_full : out std_logic;
      buffer_full : out std_logic;
      buffer_reset : in std_logic;
      clk : in std_logic
    );
  end component;

  component uart_rx6
    port (
      serial_in : in std_logic;
      en_16_x_baud : in std_logic;
      data_out : out std_logic_vector(7 downto 0);
      buffer_read : in std_logic;
      buffer_data_present : out std_logic;
      buffer_half_full : out std_logic;
      buffer_full : out std_logic;
      buffer_reset : in std_logic;
      clk : in std_logic
    );
  end component;

  component UartRxFifo is
    port (
      clk : in STD_LOGIC;
      srst : in STD_LOGIC;
      din : in STD_LOGIC_VECTOR ( 7 downto 0 );
      wr_en : in STD_LOGIC;
      rd_en : in STD_LOGIC;
      dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
      full : out STD_LOGIC;
      empty : out STD_LOGIC
    );
  end component;

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
        WTransPulse_ControlReg : out std_logic;
        UartRxDataPresent : in std_logic;
        UartRxBusy : in std_logic;
        UartTxBusy : in std_logic;
        TxDataByte : out std_logic_vector(7 downto 0);
        RxDataByte : out std_logic_vector(7 downto 0)
    );
  end component;

begin

  Rst <= not nRst;

  UartRxDataPresent <= '0' when FifoEmpty = '1' else '1';
  FifoWriteEnableAsync <= '1' when FifoWriteEnable = '1' else '0';
  FifoReadEnableAsync <= '1' when FifoReadEnable = '1' else '0';
  UartRxDataByte <= FifoDataOut;

  rx: uart_rx6
    port map (
      serial_in => UartRx,
      en_16_x_baud => En16xBaud,
      data_out => UartRxDataOutInternal,
      buffer_read => ReadFromUartRx,
      buffer_data_present => UartRxDataPresentInternal,
      buffer_half_full => UartRxHalfFull,
      buffer_full => UartRxFull,
      buffer_reset => Rst,
      clk => Clk
  );

  tx: uart_tx6
    port map (
      data_in => UartTxDataIn,
      en_16_x_baud => En16xBaud,
      serial_out => UartTx,
      buffer_write => WriteToUartTx,
      buffer_data_present => UartTxDataPresent,
      buffer_half_full => UartTxHalfFull,
      buffer_full => UartTxFull,
      buffer_reset => Rst,
      clk => Clk
  );

  BaudRateGenerator : process(Clk, Rst)
  begin
    if rising_edge(Clk) then
        if( Rst = '1' ) then
            En16xBaud <= '0';
            BaudCount <= 0;
        else
            BaudCount <= BaudCount + 1;
            En16xBaud <= '0';
            -- clock_cycles = frequenz / (16 * baud_rate)
            --
            -- 650 @ 100MHz (actually 651 including zero) -> baud rate 9600
            -- 53 @ 100MHz (actually 54 including zero) -> baud rate 115200
            -- 44 @ 83.33 MHz (actually 45 including zero) -> baud rate 115200
            if( BaudCount = ClockCycles ) then
                BaudCount <= 0;
                En16xBaud <= '1';
            end if;
         end if;
    end if;
  end process;

  UartSender : process (Clk, Rst)
  begin
    if rising_edge(Clk) then
        if( Rst = '1' ) then
            UartTxDataIn <= (others => '0');
            UartSenderTxData <= (others => '0');
            WriteToUartTx <= '0';
            UartTxBusy <= '1';
            UartSenderState <= to_unsigned(UartSender0, UartSenderState'LENGTH);
        else
            if( UartSenderState = UartSender0 ) then
                UartTxBusy <= '0';
                if( ControlRegPulse = '1' and UartTxRun = '1' ) then
                    UartTxBusy <= '1';
                    UartSenderTxData <= UartTxDataByte;
                    UartSenderState <= to_unsigned(UartSender1, UartSenderState'LENGTH);
                end if;
            -- Transmit data
            elsif( UartSenderState = UartSender1 ) then
                if( UartTxFull = '0' ) then
                    WriteToUartTx <= '1';
                    UartTxDataIn <= UartSenderTxData;
                    UartSenderState <= to_unsigned(UartSender2, UartSenderState'LENGTH);
                end if;
            -- Wait until write process has been finished (depends on baud rate)
            elsif( UartSenderState = UartSender2 ) then
                WriteToUartTx <= '0';
                -- ALTERNATIVE: Another way would be to let the user have the UartTxFull signal
                --              in order to make the user wait until the buffer has been emptied.
                if( UartTxDataPresent = '0' ) then
                    UartSenderState <= to_unsigned(UartSender0, UartSenderState'LENGTH);
                end if;
            elsif( UartSenderState = UartSenderError0 ) then
                UartSenderState <= to_unsigned(UartSenderError0, UartSenderState'LENGTH);
            else
                UartSenderState <= to_unsigned(UartSenderError0, UartSenderState'LENGTH);
            end if;
        end if;
    end if;
  end process;

  UartReceiver : process (Clk, Rst) is
  begin
    if rising_edge(Clk) then
        if ( Rst = '1' ) then
            UartRxBusy <= '1';
            FifoReadEnable <= '0';
            UartReceiverState <= (others => '0');
        else
            if( UartReceiverState = UartReceiverState0 ) then
                UartRxBusy <= '0';
                if( UartRxRun = '1' ) then
                    UartRxBusy <= '1';
                    FifoReadEnable <= '1';
                    UartReceiverState <= to_unsigned(UartReceiverState1, UartReceiverState'LENGTH);
                end if;
            elsif( UartReceiverState = UartReceiverState1 ) then
                FifoReadEnable <= '0';
                UartReceiverState <= to_unsigned(UartReceiverState2, UartReceiverState'LENGTH);
            elsif( UartReceiverState = UartReceiverState2 ) then
                UartReceiverState <= to_unsigned(UartReceiverState0, UartReceiverState'LENGTH);
            end if;
        end if;
    end if;
  end process;

  UartRamCopy : process (Clk, Rst) is
  begin
      if rising_edge(Clk) then
        if( Rst = '1' ) then
            FifoWriteEnable <= '0';
            ReadFromUartRx <= '0';
            FifoDataIn <= (others => '0');
            UartRamCopyState <= (others => '0');
        else
            if( UartRamCopyState = UartRamCopyState0 ) then
                ReadFromUartRx <= '0';
                FifoWriteEnable <= '0';
                if( UartRxDataPresentInternal = '1' ) then
                    ReadFromUartRx <= '1';
                    FifoWriteEnable <= '1';
                    FifoDataIn <= UartRxDataOutInternal;
                    UartRamCopyState <= to_unsigned(UartRamCopyState1, UartRamCopyState'LENGTH);
                end if;
            elsif( UartRamCopyState = UartRamCopyState1 ) then
                ReadFromUartRx <= '0';
                FifoWriteEnable <= '0';
                UartRamCopyState <= to_unsigned(UartRamCopyState0, UartRamCopyState'LENGTH);
            end if;
        end if;
      end if;
  end process;

  UartRxFifo_i : UartRxFifo
    port map (
      clk => Clk,
      srst => Rst,
      din => FifoDataIn,
      wr_en => FifoWriteEnableAsync,
      rd_en => FifoReadEnableAsync,
      dout => FifoDataOut,
      full => FifoFull,
      empty => FifoEmpty
    );

  UartBlk_WasmFpgaUart_i : UartBlk_WasmFpgaUart
    port map (
      Clk => Clk,
      Rst => Rst,
      Adr => Adr,
      Sel => Sel,
      DatIn => DatIn,
      We => We,
      Stb => Stb,
      Cyc => Cyc,
      UartBlk_DatOut => DatOut,
      UartBlk_Ack => Ack,
      UartBlk_Unoccupied_Ack => open,
      UartRxRun => UartRxRun,
      UartTxRun => UartTxRun,
      WTransPulse_ControlReg => ControlRegPulse,
      UartRxDataPresent => UartRxDataPresent,
      UartRxBusy => UartRxBusy,
      UartTxBusy => UartTxBusy,
      TxDataByte => UartTxDataByte,
      RxDataByte => UartRxDataByte
    );

end;
