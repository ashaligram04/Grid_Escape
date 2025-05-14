LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Game_Main IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btnc : IN STD_LOGIC;
        btnd : IN STD_LOGIC;
        btnu : IN STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END Game_Main;

ARCHITECTURE Behavioral OF Game_Main IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL display_1 : std_logic_vector (15 DOWNTO 0); -- value to be displayed
    SIGNAL display_2 : std_logic_vector (15 DOWNTO 0); -- value to be displayed
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
    SIGNAL led_count : unsigned(18 downto 0) := (others => '0');
    
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT tilemap_vga is
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
    END COMPONENT;
    
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
    COMPONENT leddec16 IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            data_1 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            data_2 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT; 
    
BEGIN
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
    
    process(pxl_clk)
    begin
        if rising_edge(pxl_clk) then
            led_count <= led_count + 1;
            led_mpx <= std_logic_vector(led_count(18 downto 16)); -- slow ~1 kHz refresh
        end if;
    end process;
    
    tilemap : tilemap_vga
    PORT MAP(
        clk => pxl_clk,
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        red => S_red, 
        green => S_green, 
        blue => S_blue,
        btnl => btnl,
        btnr => btnr,
        btnu => btnu,
        btnd => btnd,
        btnc => btnc,
        counter => display_1,
        new_last_score => display_2
    );
    
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    led1 : leddec16
    PORT MAP(
      dig => led_mpx, data_1 => display_1, data_2 => display_2,
      anode => SEG7_anode, seg => SEG7_seg
    );
END Behavioral;