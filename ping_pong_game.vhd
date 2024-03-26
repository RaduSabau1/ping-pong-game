----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2023 02:38:07 AM
-- Design Name: 
-- Module Name: ping_pong_game - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity ping_pong_game is
    Port (
        btnL    : in  std_logic;
        btnR    : in  std_logic;
        LEDs    : out std_logic_vector(15 downto 0);
        clk     : in  std_logic;
        rst     : in  std_logic
    );
end ping_pong_game;

architecture Behavioral of ping_pong_game is
    -- Constants
    constant CLK_FREQ             : integer := 50_000_000; -- 50 MHz
    constant INITIAL_LED_DELAY    : integer := 10_000_000; -- 10 secunde
    constant MIN_LED_DELAY        : integer := 100_000;    -- 100 millisecunde
    constant SCORE_LIMIT          : integer := 99;
    -- Signals
    signal counter                : integer range 0 to 15 := 0;
    signal score_user1            : integer range 0 to SCORE_LIMIT := 0;
    signal score_user2            : integer range 0 to SCORE_LIMIT := 0;
    signal LED_direction          : std_logic := '1';
    signal LED_delay_counter      : integer range 0 to CLK_FREQ := INITIAL_LED_DELAY;
    signal LED_counter            : integer range 0 to 15 := 0;
    signal LED_sequence           : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then -- Reset the game
            counter <= 0;
            score_user1 <= 0;
            score_user2 <= 0;
            LED_direction <= '1';
            LED_delay_counter <= INITIAL_LED_DELAY;
            LED_counter <= 0;
            LED_sequence <= (others => '0');
            LEDs <= "1111111111111110"; -- LED15 is on
        elsif rising_edge(clk) then
            if btnL = '1' then -- Serve button
                counter <= 15;
                LED_sequence <= (others => '0');
                for i in 0 to 15 loop
                    if counter = i then
                        LED_sequence(i) <= '1';
                    end if;
                end loop;
                LEDs <= LED_sequence;
                LED_direction <= '1';
                LED_counter <= 0;
                LED_delay_counter <= INITIAL_LED_DELAY;
            elsif btnR = '1' then -- Catch button
                if LED_sequence(0) = '1' then
                    LED_direction <= not LED_direction;
                    LED_sequence <= (others => '0');
                    for i in 0 to 15 loop
                        if LED_direction = '1' then
                            if LED_counter = i then
                                LED_sequence(i) <= '1';
                            end if;
                        else
                            if LED_counter = 15 - i then
                                LED_sequence(i) <= '1';
                            end if;
                        end if;
                    end loop;
                    LEDs <= LED_sequence;
                    LED_counter <= 0;
                    LED_delay_counter <= INITIAL_LED_DELAY;
                end if;
           end if;
           if btnR = '0' or btnL = '0' then
                if LED_delay_counter = 0 then
                    if LED_direction = '1' then
                        if LED_counter = 15 then -- LED15 is caught
                            score_user2 <= score_user2 + 1;
                            LEDs <= (others => '1'); -- All LEDs on
                            LED_sequence <= (others => '0');
                            LED_sequence(15) <= '1'; -- LED15 is on
                            LED_direction <= '1';
                            LED_counter <= 0;
                            LED_delay_counter <= INITIAL_LED_DELAY;
                        else
                            LED_counter <= LED_counter + 1;
                            if LED_counter = 15 then
                                if LED_delay_counter > MIN_LED_DELAY then
                                    LED_delay_counter <= LED_delay_counter - MIN_LED_DELAY;
                                end if;
                                if LED_delay_counter <= MIN_LED_DELAY then
                                    LED_delay_counter <= MIN_LED_DELAY;
                                end if;
                            end if;
                            LED_sequence <= ('0' & LED_sequence(15 downto 1));
                            LEDs <= LED_sequence;
                        end if;
                    else
                        if LED_counter = 0 then -- LED0 is caught
                            score_user1 <= score_user1 + 1;
                            LEDs <= (others => '1'); -- All LEDs on
                            LED_sequence <= (others => '0');
                            LED_sequence(0) <= '1'; -- LED0 is on
                            LED_direction <= '0';
                            LED_counter <= 0;
                            LED_delay_counter <= INITIAL_LED_DELAY;
                        else
                            LED_counter <= LED_counter - 1;
                            if LED_counter = 0 then
                                if LED_delay_counter > MIN_LED_DELAY then
                                    LED_delay_counter <= LED_delay_counter - MIN_LED_DELAY;
                                end if;
                                if LED_delay_counter <= MIN_LED_DELAY then
                                    LED_delay_counter <= MIN_LED_DELAY;
                                end if;
                            end if;
                            LED_sequence <= (LED_sequence(14 downto 0) & '0');
                            LEDs <= LED_sequence;
                        end if;
                    end if;
                else
                    LED_delay_counter <= LED_delay_counter - 1;
                end if;
            end if;
            -- Update the score LEDs
            LEDs(15 downto 12) <= std_logic_vector(to_unsigned(score_user1, 4));
            LEDs(11 downto 8) <= std_logic_vector(to_unsigned(score_user2, 4));
            -- Check if the game is over
            if score_user1 = SCORE_LIMIT or score_user2 = SCORE_LIMIT then
                score_user1 <= 0;
                score_user2 <= 0;
                LED_sequence <= (others => '0');
                LED_sequence(15) <= '1'; -- LED15 is on
                LED_direction <= '1';
                LED_counter <= 0;
                LED_delay_counter <= INITIAL_LED_DELAY;
                LEDs <= "1111111111111110"; -- LED15 is on
            end if;
      end if;
      
end process; -- Move the LEDs
            
end Behavioral;


