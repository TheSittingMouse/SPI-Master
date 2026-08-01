library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity spi_master_tb is
end spi_master_tb;

architecture Behavioral of spi_master_tb is

    constant c_WIDTH : positive := 8;
    constant c_MAIN_CLK_FREQ : positive := 100_000_000;
    constant c_SPI_FREQ : positive := 10_000_000;

    constant c_CPOL : std_logic := '0';

    constant c_CLK_PERIOD : time := 10 ns;
    constant c_CLK_HALF_PERIOD : time := 5 ns;

    constant c_CLK_CYCLES_PER_SCK : positive := c_MAIN_CLK_FREQ / c_SPI_FREQ;
    constant c_HALF_SCK_CYCLES : positive := c_CLK_CYCLES_PER_SCK / 2;
    constant c_IDLE_TIMEOUT_TICKS : positive := 4 * c_CLK_CYCLES_PER_SCK;

    signal r_CLK : std_logic := '0';

    -- CPHA = 0 instance signals.
    signal r_RESET_CPHA0 : std_logic := '0';
    signal r_TX_DATA_CPHA0 : std_logic_vector(c_WIDTH-1 downto 0) := (others => '0');
    signal r_RX_DATA_CPHA0 : std_logic_vector(c_WIDTH-1 downto 0) := (others => '0');
    signal r_SCK_CPHA0 : std_logic := c_CPOL;
    signal r_SS_CPHA0 : std_logic := '1';
    signal r_MOSI_CPHA0 : std_logic := '0';
    signal r_MISO_CPHA0 : std_logic := '0';
    signal r_TX_VALID_CPHA0 : std_logic := '0';
    signal r_TX_READY_CPHA0 : std_logic := '0';
    signal r_RX_VALID_CPHA0 : std_logic := '0';
    signal r_RX_READY_CPHA0 : std_logic := '0';
    signal r_TX_BUFFER_FULL_CPHA0 : std_logic := '0';
    signal r_BUSY_CPHA0 : std_logic := '0';
    signal r_RX_OVERRUN_CPHA0 : std_logic := '0';
    signal r_REQUIRE_SS_LOW_CPHA0 : std_logic := '0';

    -- CPHA = 1 instance signals.
    signal r_RESET_CPHA1 : std_logic := '0';
    signal r_TX_DATA_CPHA1 : std_logic_vector(c_WIDTH-1 downto 0) := (others => '0');
    signal r_RX_DATA_CPHA1 : std_logic_vector(c_WIDTH-1 downto 0) := (others => '0');
    signal r_SCK_CPHA1 : std_logic := c_CPOL;
    signal r_SS_CPHA1 : std_logic := '1';
    signal r_MOSI_CPHA1 : std_logic := '0';
    signal r_MISO_CPHA1 : std_logic := '0';
    signal r_TX_VALID_CPHA1 : std_logic := '0';
    signal r_TX_READY_CPHA1 : std_logic := '0';
    signal r_RX_VALID_CPHA1 : std_logic := '0';
    signal r_RX_READY_CPHA1 : std_logic := '0';
    signal r_TX_BUFFER_FULL_CPHA1 : std_logic := '0';
    signal r_BUSY_CPHA1 : std_logic := '0';
    signal r_RX_OVERRUN_CPHA1 : std_logic := '0';
    signal r_REQUIRE_SS_LOW_CPHA1 : std_logic := '0';

begin

    p_CLK : process
    begin
        r_CLK <= '0';
        wait for c_CLK_HALF_PERIOD;
        r_CLK <= '1';
        wait for c_CLK_HALF_PERIOD;
    end process p_CLK;


    UUT_CPHA0 : entity work.spi_master
    generic map(
        c_WIDTH => c_WIDTH,
        c_MAIN_CLK_FREQ => c_MAIN_CLK_FREQ,
        c_SPI_FREQ => c_SPI_FREQ,
        c_CPOL => c_CPOL,
        c_CPHA => '0'
    )
    port map(
        i_clk => r_CLK,
        i_rst => r_RESET_CPHA0,

        i_tx_data => r_TX_DATA_CPHA0,
        o_rx_data => r_RX_DATA_CPHA0,

        o_sck => r_SCK_CPHA0,
        o_ss => r_SS_CPHA0,
        o_mosi => r_MOSI_CPHA0,
        i_miso => r_MISO_CPHA0,

        i_tx_valid => r_TX_VALID_CPHA0,
        o_tx_ready => r_TX_READY_CPHA0,

        i_rx_valid => r_RX_VALID_CPHA0,
        o_rx_ready => r_RX_READY_CPHA0,

        o_tx_buffer_full => r_TX_BUFFER_FULL_CPHA0,
        o_busy => r_BUSY_CPHA0,
        o_rx_overrun => r_RX_OVERRUN_CPHA0
    );


    UUT_CPHA1 : entity work.spi_master
    generic map(
        c_WIDTH => c_WIDTH,
        c_MAIN_CLK_FREQ => c_MAIN_CLK_FREQ,
        c_SPI_FREQ => c_SPI_FREQ,
        c_CPOL => c_CPOL,
        c_CPHA => '1'
    )
    port map(
        i_clk => r_CLK,
        i_rst => r_RESET_CPHA1,

        i_tx_data => r_TX_DATA_CPHA1,
        o_rx_data => r_RX_DATA_CPHA1,

        o_sck => r_SCK_CPHA1,
        o_ss => r_SS_CPHA1,
        o_mosi => r_MOSI_CPHA1,
        i_miso => r_MISO_CPHA1,

        i_tx_valid => r_TX_VALID_CPHA1,
        o_tx_ready => r_TX_READY_CPHA1,

        i_rx_valid => r_RX_VALID_CPHA1,
        o_rx_ready => r_RX_READY_CPHA1,

        o_tx_buffer_full => r_TX_BUFFER_FULL_CPHA1,
        o_busy => r_BUSY_CPHA1,
        o_rx_overrun => r_RX_OVERRUN_CPHA1
    );


    -- These guards are enabled only during a test that requires a continuous
    -- transaction. Sampling on every main-clock edge catches even a one-clock
    -- SS pulse that happens between two SCK edges.
    p_CPHA0_SS_GUARD : process(r_CLK)
    begin
        if rising_edge(r_CLK) then
            if r_REQUIRE_SS_LOW_CPHA0 = '1' then
                assert r_SS_CPHA0 = '0'
                    report "CPHA=0 continuous-transfer check: SS went high between bytes."
                    severity failure;
            end if;
        end if;
    end process p_CPHA0_SS_GUARD;


    p_CPHA1_SS_GUARD : process(r_CLK)
    begin
        if rising_edge(r_CLK) then
            if r_REQUIRE_SS_LOW_CPHA1 = '1' then
                assert r_SS_CPHA1 = '0'
                    report "CPHA=1 continuous-transfer check: SS went high between bytes."
                    severity failure;
            end if;
        end if;
    end process p_CPHA1_SS_GUARD;


    p_TEST_BENCH : process is

        procedure p_tick_n(constant n : positive) is
        begin
            for i in 1 to n loop
                wait until rising_edge(r_CLK);
                wait for 1 ns;
            end loop;
        end procedure p_tick_n;


        procedure p_PREPARE_IDLE(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
        begin
            o_tx_data <= (others => '0');
            o_tx_valid <= '0';
            o_rx_valid <= '0';
            o_miso <= '0';
            o_require_ss_low <= '0';

            o_reset <= '1';
            p_tick_n(3);
            o_reset <= '0';
            p_tick_n(2);

            assert i_ss = '1'
                report "CPHA=" & std_logic'image(cpha) & ": SS should be high after reset."
                severity failure;

            assert i_sck = c_CPOL
                report "CPHA=" & std_logic'image(cpha) & ": SCK should be at CPOL while idle."
                severity failure;

            assert i_mosi = '0'
                report "CPHA=" & std_logic'image(cpha) & ": MOSI should reset to 0."
                severity failure;

            assert i_rx_data = x"00"
                report "CPHA=" & std_logic'image(cpha) & ": RX_DATA should reset to 0."
                severity failure;

            assert i_tx_ready = '1'
                report "CPHA=" & std_logic'image(cpha) & ": TX_READY should be high while idle."
                severity failure;

            assert i_rx_ready = '0'
                report "CPHA=" & std_logic'image(cpha) & ": RX_READY should be low after reset."
                severity failure;

            assert i_tx_buffer_full = '0'
                report "CPHA=" & std_logic'image(cpha) & ": TX buffer should be empty after reset."
                severity failure;

            assert i_busy = '0'
                report "CPHA=" & std_logic'image(cpha) & ": BUSY should be low while idle."
                severity failure;

            assert i_rx_overrun = '0'
                report "CPHA=" & std_logic'image(cpha) & ": RX_OVERRUN should be cleared by reset."
                severity failure;
        end procedure p_PREPARE_IDLE;


        procedure p_WAIT_FOR_IDLE(
            constant cpha : std_logic;
            constant test_name : string;
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic
        ) is
            variable v_idle_found : boolean := false;
        begin
            for i in 1 to c_IDLE_TIMEOUT_TICKS loop
                if i_ss = '1' and i_busy = '0' then
                    v_idle_found := true;
                    exit;
                end if;

                p_tick_n(1);
            end loop;

            assert v_idle_found
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": master did not return to idle before timeout."
                severity failure;

            assert i_sck = c_CPOL
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": SCK did not return to CPOL."
                severity failure;

            assert i_tx_ready = '1'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": TX_READY should be high after returning to idle."
                severity failure;

            assert i_tx_buffer_full = '0'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": TX buffer should be empty after returning to idle."
                severity failure;
        end procedure p_WAIT_FOR_IDLE;


        procedure p_START_TX_REQUEST(
            constant cpha : std_logic;
            constant data_to_send : std_logic_vector(c_WIDTH-1 downto 0);
            constant test_name : string;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal i_tx_ready : in std_logic;
            signal i_ss : in std_logic;
            signal i_busy : in std_logic
        ) is
        begin
            assert i_tx_ready = '1'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": attempted a first TX handshake while TX_READY was low."
                severity failure;

            o_tx_data <= data_to_send;
            o_tx_valid <= '1';
            p_tick_n(1);
            o_tx_valid <= '0';
            wait for 1 ns;

            assert i_ss = '0'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": SS was not asserted after the TX_VALID/TX_READY handshake."
                severity failure;

            assert i_busy = '1'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": BUSY was not asserted after starting a transfer."
                severity failure;
        end procedure p_START_TX_REQUEST;


        procedure p_EXCHANGE_SPI_BYTE(
            constant cpha : std_logic;
            constant expected_mosi_data : std_logic_vector(c_WIDTH-1 downto 0);
            constant miso_data_to_drive : std_logic_vector(c_WIDTH-1 downto 0);
            constant test_name : string;
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal o_miso : out std_logic
        ) is
        begin
            assert i_ss = '0'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": SS must be low before exchanging a byte."
                severity failure;

            if cpha = '0' then
                -- CPHA=0 samples on the leading edge, so the first MISO bit must
                -- already be valid before the first SCK edge.
                o_miso <= miso_data_to_drive(c_WIDTH-1);
                wait for 1 ns;

                for bit_index in c_WIDTH-1 downto 0 loop
                    wait until i_sck'event and i_sck /= c_CPOL;
                    wait for 1 ns;

                    assert i_ss = '0'
                        report "CPHA=0 " & test_name &
                               ": SS was high at a sampling edge."
                        severity failure;

                    assert i_mosi = expected_mosi_data(bit_index)
                        report "CPHA=0 " & test_name &
                               ": incorrect MOSI bit at index " & integer'image(bit_index) & "."
                        severity failure;

                    if bit_index > 0 then
                        wait until i_sck'event and i_sck = c_CPOL;
                        wait for 1 ns;

                        assert i_ss = '0'
                            report "CPHA=0 " & test_name &
                                   ": SS went high before the byte completed."
                            severity failure;

                        o_miso <= miso_data_to_drive(bit_index-1);
                        wait for 1 ns;
                    end if;
                end loop;

            else
                -- CPHA=1 changes data on the leading edge and samples it on the
                -- trailing edge.
                for bit_index in c_WIDTH-1 downto 0 loop
                    wait until i_sck'event and i_sck /= c_CPOL;

                    o_miso <= miso_data_to_drive(bit_index);
                    wait for 1 ns;

                    assert i_ss = '0'
                        report "CPHA=1 " & test_name &
                               ": SS was high at a shift edge."
                        severity failure;

                    assert i_mosi = expected_mosi_data(bit_index)
                        report "CPHA=1 " & test_name &
                               ": incorrect MOSI bit at index " & integer'image(bit_index) & "."
                        severity failure;

                    wait until i_sck'event and i_sck = c_CPOL;
                    wait for 1 ns;

                    assert i_ss = '0'
                        report "CPHA=1 " & test_name &
                               ": SS went high before the byte completed."
                        severity failure;
                end loop;
            end if;
        end procedure p_EXCHANGE_SPI_BYTE;


        procedure p_EXCHANGE_SPI_BYTE_WITH_FINAL_RX_ACK(
            constant cpha : std_logic;
            constant expected_mosi_data : std_logic_vector(c_WIDTH-1 downto 0);
            constant miso_data_to_drive : std_logic_vector(c_WIDTH-1 downto 0);
            constant test_name : string;
            signal o_rx_valid : out std_logic;
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal o_miso : out std_logic
        ) is
        begin
            assert i_ss = '0'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": SS must be low before exchanging a byte."
                severity failure;

            if cpha = '0' then
                o_miso <= miso_data_to_drive(c_WIDTH-1);
                wait for 1 ns;

                for bit_index in c_WIDTH-1 downto 0 loop
                    -- Assert the consumer acknowledge before the final sampling
                    -- edge, so the old RX byte is consumed on the same system
                    -- clock that the new RX byte is completed.
                    if bit_index = 0 then
                        -- Wait until the final system clock before the sampling
                        -- edge. Holding the acknowledge high for the whole SCK
                        -- half-period would consume the old byte too early.
                        p_tick_n(c_HALF_SCK_CYCLES - 1);
                        o_rx_valid <= '1';
                        wait for 1 ns;
                    end if;

                    wait until i_sck'event and i_sck /= c_CPOL;
                    wait for 1 ns;

                    assert i_mosi = expected_mosi_data(bit_index)
                        report "CPHA=0 " & test_name &
                               ": incorrect MOSI bit at index " & integer'image(bit_index) & "."
                        severity failure;

                    if bit_index = 0 then
                        o_rx_valid <= '0';
                        wait for 1 ns;
                    else
                        wait until i_sck'event and i_sck = c_CPOL;
                        wait for 1 ns;
                        o_miso <= miso_data_to_drive(bit_index-1);
                        wait for 1 ns;
                    end if;
                end loop;

            else
                for bit_index in c_WIDTH-1 downto 0 loop
                    wait until i_sck'event and i_sck /= c_CPOL;
                    o_miso <= miso_data_to_drive(bit_index);

                    wait for 1 ns;

                    assert i_mosi = expected_mosi_data(bit_index)
                        report "CPHA=1 " & test_name &
                               ": incorrect MOSI bit at index " & integer'image(bit_index) & "."
                        severity failure;

                    if bit_index = 0 then
                        -- The trailing edge is the CPHA=1 sampling edge. Raise
                        -- the acknowledge only for the system clock containing
                        -- that edge.
                        p_tick_n(c_HALF_SCK_CYCLES - 1);
                        o_rx_valid <= '1';
                        wait for 1 ns;
                    end if;

                    wait until i_sck'event and i_sck = c_CPOL;
                    wait for 1 ns;

                    if bit_index = 0 then
                        o_rx_valid <= '0';
                        wait for 1 ns;
                    end if;
                end loop;
            end if;
        end procedure p_EXCHANGE_SPI_BYTE_WITH_FINAL_RX_ACK;


        procedure p_CHECK_RX_AND_ACKNOWLEDGE(
            constant cpha : std_logic;
            constant expected_rx_data : std_logic_vector(c_WIDTH-1 downto 0);
            constant test_name : string;
            signal o_rx_valid : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_rx_ready : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
        begin
            assert i_rx_ready = '1'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": RX_READY was not asserted after receiving a byte."
                severity failure;

            assert i_rx_data = expected_rx_data
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": RX_DATA does not match the byte driven on MISO."
                severity failure;

            assert i_rx_overrun = '0'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": RX_OVERRUN asserted unexpectedly."
                severity failure;

            -- In the current RTL naming, i_rx_valid acts as the consumer's
            -- acknowledge/ready input for the byte indicated by o_rx_ready.
            o_rx_valid <= '1';
            p_tick_n(1);
            o_rx_valid <= '0';
            wait for 1 ns;

            assert i_rx_ready = '0'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": RX_READY did not clear after the receive acknowledge."
                severity failure;

            assert i_rx_overrun = '0'
                report "CPHA=" & std_logic'image(cpha) & " " & test_name &
                       ": RX_OVERRUN should be low after a normal acknowledge."
                severity failure;
        end procedure p_CHECK_RX_AND_ACKNOWLEDGE;


        procedure p_TEST_IDLE_AND_NO_TX_VALID(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
        begin
            report "TEST: CPHA=" & std_logic'image(cpha) & " IDLE / NO TX_VALID";

            p_PREPARE_IDLE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_tick_n(2 * c_CLK_CYCLES_PER_SCK);

            assert i_ss = '1'
                report "CPHA=" & std_logic'image(cpha) &
                       " idle check: SS changed without TX_VALID."
                severity failure;

            assert i_sck = c_CPOL
                report "CPHA=" & std_logic'image(cpha) &
                       " idle check: SCK changed without TX_VALID."
                severity failure;

            assert i_tx_ready = '1'
                report "CPHA=" & std_logic'image(cpha) &
                       " idle check: TX_READY should remain high."
                severity failure;

            assert i_busy = '0'
                report "CPHA=" & std_logic'image(cpha) &
                       " idle check: BUSY changed without a transfer."
                severity failure;

            report "SUCCESS";
        end procedure p_TEST_IDLE_AND_NO_TX_VALID;


        procedure p_TEST_FULL_DUPLEX_BYTE(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
            constant c_MASTER_BYTE : std_logic_vector(c_WIDTH-1 downto 0) := x"A6";
            constant c_SLAVE_BYTE : std_logic_vector(c_WIDTH-1 downto 0) := x"3C";
        begin
            report "TEST: CPHA=" & std_logic'image(cpha) & " FULL-DUPLEX BYTE";

            p_PREPARE_IDLE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_START_TX_REQUEST(
                cpha, c_MASTER_BYTE, "full-duplex byte",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            p_EXCHANGE_SPI_BYTE(
                cpha, c_MASTER_BYTE, c_SLAVE_BYTE, "full-duplex byte",
                i_sck, i_ss, i_mosi, o_miso
            );

            p_CHECK_RX_AND_ACKNOWLEDGE(
                cpha, c_SLAVE_BYTE, "full-duplex byte",
                o_rx_valid, i_rx_data, i_rx_ready, i_rx_overrun
            );

            p_WAIT_FOR_IDLE(
                cpha, "full-duplex byte", i_sck, i_ss,
                i_tx_ready, i_tx_buffer_full, i_busy
            );

            report "SUCCESS";
        end procedure p_TEST_FULL_DUPLEX_BYTE;


        procedure p_TEST_CONTINUOUS_TWO_BYTES(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
            constant c_MASTER_BYTE_1 : std_logic_vector(c_WIDTH-1 downto 0) := x"81";
            constant c_MASTER_BYTE_2 : std_logic_vector(c_WIDTH-1 downto 0) := x"5A";
            constant c_REJECTED_BYTE : std_logic_vector(c_WIDTH-1 downto 0) := x"E7";
            constant c_SLAVE_BYTE_1 : std_logic_vector(c_WIDTH-1 downto 0) := x"24";
            constant c_SLAVE_BYTE_2 : std_logic_vector(c_WIDTH-1 downto 0) := x"C3";
        begin
            report "TEST: CPHA=" & std_logic'image(cpha) &
                   " CONTINUOUS TWO-BYTE TRANSFER / TX HANDSHAKE";

            p_PREPARE_IDLE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            -- Keep TX_VALID asserted over two adjacent system-clock edges. The
            -- first edge starts the active byte; the second fills the one-byte
            -- look-ahead buffer with a new data value.
            assert i_tx_ready = '1'
                report "Continuous transfer: TX_READY should be high before byte 1."
                severity failure;

            o_tx_data <= c_MASTER_BYTE_1;
            o_tx_valid <= '1';
            p_tick_n(1);

            assert i_ss = '0' and i_busy = '1'
                report "Continuous transfer: byte 1 was not accepted."
                severity failure;

            assert i_tx_ready = '1'
                report "Continuous transfer: TX_READY should remain high while the TX buffer is empty."
                severity failure;

            o_tx_data <= c_MASTER_BYTE_2;
            p_tick_n(1);
            o_tx_valid <= '0';
            wait for 1 ns;

            assert i_tx_buffer_full = '1'
                report "Continuous transfer: byte 2 was not stored in the TX buffer."
                severity failure;

            assert i_tx_ready = '0'
                report "Continuous transfer: TX_READY should be low while the TX buffer is full."
                severity failure;

            o_require_ss_low <= '1';
            wait for 1 ns;

            -- A one-clock TX_VALID pulse while TX_READY is low must not replace
            -- or append data. The transfer should still contain exactly two bytes.
            o_tx_data <= c_REJECTED_BYTE;
            o_tx_valid <= '1';
            p_tick_n(1);
            o_tx_valid <= '0';
            wait for 1 ns;

            assert i_tx_buffer_full = '1' and i_tx_ready = '0'
                report "Continuous transfer: a request was accepted while TX_READY was low."
                severity failure;

            p_EXCHANGE_SPI_BYTE(
                cpha, c_MASTER_BYTE_1, c_SLAVE_BYTE_1,
                "continuous transfer byte 1", i_sck, i_ss, i_mosi, o_miso
            );

            p_CHECK_RX_AND_ACKNOWLEDGE(
                cpha, c_SLAVE_BYTE_1, "continuous transfer byte 1",
                o_rx_valid, i_rx_data, i_rx_ready, i_rx_overrun
            );

            assert i_ss = '0'
                report "CPHA=" & std_logic'image(cpha) &
                       " continuous transfer: SS rose at the byte boundary."
                severity failure;

            p_EXCHANGE_SPI_BYTE(
                cpha, c_MASTER_BYTE_2, c_SLAVE_BYTE_2,
                "continuous transfer byte 2", i_sck, i_ss, i_mosi, o_miso
            );

            p_CHECK_RX_AND_ACKNOWLEDGE(
                cpha, c_SLAVE_BYTE_2, "continuous transfer byte 2",
                o_rx_valid, i_rx_data, i_rx_ready, i_rx_overrun
            );

            o_require_ss_low <= '0';
            wait for 1 ns;

            -- With the third request correctly rejected, SS must rise after only
            -- the normal final half-period. If a third byte was accepted despite
            -- TX_READY being low, SS will still be low here.
            p_tick_n(c_HALF_SCK_CYCLES + 2);

            assert i_ss = '1'
                report "CPHA=" & std_logic'image(cpha) &
                       " continuous transfer: an extra byte appears to have been accepted."
                severity failure;

            p_WAIT_FOR_IDLE(
                cpha, "continuous two-byte transfer", i_sck, i_ss,
                i_tx_ready, i_tx_buffer_full, i_busy
            );

            report "SUCCESS";
        end procedure p_TEST_CONTINUOUS_TWO_BYTES;


        procedure p_TEST_RX_OVERRUN(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
            constant c_MASTER_BYTE_1 : std_logic_vector(c_WIDTH-1 downto 0) := x"11";
            constant c_MASTER_BYTE_2 : std_logic_vector(c_WIDTH-1 downto 0) := x"22";
            constant c_SLAVE_BYTE_1 : std_logic_vector(c_WIDTH-1 downto 0) := x"6D";
            constant c_SLAVE_BYTE_2 : std_logic_vector(c_WIDTH-1 downto 0) := x"B2";
        begin
            report "TEST: CPHA=" & std_logic'image(cpha) & " RX OVERRUN";

            p_PREPARE_IDLE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_START_TX_REQUEST(
                cpha, c_MASTER_BYTE_1, "RX overrun byte 1",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            p_EXCHANGE_SPI_BYTE(
                cpha, c_MASTER_BYTE_1, c_SLAVE_BYTE_1,
                "RX overrun byte 1", i_sck, i_ss, i_mosi, o_miso
            );

            assert i_rx_ready = '1' and i_rx_data = c_SLAVE_BYTE_1
                report "RX overrun test: first unread byte was not stored correctly."
                severity failure;

            p_WAIT_FOR_IDLE(
                cpha, "RX overrun byte 1", i_sck, i_ss,
                i_tx_ready, i_tx_buffer_full, i_busy
            );

            -- Do not acknowledge byte 1. Receiving byte 2 must replace it and
            -- assert the overrun flag.
            p_START_TX_REQUEST(
                cpha, c_MASTER_BYTE_2, "RX overrun byte 2",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            p_EXCHANGE_SPI_BYTE(
                cpha, c_MASTER_BYTE_2, c_SLAVE_BYTE_2,
                "RX overrun byte 2", i_sck, i_ss, i_mosi, o_miso
            );

            assert i_rx_ready = '1'
                report "RX overrun test: RX_READY should remain high after replacement."
                severity failure;

            assert i_rx_data = c_SLAVE_BYTE_2
                report "RX overrun test: RX_DATA should contain the newest received byte."
                severity failure;

            assert i_rx_overrun = '1'
                report "RX overrun test: RX_OVERRUN was not asserted."
                severity failure;

            o_rx_valid <= '1';
            p_tick_n(1);
            o_rx_valid <= '0';
            wait for 1 ns;

            assert i_rx_ready = '0' and i_rx_overrun = '0'
                report "RX overrun test: acknowledge did not clear RX_READY and RX_OVERRUN."
                severity failure;

            p_WAIT_FOR_IDLE(
                cpha, "RX overrun byte 2", i_sck, i_ss,
                i_tx_ready, i_tx_buffer_full, i_busy
            );

            report "SUCCESS";
        end procedure p_TEST_RX_OVERRUN;


        procedure p_TEST_RESET_MID_TRANSFER(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
        begin
            report "TEST: CPHA=" & std_logic'image(cpha) & " RESET MID-TRANSFER";

            p_PREPARE_IDLE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_START_TX_REQUEST(
                cpha, x"D9", "reset mid-transfer",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            wait until i_sck'event;
            wait for 1 ns;

            assert i_ss = '0' and i_busy = '1'
                report "Reset-mid-transfer test did not reach an active transfer."
                severity failure;

            o_reset <= '1';
            p_tick_n(3);

            assert i_ss = '1'
                report "Reset-mid-transfer: SS should be high during reset."
                severity failure;

            assert i_sck = c_CPOL
                report "Reset-mid-transfer: SCK should return to CPOL during reset."
                severity failure;

            assert i_mosi = '0'
                report "Reset-mid-transfer: MOSI should reset to 0."
                severity failure;

            assert i_busy = '0'
                report "Reset-mid-transfer: BUSY should clear during reset."
                severity failure;

            assert i_tx_buffer_full = '0'
                report "Reset-mid-transfer: TX buffer should clear during reset."
                severity failure;

            assert i_rx_ready = '0'
                report "Reset-mid-transfer: RX_READY should clear during reset."
                severity failure;

            assert i_rx_data = x"00"
                report "Reset-mid-transfer: RX_DATA should clear during reset."
                severity failure;

            assert i_rx_overrun = '0'
                report "Reset-mid-transfer: RX_OVERRUN should clear during reset."
                severity failure;

            o_reset <= '0';
            p_tick_n(2);

            assert i_tx_ready = '1' and i_busy = '0' and i_ss = '1'
                report "Reset-mid-transfer: master did not recover to idle."
                severity failure;

            report "SUCCESS";
        end procedure p_TEST_RESET_MID_TRANSFER;


        procedure p_TEST_RESET_CLEARS_RX_OVERRUN(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
        begin
            report "TEST: CPHA=" & std_logic'image(cpha) &
                   " RESET CLEARS RX OVERRUN";

            p_PREPARE_IDLE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_START_TX_REQUEST(
                cpha, x"31", "reset-overrun byte 1",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            p_EXCHANGE_SPI_BYTE(
                cpha, x"31", x"A1", "reset-overrun byte 1",
                i_sck, i_ss, i_mosi, o_miso
            );

            p_WAIT_FOR_IDLE(
                cpha, "reset-overrun byte 1", i_sck, i_ss,
                i_tx_ready, i_tx_buffer_full, i_busy
            );

            -- Leave the first received byte unread, then overwrite it.
            p_START_TX_REQUEST(
                cpha, x"32", "reset-overrun byte 2",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            p_EXCHANGE_SPI_BYTE(
                cpha, x"32", x"B2", "reset-overrun byte 2",
                i_sck, i_ss, i_mosi, o_miso
            );

            assert i_rx_overrun = '1'
                report "Reset-overrun test could not create an RX overrun before reset."
                severity failure;

            o_reset <= '1';
            p_tick_n(2);

            assert i_rx_overrun = '0'
                report "CPHA=" & std_logic'image(cpha) &
                       " reset-overrun test: RX_OVERRUN was not cleared by reset."
                severity failure;

            assert i_rx_ready = '0' and i_rx_data = x"00"
                report "Reset-overrun test: receive state was not cleared by reset."
                severity failure;

            assert i_ss = '1' and i_sck = c_CPOL and i_busy = '0'
                report "Reset-overrun test: SPI outputs did not return to idle during reset."
                severity failure;

            o_reset <= '0';
            p_tick_n(2);

            report "SUCCESS";
        end procedure p_TEST_RESET_CLEARS_RX_OVERRUN;


        procedure p_TEST_SIMULTANEOUS_RX_REPLACE(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
        begin
            report "TEST: CPHA=" & std_logic'image(cpha) &
                   " SIMULTANEOUS RX CONSUME AND REPLACE";

            p_PREPARE_IDLE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_START_TX_REQUEST(
                cpha, x"41", "simultaneous RX byte 1",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            p_EXCHANGE_SPI_BYTE(
                cpha, x"41", x"19", "simultaneous RX byte 1",
                i_sck, i_ss, i_mosi, o_miso
            );

            assert i_rx_ready = '1' and i_rx_data = x"19"
                report "Simultaneous RX test: first unread byte is missing."
                severity failure;

            p_WAIT_FOR_IDLE(
                cpha, "simultaneous RX byte 1", i_sck, i_ss,
                i_tx_ready, i_tx_buffer_full, i_busy
            );

            p_START_TX_REQUEST(
                cpha, x"42", "simultaneous RX byte 2",
                o_tx_data, o_tx_valid, i_tx_ready, i_ss, i_busy
            );

            p_EXCHANGE_SPI_BYTE_WITH_FINAL_RX_ACK(
                cpha, x"42", x"A7", "simultaneous RX byte 2",
                o_rx_valid, i_sck, i_ss, i_mosi, o_miso
            );

            -- The old byte was consumed on this edge, so the new byte must be
            -- presented normally. This is not an overrun condition.
            assert i_rx_ready = '1'
                report "CPHA=" & std_logic'image(cpha) &
                       " simultaneous RX test: the new byte lost its RX_READY indication."
                severity failure;

            assert i_rx_data = x"A7"
                report "Simultaneous RX test: RX_DATA does not contain the replacement byte."
                severity failure;

            assert i_rx_overrun = '0'
                report "CPHA=" & std_logic'image(cpha) &
                       " simultaneous RX test: a legal consume-and-replace was flagged as overrun."
                severity failure;

            o_rx_valid <= '1';
            p_tick_n(1);
            o_rx_valid <= '0';
            wait for 1 ns;

            p_WAIT_FOR_IDLE(
                cpha, "simultaneous RX replacement", i_sck, i_ss,
                i_tx_ready, i_tx_buffer_full, i_busy
            );

            report "SUCCESS";
        end procedure p_TEST_SIMULTANEOUS_RX_REPLACE;


        procedure p_RUN_STANDARD_TESTS(
            constant cpha : std_logic;
            signal o_reset : out std_logic;
            signal o_tx_data : out std_logic_vector(c_WIDTH-1 downto 0);
            signal o_tx_valid : out std_logic;
            signal o_rx_valid : out std_logic;
            signal o_miso : out std_logic;
            signal o_require_ss_low : out std_logic;
            signal i_rx_data : in std_logic_vector(c_WIDTH-1 downto 0);
            signal i_sck : in std_logic;
            signal i_ss : in std_logic;
            signal i_mosi : in std_logic;
            signal i_tx_ready : in std_logic;
            signal i_rx_ready : in std_logic;
            signal i_tx_buffer_full : in std_logic;
            signal i_busy : in std_logic;
            signal i_rx_overrun : in std_logic
        ) is
        begin
            p_TEST_IDLE_AND_NO_TX_VALID(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_TEST_FULL_DUPLEX_BYTE(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_TEST_CONTINUOUS_TWO_BYTES(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_TEST_RX_OVERRUN(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );

            p_TEST_RESET_MID_TRANSFER(
                cpha, o_reset, o_tx_data, o_tx_valid, o_rx_valid, o_miso,
                o_require_ss_low, i_rx_data, i_sck, i_ss, i_mosi,
                i_tx_ready, i_rx_ready, i_tx_buffer_full, i_busy, i_rx_overrun
            );
        end procedure p_RUN_STANDARD_TESTS;

    begin
        assert c_MAIN_CLK_FREQ mod c_SPI_FREQ = 0
            report "Testbench requires an integer number of main clocks per SCK period."
            severity failure;

        assert c_CLK_CYCLES_PER_SCK mod 2 = 0
            report "Testbench requires an even number of main clocks per SCK period."
            severity failure;

        assert c_HALF_SCK_CYCLES >= 4
            report "Use at least four main-clock cycles per SCK half-period for these procedures."
            severity failure;

        -- Run the complete required suite on both instantiated CPHA modes.
        p_RUN_STANDARD_TESTS(
            '0', r_RESET_CPHA0, r_TX_DATA_CPHA0, r_TX_VALID_CPHA0,
            r_RX_VALID_CPHA0, r_MISO_CPHA0, r_REQUIRE_SS_LOW_CPHA0,
            r_RX_DATA_CPHA0, r_SCK_CPHA0, r_SS_CPHA0, r_MOSI_CPHA0,
            r_TX_READY_CPHA0, r_RX_READY_CPHA0, r_TX_BUFFER_FULL_CPHA0,
            r_BUSY_CPHA0, r_RX_OVERRUN_CPHA0
        );

        p_RUN_STANDARD_TESTS(
            '1', r_RESET_CPHA1, r_TX_DATA_CPHA1, r_TX_VALID_CPHA1,
            r_RX_VALID_CPHA1, r_MISO_CPHA1, r_REQUIRE_SS_LOW_CPHA1,
            r_RX_DATA_CPHA1, r_SCK_CPHA1, r_SS_CPHA1, r_MOSI_CPHA1,
            r_TX_READY_CPHA1, r_RX_READY_CPHA1, r_TX_BUFFER_FULL_CPHA1,
            r_BUSY_CPHA1, r_RX_OVERRUN_CPHA1
        );

        -- These are intentionally placed after both CPHA suites. The current
        -- RTL does not assign r_rx_overrun in its reset branch, so this test is
        -- expected to fail until that reset omission is fixed.
        p_TEST_RESET_CLEARS_RX_OVERRUN(
            '0', r_RESET_CPHA0, r_TX_DATA_CPHA0, r_TX_VALID_CPHA0,
            r_RX_VALID_CPHA0, r_MISO_CPHA0, r_REQUIRE_SS_LOW_CPHA0,
            r_RX_DATA_CPHA0, r_SCK_CPHA0, r_SS_CPHA0, r_MOSI_CPHA0,
            r_TX_READY_CPHA0, r_RX_READY_CPHA0, r_TX_BUFFER_FULL_CPHA0,
            r_BUSY_CPHA0, r_RX_OVERRUN_CPHA0
        );

        p_TEST_RESET_CLEARS_RX_OVERRUN(
            '1', r_RESET_CPHA1, r_TX_DATA_CPHA1, r_TX_VALID_CPHA1,
            r_RX_VALID_CPHA1, r_MISO_CPHA1, r_REQUIRE_SS_LOW_CPHA1,
            r_RX_DATA_CPHA1, r_SCK_CPHA1, r_SS_CPHA1, r_MOSI_CPHA1,
            r_TX_READY_CPHA1, r_RX_READY_CPHA1, r_TX_BUFFER_FULL_CPHA1,
            r_BUSY_CPHA1, r_RX_OVERRUN_CPHA1
        );

        -- Once the reset omission above is fixed, these tests exercise the
        -- receive handshake race where the old byte is consumed on the same
        -- clock that the next byte is completed.
        p_TEST_SIMULTANEOUS_RX_REPLACE(
            '0', r_RESET_CPHA0, r_TX_DATA_CPHA0, r_TX_VALID_CPHA0,
            r_RX_VALID_CPHA0, r_MISO_CPHA0, r_REQUIRE_SS_LOW_CPHA0,
            r_RX_DATA_CPHA0, r_SCK_CPHA0, r_SS_CPHA0, r_MOSI_CPHA0,
            r_TX_READY_CPHA0, r_RX_READY_CPHA0, r_TX_BUFFER_FULL_CPHA0,
            r_BUSY_CPHA0, r_RX_OVERRUN_CPHA0
        );

        p_TEST_SIMULTANEOUS_RX_REPLACE(
            '1', r_RESET_CPHA1, r_TX_DATA_CPHA1, r_TX_VALID_CPHA1,
            r_RX_VALID_CPHA1, r_MISO_CPHA1, r_REQUIRE_SS_LOW_CPHA1,
            r_RX_DATA_CPHA1, r_SCK_CPHA1, r_SS_CPHA1, r_MOSI_CPHA1,
            r_TX_READY_CPHA1, r_RX_READY_CPHA1, r_TX_BUFFER_FULL_CPHA1,
            r_BUSY_CPHA1, r_RX_OVERRUN_CPHA1
        );

        assert false report "ALL TESTS PASSED" severity failure;
    end process p_TEST_BENCH;

end Behavioral;
