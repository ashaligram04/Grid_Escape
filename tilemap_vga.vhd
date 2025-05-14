LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tilemap_vga IS
    PORT (
        clk         : IN  STD_LOGIC;
        pixel_row   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        btnl        : IN STD_LOGIC;
        btnr        : IN STD_LOGIC;
        btnu        : IN STD_LOGIC;
        btnd        : IN STD_LOGIC;
        btnc        : IN STD_LOGIC;
        red         : OUT STD_LOGIC;
        green       : OUT STD_LOGIC;
        blue        : OUT STD_LOGIC;
        counter     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        new_last_score : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END tilemap_vga;

ARCHITECTURE Behavioral OF tilemap_vga IS

    CONSTANT TILE_SIZE : INTEGER := 16;
    CONSTANT TILE_BITS : INTEGER := 6;

    SIGNAL render_tile_X, render_tile_Y : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL render_tile_num : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL world_X, world_Y : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL origin_X, origin_Y : STD_LOGIC_VECTOR(8 DOWNTO 0);

    SIGNAL player_x, player_y : STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    -- Collision check tiles
    SIGNAL test_tile_x_h1, test_tile_y_h1 : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL test_tile_val_h1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL test_tile_x_h2, test_tile_y_h2 : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL test_tile_val_h2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL test_tile_x_v1, test_tile_y_v1 : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL test_tile_val_v1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL test_tile_x_v2, test_tile_y_v2 : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL test_tile_val_v2 : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL tile_red, tile_green, tile_blue : STD_LOGIC;
    SIGNAL player_red, player_green, player_blue : STD_LOGIC;
    SIGNAL draw_player : STD_LOGIC := '0';
    
    signal enemy_x_1, enemy_y_1 : STD_LOGIC_VECTOR(9 downto 0);
    signal enemy_x_int_1    : UNSIGNED(9 downto 0) := to_unsigned(400, 10);
    signal enemy_y_int_1    : UNSIGNED(9 downto 0) := to_unsigned(225, 10);
    signal enemy_alive_1    : STD_LOGIC := '1';
    signal enemy_dir_1      : STD_LOGIC := '1';  -- '1' right, '0' left
    signal move_counter_1   : unsigned(23 downto 0) := (others => '0');
    signal hit_player_1   : STD_LOGIC;
    signal draw_enemy_1   : std_logic;
    signal enemy_red_1    : std_logic;
    signal enemy_green_1  : std_logic;
    signal enemy_blue_1   : std_logic;
    
    signal enemy_x_2, enemy_y_2 : STD_LOGIC_VECTOR(9 downto 0);
    signal enemy_x_int_2    : UNSIGNED(9 downto 0) := to_unsigned(350, 10);
    signal enemy_y_int_2    : UNSIGNED(9 downto 0) := to_unsigned(289, 10);
    signal enemy_alive_2    : STD_LOGIC := '1';
    signal enemy_dir_2      : STD_LOGIC := '1';  -- '1' right, '0' left
    signal move_counter_2   : unsigned(23 downto 0) := (others => '0');
    signal hit_player_2   : STD_LOGIC;
    signal draw_enemy_2   : std_logic;
    signal enemy_red_2    : std_logic;
    signal enemy_green_2  : std_logic;
    signal enemy_blue_2   : std_logic;
    
    SIGNAL clock_scaler : INTEGER RANGE 0 TO 999999999 := 0;
    SIGNAL count        : UNSIGNED(15 DOWNTO 0) := (others => '0');
    
    SIGNAL last_score : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '1');
    
    COMPONENT map_rom
        PORT (
            clock   : IN  STD_LOGIC;
            tile_X  : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
            tile_Y  : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
            data    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT draw_map
        PORT (
            world_X, world_Y   : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            origin_X, origin_Y : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            tile_num           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            red, green, blue   : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT player_controller
        PORT (
            clk               : IN  STD_LOGIC;
            btnl              : IN  STD_LOGIC;
            btnr              : IN  STD_LOGIC;
            btnu              : IN  STD_LOGIC;
            btnd              : IN  STD_LOGIC;
            test_tile_val_h1  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            test_tile_val_h2  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            test_tile_val_v1  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            test_tile_val_v2  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            reset_player_1    : IN STD_LOGIC;
            reset_player_2    : IN STD_LOGIC;
            player_x          : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            player_y          : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            test_tile_x_h1    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            test_tile_y_h1    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            test_tile_x_h2    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            test_tile_y_h2    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            test_tile_x_v1    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            test_tile_y_v1    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            test_tile_x_v2    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            test_tile_y_v2    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    -- Pixel-to-tile index
    render_tile_X <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(pixel_col)) / TILE_SIZE, TILE_BITS));
    render_tile_Y <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(pixel_row)) / TILE_SIZE, TILE_BITS));

    world_X <= pixel_col(8 DOWNTO 0);
    world_Y <= pixel_row(8 DOWNTO 0);
    origin_X <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(render_tile_X)) * TILE_SIZE, 9));
    origin_Y <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(render_tile_Y)) * TILE_SIZE, 9));

    -- Visible tile ROM
    rom_render : map_rom
        PORT MAP (
            clock   => clk,
            tile_X  => render_tile_X,
            tile_Y  => render_tile_Y,
            data    => render_tile_num
        );

    -- Collision ROM lookups
    rom_h1 : map_rom PORT MAP (clock => clk, tile_X => test_tile_x_h1, tile_Y => test_tile_y_h1, data => test_tile_val_h1);
    rom_h2 : map_rom PORT MAP (clock => clk, tile_X => test_tile_x_h2, tile_Y => test_tile_y_h2, data => test_tile_val_h2);
    rom_v1 : map_rom PORT MAP (clock => clk, tile_X => test_tile_x_v1, tile_Y => test_tile_y_v1, data => test_tile_val_v1);
    rom_v2 : map_rom PORT MAP (clock => clk, tile_X => test_tile_x_v2, tile_Y => test_tile_y_v2, data => test_tile_val_v2);

    -- Tile rendering
    draw_inst : draw_map
        PORT MAP (
            world_X  => world_X,
            world_Y  => world_Y,
            origin_X => origin_X,
            origin_Y => origin_Y,
            tile_num => render_tile_num,
            red      => tile_red,
            green    => tile_green,
            blue     => tile_blue
        );

    -- Player control
    player_ctl : player_controller
        PORT MAP (
            clk               => clk,
            btnl              => btnl,
            btnr              => btnr,
            btnu              => btnu,
            btnd              => btnd,
            test_tile_val_h1  => test_tile_val_h1,
            test_tile_val_h2  => test_tile_val_h2,
            test_tile_val_v1  => test_tile_val_v1,
            test_tile_val_v2  => test_tile_val_v2,
            player_x          => player_x,
            player_y          => player_y,
            reset_player_1    => hit_player_1,
            reset_player_2    => hit_player_2,
            test_tile_x_h1    => test_tile_x_h1,
            test_tile_y_h1    => test_tile_y_h1,
            test_tile_x_h2    => test_tile_x_h2,
            test_tile_y_h2    => test_tile_y_h2,
            test_tile_x_v1    => test_tile_x_v1,
            test_tile_y_v1    => test_tile_y_v1,
            test_tile_x_v2    => test_tile_x_v2,
            test_tile_y_v2    => test_tile_y_v2
        );
    
    -- Game Time Counter
    PROCESS(clk)
    begin
        IF rising_edge(clk) THEN 
            IF btnd = '1' OR test_tile_val_h1 = "010" OR test_tile_val_h2 = "010" OR test_tile_val_v1 = "010" OR test_tile_val_v2 = "010" THEN
                IF test_tile_val_h1 = "010" OR test_tile_val_h2 = "010" OR test_tile_val_v1 = "010" OR test_tile_val_v2 = "010" THEN
                    IF last_score > std_logic_vector(count) THEN
                        last_score <= std_logic_vector(count);
                        new_last_score <= std_logic_vector(count);
                    END IF;
                END IF;
                clock_scaler <= 0;
                count <= "0000000000000000";
                counter <= std_logic_vector(count);
            ELSIF clock_scaler = 34999999 THEN
                clock_scaler <= 0;
                count <= count + "0000000000000001";
                counter <= std_logic_vector(count);
            ELSE
                clock_scaler <= clock_scaler + 1;
            END IF;
        END IF;
    END PROCESS;
        
    
    -- Player sprite rendering (12×12)
    PROCESS(clk)
        VARIABLE px, py, pc, pr : INTEGER;
    BEGIN
        IF rising_edge(clk) THEN
            pc := TO_INTEGER(UNSIGNED(pixel_col));
            pr := TO_INTEGER(UNSIGNED(pixel_row));
            px := TO_INTEGER(UNSIGNED(player_x));
            py := TO_INTEGER(UNSIGNED(player_y));

            IF pc < 800 AND pr < 600 THEN
                IF pc >= px AND pc < px + 12 AND pr >= py AND pr < py + 12 THEN
                    draw_player  <= '1';
                    player_red   <= '1';
                    player_green <= '0';
                    player_blue  <= '0';
                ELSE
                    draw_player  <= '0';
                    player_red   <= '0';
                    player_green <= '0';
                    player_blue  <= '0';
                END IF;
            ELSE
                draw_player  <= '0';
                player_red   <= '0';
                player_green <= '0';
                player_blue  <= '0';
            END IF;
        END IF;
    END PROCESS;
    
enemy_logic_1: process(clk)
begin
    if rising_edge(clk) then
        if btnd = '1' OR test_tile_val_h1 = "010" OR test_tile_val_h2 = "010" OR test_tile_val_v1 = "010" OR test_tile_val_v2 = "010" then
            enemy_x_int_1   <= to_unsigned(400, 10);
            enemy_y_int_1   <= to_unsigned(225, 10);
            enemy_dir_1     <= '1';
            enemy_alive_1   <= '1';
            move_counter_1  <= (others => '0');
        elsif enemy_alive_1 = '1' then
            -- Move enemy every few million cycles
            move_counter_1 <= move_counter_1 + 1;
            if move_counter_1 = x"DDDDDD" then
                move_counter_1 <= (others => '0');
                if enemy_dir_1 = '1' then
                    if enemy_x_int_1 < to_unsigned(448, 10) then
                        enemy_x_int_1 <= enemy_x_int_1 + 1;
                    else
                        enemy_dir_1 <= '0';
                    end if;
                else
                    if enemy_x_int_1 > to_unsigned(368, 10) then
                        enemy_x_int_1 <= enemy_x_int_1 - 1;
                    else
                        enemy_dir_1 <= '1';
                    end if;
                end if;
            end if;

            -- Collision detection
            if (unsigned(player_x) + 11 >= enemy_x_int_1 and
                unsigned(player_x) <= enemy_x_int_1 + 11 and
                unsigned(player_y) + 11 >= enemy_y_int_1 and
                unsigned(player_y) <= enemy_y_int_1 + 11) then
                hit_player_1 <= '1';
            else
                hit_player_1 <= '0';
            end if;
            -- PVP Mechanic
            if btnc = '1' AND (unsigned(player_x) + 21 >= enemy_x_int_1 and
                unsigned(player_x) <= enemy_x_int_1 + 21 and
                unsigned(player_y) + 21 >= enemy_y_int_1 and
                unsigned(player_y) <= enemy_y_int_1 + 21) then
                    enemy_alive_1 <= '0';
                end if;
        else
            hit_player_1 <= '0';
        end if;
    end if;
end process;

    -- Assign signals for drawing
    enemy_x_1 <= std_logic_vector(enemy_x_int_1);
    enemy_y_1 <= std_logic_vector(enemy_y_int_1);
-- Enemy drawing process  
    process(clk)
begin
    if rising_edge(clk) then
            if (enemy_alive_1 = '1' and
                unsigned(pixel_col) >= unsigned(enemy_x_1) and
                unsigned(pixel_col) < unsigned(enemy_x_1) + 12 and
                unsigned(pixel_row) >= unsigned(enemy_y_1) and
                unsigned(pixel_row) < unsigned(enemy_y_1) + 12) then
                draw_enemy_1  <= '1';
                enemy_red_1   <= '1';
                enemy_green_1 <= '0';
                enemy_blue_1  <= '1';  -- purple
            else
                draw_enemy_1  <= '0';
                enemy_red_1   <= '0';
                enemy_green_1 <= '0';
                enemy_blue_1  <= '0';
            end if;
        end if;
end process;

    
enemy_logic_2: process(clk)
begin
    if rising_edge(clk) then
        if btnd = '1' OR test_tile_val_h1 = "010" OR test_tile_val_h2 = "010" OR test_tile_val_v1 = "010" OR test_tile_val_v2 = "010" then
            enemy_x_int_2   <= to_unsigned(352, 10);
            enemy_y_int_2   <= to_unsigned(289, 10);
            enemy_dir_2     <= '1';
            enemy_alive_2   <= '1';
            move_counter_2  <= (others => '0');
        elsif enemy_alive_2 = '1' then
            -- Move enemy every few million cycles
            move_counter_2 <= move_counter_2 + 1;
            if move_counter_2 = x"FFFFFF" then
                move_counter_2 <= (others => '0');
                if enemy_dir_2 = '1' then
                    if enemy_x_int_2 < to_unsigned(368, 10) then
                        enemy_x_int_2 <= enemy_x_int_2 + 1;
                    else
                        enemy_dir_2 <= '0';
                    end if;
                else
                    if enemy_x_int_2 > to_unsigned(308, 10) then
                        enemy_x_int_2 <= enemy_x_int_2 - 1;
                    else
                        enemy_dir_2 <= '1';
                    end if;
                end if;
            end if;

            -- Collision detection
            if (unsigned(player_x) + 11 >= enemy_x_int_2 and
                unsigned(player_x) <= enemy_x_int_2 + 11 and
                unsigned(player_y) + 11 >= enemy_y_int_2 and
                unsigned(player_y) <= enemy_y_int_2 + 11) then
                hit_player_2 <= '1';
            else
                hit_player_2 <= '0';
            end if;
            -- PVP Mechanic
            if btnc = '1' AND (unsigned(player_x) + 21 >= enemy_x_int_2 and
                unsigned(player_x) <= enemy_x_int_2 + 21 and
                unsigned(player_y) + 21 >= enemy_y_int_2 and
                unsigned(player_y) <= enemy_y_int_2 + 21) then
                    enemy_alive_2 <= '0';
                end if;
        else
            hit_player_2 <= '0';
        end if;
    end if;
end process;

    -- Assign signals for drawing
    enemy_x_2 <= std_logic_vector(enemy_x_int_2);
    enemy_y_2 <= std_logic_vector(enemy_y_int_2);
-- Enemy drawing process  
    process(clk)
begin
    if rising_edge(clk) then
            if (enemy_alive_2 = '1' and
                unsigned(pixel_col) >= unsigned(enemy_x_2) and
                unsigned(pixel_col) < unsigned(enemy_x_2) + 12 and
                unsigned(pixel_row) >= unsigned(enemy_y_2) and
                unsigned(pixel_row) < unsigned(enemy_y_2) + 12) then
                draw_enemy_2  <= '1';
                enemy_red_2   <= '1';
                enemy_green_2 <= '0';
                enemy_blue_2  <= '1';  -- purple
            else
                draw_enemy_2  <= '0';
                enemy_red_2   <= '0';
                enemy_green_2 <= '0';
                enemy_blue_2  <= '0';
            end if;
        end if;
end process;

    red   <= player_red   WHEN draw_player = '1' ELSE
         enemy_red_1    WHEN draw_enemy_1  = '1' ELSE
         enemy_red_2    WHEN draw_enemy_2  = '1' ELSE
         tile_red;

    green <= player_green WHEN draw_player = '1' ELSE
         enemy_green_1  WHEN draw_enemy_1  = '1' ELSE
         enemy_green_2  WHEN draw_enemy_2  = '1' ELSE
         tile_green;

    blue  <= player_blue  WHEN draw_player = '1' ELSE
         enemy_blue_1   WHEN draw_enemy_1  = '1' ELSE
         enemy_blue_2   WHEN draw_enemy_2  = '1' ELSE
         tile_blue;

END Behavioral;