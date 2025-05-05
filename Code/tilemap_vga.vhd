LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tilemap_vga IS
    PORT (
        clk         : IN  STD_LOGIC;
        v_sync      : IN  STD_LOGIC;
        pixel_row   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        red         : OUT STD_LOGIC;
        green       : OUT STD_LOGIC;
        blue        : OUT STD_LOGIC
    );
END tilemap_vga;

ARCHITECTURE Behavioral OF tilemap_vga IS
    -- Tilemap parameters
    CONSTANT TILE_SIZE      : INTEGER := 20;
    CONSTANT TILE_BITS      : INTEGER := 5; -- 2^5 = 32 tiles max per row/column

    SIGNAL tile_X, tile_Y   : STD_LOGIC_VECTOR(TILE_BITS-1 DOWNTO 0);
    SIGNAL tile_num         : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL world_X, world_Y : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL origin_X, origin_Y : STD_LOGIC_VECTOR(8 DOWNTO 0);

    COMPONENT map_rom
        PORT (
            clock   : IN  STD_LOGIC;
            tile_X  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            tile_Y  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            data    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT draw_map
        PORT (
            world_X, world_Y : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            origin_X, origin_Y : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            tile_num : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            red, green, blue : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    -- Calculate tile indices and pixel positions
    tile_X <= pixel_col(10 DOWNTO 6); -- pixel_col / 20 (TILE_SIZE)
    tile_Y <= pixel_row(10 DOWNTO 6); -- pixel_row / 20

    world_X <= pixel_col(8 DOWNTO 0);
    world_Y <= pixel_row(8 DOWNTO 0);

    origin_X <= tile_X & "0000"; -- Multiply tile_X by 20 (TILE_SIZE)
    origin_Y <= tile_Y & "0000"; -- Multiply tile_Y by 20

    -- Instantiate the map ROM to get tile type
    rom_inst : map_rom
        PORT MAP (
            clock => clk,
            tile_X => tile_X,
            tile_Y => tile_Y,
            data => tile_num
        );

    -- Draw the tile
    draw_inst : draw_map
        PORT MAP (
            world_X => world_X,
            world_Y => world_Y,
            origin_X => origin_X,
            origin_Y => origin_Y,
            tile_num => tile_num,
            red => red,
            green => green,
            blue => blue
        );

END Behavioral;