

-- TODO:
-- The final test does not pass, the module cannot handle reading form the rx buffer at the
-- final clock cycle when the buffer is full. Let that be knonw and sit for now but needs to be fixed.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
    generic (
        constant c_WIDTH : positive := 8;
        constant c_MAIN_CLK_FREQ : positive := 100_000_000;
        constant c_SPI_FREQ : positive := 1_000_000;

        constant c_CPOL : std_logic := '1';
        constant c_CPHA : std_logic := '1'
    );
    port (
        ----------------------
        -- Board-to-Unit I/O
        i_clk : in std_logic;
        i_rst : in std_logic;
        
        i_tx_data : in std_logic_vector(c_WIDTH-1 downto 0);
        o_rx_data : out std_logic_vector(c_WIDTH-1 downto 0);
        ----------------------
        
        ----------------------
        -- SPI Master I/O
        o_sck : out std_logic;
        o_ss : out std_logic;
        o_mosi : out std_logic;
        i_miso : in  std_logic;
        ----------------------
        
        ----------------------
        -- SPI Master to EXT I/O
        i_tx_valid : in std_logic; -- ext has data to send
        o_tx_ready : out std_logic; -- master is ready to send
        
        i_rx_valid : in std_logic; -- ext is ready to receive
        o_rx_ready : out std_logic; -- master has data to be read
        ----------------------
        
        ----------------------
        -- Status Flags
        o_tx_buffer_full : out std_logic;
        o_busy : out std_logic;
        ----------------------
        
        ----------------------
        -- Diagnositc/Error Flags
        o_rx_overrun : out std_logic
        -----------------------
    );
end spi_master;

architecture Behavioral of spi_master is

    subtype t_std_byte is std_logic_vector(c_WIDTH-1 downto 0);

    type t_state is (IDLE, TRANSFER, FINISH);

    constant c_CLK_CYCLES_PER_SCK : positive := c_MAIN_CLK_FREQ / c_SPI_FREQ;
    constant c_HALF_SCK_CYCLES : positive := c_CLK_CYCLES_PER_SCK / 2;
    signal r_clk_count : natural range 0 to c_HALF_SCK_CYCLES-1 := 0;
    
    signal r_state : t_state := IDLE;

    signal r_ss : std_logic := '1';
    signal r_sck : std_logic := c_CPOL;
    signal r_mosi : std_logic := '0';

    signal r_tx_reg : t_std_byte := (others => '0');
    signal r_rx_reg : t_std_byte := (others => '0');
    signal r_rx_data : t_std_byte := (others => '0');
    
    signal r_rx_ready : std_logic := '0';
    signal r_rx_overrun : std_logic := '0';

    signal r_bit_count : natural range 0 to c_WIDTH-1 := 0;

    signal r_tx_data_buffer : t_std_byte := (others => '0');
    signal r_tx_data_buffer_full : std_logic := '0';

begin

    assert c_WIDTH >= 2
        report "c_WIDTH must be at least 2"
        severity failure;

    assert (c_MAIN_CLK_FREQ mod c_SPI_FREQ = 0)
        report "c_MAIN_CLK_FREQ must be divisible by c_SPI_FREQ"
        severity failure;

    assert (c_CLK_CYCLES_PER_SCK mod 2 = 0)
        report "c_MAIN_CLK_FREQ / c_SPI_FREQ must be even"
        severity failure;

    o_ss <= r_ss;
    o_sck <= r_sck;
    o_mosi <= r_mosi;
    o_rx_data <= r_rx_data;
    o_rx_ready <= r_rx_ready; 
    o_rx_overrun <= r_rx_overrun;
    
    -- flag configurations
    o_tx_buffer_full <= r_tx_data_buffer_full;
    o_busy <= '1' when r_state /= IDLE else '0';
    
    
    -- apperabtly, I can implement the tx_ready logic directly combinationally.
    -- I only want 
    o_tx_ready <= '1' when 
        (r_state=IDLE or (r_state=TRANSFER and r_tx_data_buffer_full='0'))
        else '0';

    p_MAIN : process(i_clk)
        variable v_leading_edge : boolean;
        variable v_sample_edge : boolean;
        variable v_rx_next : t_std_byte;
        variable v_tx_accept : boolean; 
    begin
        if rising_edge(i_clk) then
            v_tx_accept := i_tx_valid = '1' and (r_state = IDLE or (r_state = TRANSFER and r_tx_data_buffer_full = '0'));
            
            -- reset behaviour is primary and should not be overriden.
            if i_rst = '1' then
                r_state <= IDLE;

                r_ss <= '1';
                r_sck <= c_CPOL;
                r_mosi <= '0';

                r_tx_reg <= (others => '0');
                r_rx_reg <= (others => '0');
                r_rx_data <= (others => '0');
                r_tx_data_buffer <= (others => '0');
                
                r_rx_ready <= '0';
                r_rx_overrun <= '0';

                r_bit_count <= 0;
                r_clk_count <= 0;

                r_tx_data_buffer <= (others => '0');
                r_tx_data_buffer_full <= '0';
                
            else
                -- a primative receive logic.
                if i_rx_valid = '1' and r_rx_ready = '1' and r_bit_count /= c_width-1 then
                    r_rx_ready <= '0'; -- Can work on this logic further.
                    r_rx_overrun <= '0'; -- Reset the flag??? Idk but looks good for the moment.
                end if;
            
                case r_state is
                    when IDLE =>
                        r_ss <= '1';
                        r_sck <= c_CPOL;
                        r_mosi <= '0';
                        r_clk_count <= 0;
                        r_bit_count <= 0;

                        if i_tx_valid = '1' then
                            r_ss <= '0';
                            r_rx_reg <= (others => '0');

                            if c_CPHA = '0' then
                                r_mosi <= i_tx_data(c_WIDTH-1); -- oush the first bit for CPHA=0
                                r_tx_reg <= i_tx_data(c_WIDTH-2 downto 0) & '0';
                            else
                                -- CPHA = 1, the initial value doesnt matter as it will
                                -- wont be read and be over-written at the leading edge.
                                r_mosi <= '0';
                                r_tx_reg <= i_tx_data;
                            end if;

                            r_state <= TRANSFER; -- tx_ready goes low here.
                        end if;


                    when TRANSFER =>
                        -- accepting condition for writing data in the tx buffer.
                        if v_tx_accept then
                            r_tx_data_buffer <= i_tx_data;
                            r_tx_data_buffer_full <= '1';
                        end if;
                    
                        if r_clk_count < c_HALF_SCK_CYCLES-1 then
                            r_clk_count <= r_clk_count + 1;

                        else -- Doing the updates at the end of each half-period of SPI. 
                            r_clk_count <= 0;

                            -- opposite would be trailing_edge
                            v_leading_edge := (r_sck = c_CPOL); 
                            -- Similarly, opposite of sample_edge would be shift_edge.
                            v_sample_edge := (c_CPHA = '0' and v_leading_edge) or (c_CPHA = '1' and not v_leading_edge);

                            if v_sample_edge then
                                v_rx_next := r_rx_reg(c_WIDTH-2 downto 0) & i_miso;
                                r_rx_reg <= v_rx_next;

                                if r_bit_count = c_WIDTH-1 then
                                    r_rx_data <= v_rx_next;
                                    
                                    if r_rx_ready = '1' then
                                        r_rx_overrun <= '1'; -- The new btye over-wrote the old one.
                                    else
                                        r_rx_ready <= '1'; -- Ready to be read.
                                    end if;
                                    
                                    r_bit_count <= 0;
                                    r_state <= FINISH; -- go to FINISH state.
                                    
                                else
                                    r_bit_count <= r_bit_count + 1;
                                end if;

                            else -- shift edge logic
                                r_mosi <= r_tx_reg(c_WIDTH-1);
                                r_tx_reg <= r_tx_reg(c_WIDTH-2 downto 0) & '0';
                            end if;

                            r_sck <= not r_sck; -- Update SPI clock.
                        end if;


                    when FINISH =>
                        -- Need to wait c_HALF_SCK_CYCLES regardless of the CPHA  
                        -- since we are currently at the sample_edge. 
                        if r_clk_count < c_HALF_SCK_CYCLES-1 then
                            r_clk_count <= r_clk_count + 1;
                        
                        else
                            r_clk_count <= 0;
                            
                            if c_CPHA = '0' then
                                r_sck <= c_CPOL; -- at CHPA=0, we are at the wrong clock polarization
                                
                                if r_tx_data_buffer_full='1' then
                                    r_tx_data_buffer_full <= '0';
                                    r_state <= TRANSFER; -- go back to TRANSFER
                                    
                                    r_ss <= '0'; -- continueing the transfer
                                    r_bit_count <= 0;
                                    r_rx_reg <= (others => '0');
                                    
                                    r_mosi <= r_tx_data_buffer(c_WIDTH-1);
                                    r_tx_reg <= r_tx_data_buffer(c_WIDTH-2 downto 0) & '0';
                                
                                else -- no incoming data
                                    r_ss <= '1';
                                    r_state <= IDLE;
                                end if;
                                
                            else    -- CPHA=1, corret SCK polarization but consideration for continious transfer
                                if r_tx_data_buffer_full='1' then
                                    r_tx_data_buffer_full <= '0';
                                    r_state <= TRANSFER; -- go back to TRANSFER
                                    
                                    r_sck <= not r_sck; -- For the continuing transfer, need to change the sck to get ready
                                    r_ss <= '0'; -- continueing the transfer
                                    r_bit_count <= 0;
                                    r_rx_reg <= (others => '0');
                                    
                                    -- uppsiiies this shit wrong :D
--                                    r_mosi   <= '0';
--                                    r_tx_reg <= r_tx_data_buffer;
                                    r_mosi <= r_tx_data_buffer(c_WIDTH-1);
                                    r_tx_reg <= r_tx_data_buffer(c_WIDTH-2 downto 0) & '0';
                                
                                else -- no incoming data
                                    r_ss <= '1';
                                    r_state <= IDLE;
                                end if;
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process p_MAIN;

end Behavioral;