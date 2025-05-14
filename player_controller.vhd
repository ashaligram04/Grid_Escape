LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY player_controller IS
    PORT (
        clk                 : IN  STD_LOGIC;
        btnl                : IN  STD_LOGIC;
        btnr                : IN  STD_LOGIC;
        btnu                : IN  STD_LOGIC;
        btnd                : IN  STD_LOGIC;
        test_tile_val_h1    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        test_tile_val_h2    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        test_tile_val_v1    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        test_tile_val_v2    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        reset_player_1      : IN STD_LOGIC;
        reset_player_2      : IN STD_LOGIC;
        player_x            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        player_y            : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        test_tile_x_h1      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        test_tile_y_h1      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        test_tile_x_h2      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        test_tile_y_h2      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        test_tile_x_v1      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        test_tile_y_v1      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        test_tile_x_v2      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        test_tile_y_v2      : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
    );
END player_controller;

ARCHITECTURE Behavioral OF player_controller IS
    SIGNAL x_pos : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(212, 10));
    SIGNAL y_pos : STD_LOGIC_VECTOR(9 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(416, 10));
    SIGNAL move_counter : INTEGER RANGE 0 TO 999999 := 0;
    SIGNAL move_tick    : STD_LOGIC := '0';

    SIGNAL next_x_h, next_y_h : UNSIGNED(9 DOWNTO 0);
    SIGNAL next_x_v, next_y_v : UNSIGNED(9 DOWNTO 0);

    SIGNAL offset_h : STD_LOGIC := '0';
    SIGNAL offset_v : STD_LOGIC := '0';
    
    SIGNAL jumping : STD_LOGIC := '0';
    SIGNAL ground  : STD_LOGIC := '0';
    SIGNAL jumpcount : UNSIGNED(6 DOWNTO 0) := to_unsigned(45, 7);
    
BEGIN

    -- Movement tick generator
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF move_counter = 199999 THEN
                move_counter <= 0;
                move_tick <= '1';
            ELSE
                move_counter <= move_counter + 1;
                move_tick <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Predictive tile positions and movement logic
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF btnd = '1' THEN
                next_x_h <= to_unsigned(212, 10);
                next_y_h <= to_unsigned(416, 10);
                next_x_v <= to_unsigned(212, 10);
                next_y_v <= to_unsigned(416, 10);
            ELSIF move_tick = '1' THEN
                -- Horizontal movement
                IF btnl = '1' AND UNSIGNED(x_pos) > 0 THEN
                    next_x_h <= UNSIGNED(x_pos) - 1;
                    offset_h <= '0';
                ELSIF btnr = '1' AND UNSIGNED(x_pos) < 788 THEN
                    next_x_h <= UNSIGNED(x_pos) + 12;
                    offset_h <= '1';
                ELSE
                    next_x_h <= UNSIGNED(x_pos);
                    offset_h <= '0';
                END IF;
                next_y_h <= UNSIGNED(y_pos);
                
                IF NOT (test_tile_val_v1 = "000") OR NOT (test_tile_val_v2 = "000") THEN
                    IF offset_v = '1' THEN
                            ground <= '1';
                    END IF;
                END IF;
                
                -- Vertical movement
                IF btnu = '1' AND UNSIGNED(y_pos) > 0 AND jumping = '0' AND ground = '1' THEN
                    next_y_v <= UNSIGNED(y_pos) - 1;
                    offset_v <= '0';
                    jumping <= '1';
                    ground <= '0';
                ELSIF jumping = '1' THEN
                    next_y_v <= UNSIGNED(y_pos) - 1;
                    offset_v <= '0';
                    jumpcount <= jumpcount - 1;
                    IF jumpcount = 0 THEN
                        jumping <= '0';
                        jumpcount <= to_unsigned(45, 7);
                    END IF;
                ELSIF UNSIGNED(y_pos) < 588 THEN
                    next_y_v <= UNSIGNED(y_pos) + 12;
                    offset_v <= '1';
                    IF test_tile_val_v1 = "000" AND (test_tile_val_v2 = "000") then
                        ground <= '0';
                    END IF;
                ELSE
                    next_y_v <= UNSIGNED(y_pos);
                    offset_v <= '0';
                END IF;
                next_x_v <= UNSIGNED(x_pos);
            END IF;
        END IF;
    END PROCESS;

    -- Movement execution
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset_player_1 = '1' OR reset_player_2 = '1' OR test_tile_val_h1 = "010" OR test_tile_val_h2 = "010" OR test_tile_val_v1 = "010" OR test_tile_val_v2 = "010" THEN
                x_pos <= STD_LOGIC_VECTOR(to_unsigned(212, 10));
                y_pos <= STD_LOGIC_VECTOR(to_unsigned(416, 10));
            ELSIF move_tick = '1' THEN
                IF test_tile_val_h1 = "000" AND test_tile_val_h2 = "000" THEN
                    IF offset_h = '0' THEN
                        x_pos <= STD_LOGIC_VECTOR(next_x_h);
                    ELSE
                        x_pos <= STD_LOGIC_VECTOR(next_x_h - 11);
                    END IF;
                END IF;

                IF test_tile_val_v1 = "000" AND test_tile_val_v2 = "000" THEN
                    IF offset_v = '0' THEN
                        y_pos <= STD_LOGIC_VECTOR(next_y_v);
                    ELSE
                        y_pos <= STD_LOGIC_VECTOR(next_y_v - 11);
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    -- Position outputs
    player_x <= x_pos;
    player_y <= y_pos;

    -- Tile lookups for corners
    test_tile_x_h1 <= STD_LOGIC_VECTOR(next_x_h(9 DOWNTO 4));
    test_tile_y_h1 <= STD_LOGIC_VECTOR(next_y_h(9 DOWNTO 4));
    test_tile_x_h2 <= STD_LOGIC_VECTOR(next_x_h(9 DOWNTO 4));
    test_tile_y_h2 <= STD_LOGIC_VECTOR(to_unsigned(to_integer(next_y_h) + 11, 10)(9 DOWNTO 4));


    test_tile_x_v1 <= STD_LOGIC_VECTOR(next_x_v(9 DOWNTO 4));
    test_tile_y_v1 <= STD_LOGIC_VECTOR(next_y_v(9 DOWNTO 4));
    test_tile_x_v2 <= STD_LOGIC_VECTOR(to_unsigned(to_integer(next_x_v) + 11, 10)(9 DOWNTO 4));
    test_tile_y_v2 <= STD_LOGIC_VECTOR(next_y_v(9 DOWNTO 4));
END Behavioral;
