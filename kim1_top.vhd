library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kim1_top is
	port(
		CLK_20			: in std_logic;
		VIDEO_R			: out std_logic_vector(7 downto 0);
		VIDEO_G			: out std_logic_vector(7 downto 0);
		VIDEO_B			: out std_logic_vector(7 downto 0);
		VIDEO_HSYNC		: out std_logic := '1';
		VIDEO_VSYNC		: out std_logic := '1'
	);
end kim1_top;

architecture behavior of kim1_top is

	signal vga_clock 		: std_logic := '0';
	signal vga_hpos		: integer range 0 to 1000;
	signal vga_vpos		: integer range 0 to 1000;
	
	signal led_output 	: std_logic_vector(5 downto 0);
	
	type LedArray is array (0 to 5) of std_logic_vector(6 downto 0);
	signal ledSegments	: LedArray;
--	signal ledValue		: std_logic_vector (23 downto 0) := x"000000";

	type LedArrayDebug is array (0 to 8) of std_logic_vector(6 downto 0);
	signal ledSegmentsDebug	: LedArrayDebug;
	signal ledOutputDebug 	: std_logic_vector(8 downto 0);
	signal ledValueDebug		: std_logic_vector (31 downto 0);

	
	signal oneSecCount	 	: integer := 0;
	signal phi4					: std_logic := '0';
	signal phi2					: std_logic := '0';
	signal mem_clock			: std_logic :='0';
	signal signalCount		: integer := 0;

	
	
	constant ZEROS			: std_logic_vector(5 downto 0) := "000000";
		
	constant SEG_XOFFSET	: integer := 20;
	constant SEG_YOFFSET	: integer := 100;
	constant SEG_WIDTH	: integer := 80;
	constant SEG_LENGTH	: integer := 160;
	constant SEG_THICK	: integer := 10;
	constant SEG_GAP		: integer := 20;
	
	signal we				: std_logic;
	signal rst				: std_logic := '1';
	signal nmi				: std_logic := '1';
	signal irq				: std_logic := '1';
	
	signal data_in       		: std_logic_vector(7 downto 0);
   signal data_out      		: std_logic_vector(7 downto 0);
   signal rom_data_out  		: std_logic_vector(7 downto 0);
   signal ram1024_data_out		: std_logic_vector(7 downto 0);
   signal ram6530_data_out		: std_logic_vector(7 downto 0);
   signal io6530_002_data_out	: std_logic_vector(7 downto 0);	
   signal io6530_003_data_out	: std_logic_vector(7 downto 0);	
	signal address_out			: std_logic_vector(15 downto 0);

	signal ram_1024_en	: std_logic;
	signal io_6530_003_en: std_logic;
	signal io_6530_002_en: std_logic;
	signal ram_6530_en	: std_logic;
	signal rom_en			: std_logic;
	
	signal io_6530_002_porta_out	: std_logic_vector(7 downto 0);
	signal io_6530_002_porta_in	: std_logic_vector(7 downto 0);
	signal io_6530_002_portb_out	: std_logic_vector(7 downto 0);
	signal io_6530_002_portb_in	: std_logic_vector(7 downto 0);
	signal io_6530_003_porta_out	: std_logic_vector(7 downto 0);
	signal io_6530_003_porta_in	: std_logic_vector(7 downto 0);
	signal io_6530_003_portb_out	: std_logic_vector(7 downto 0);
	signal io_6530_003_portb_in	: std_logic_vector(7 downto 0);

begin
	pllInst : entity work.pll
		port map (
			inclk0 => CLK_20,
			c0 => vga_clock
		);

	mem_decoder_inst : entity work.mem_decoder
		port map(
			addr 				=> address_out,
			ram_1024_en 	=> ram_1024_en,
			io_6530_003_en => io_6530_003_en,
			io_6530_002_en => io_6530_002_en,
			ram_6530_en		=> ram_6530_en,
			rom_en			=> rom_en
		);
		
	romInst : entity work.rom
		port map (
			address	=> address_out(10 downto 0),
			clock		=> mem_clock and rom_en,
			q			=>	rom_data_out
		);

	ram1024Inst : entity work.ram1024 port map (
		address	=> address_out(9 downto 0),
		clock	 	=> mem_clock and ram_1024_en,
		data	 	=> data_out,
		wren	 	=> we,
		q	 		=> ram1024_data_out
	);

	ram6530Inst : entity work.ram6530 port map (
		address	=> address_out(6 downto 0),
		clock	 	=> mem_clock and ram_6530_en,
		data	 	=> data_out,
		wren	 	=> we,
		q	 		=> ram6530_data_out
	);

	io6530_002Inst : entity work.R6530 port map (
		phi2		=> phi2,
		rst_n		=> not(rst),
		cs			=> io_6530_002_en,
		rw_n		=> not(we),
		add		=> address_out(3 downto 0),
		din		=> data_out,
		dout		=> io6530_002_data_out,
		pa_in		=> io_6530_002_porta_in,
		pb_in		=> io_6530_002_portb_in,
		pa_out	=> io_6530_002_porta_out,
		pb_out	=> io_6530_002_portb_out
	);

	io6530_003Inst : entity work.R6530 port map (
		phi2		=> phi2,
		rst_n		=> not(rst),
		cs			=> io_6530_003_en,
		rw_n		=> not(we),
		add		=> address_out(3 downto 0),
		din		=> data_out,
		dout		=> io6530_003_data_out,
		pa_in		=> io_6530_003_porta_in,
		pb_in		=> io_6530_003_portb_in,
		pa_out	=> io_6530_003_porta_out,
		pb_out	=> io_6530_003_portb_out
	);

	vgaInst : entity work.vga
		port map (
			vga_clock => vga_clock,
			vga_hpos => vga_hpos,
			vga_vpos => vga_vpos,
			vga_hsync => VIDEO_HSYNC,
			vga_vsync => VIDEO_VSYNC
		);

	generateLeds : for i in 0 to 5 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> SEG_XOFFSET + i*(SEG_WIDTH + SEG_GAP),
				yoffset 	=> SEG_YOFFSET,
				width		=> SEG_WIDTH,
				length	=>	SEG_LENGTH,
				thick		=> SEG_THICK,
				segments => ledSegments(i),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => led_output(i)
			);
	end generate;

    P6502: entity work.P6502 
        generic map (
            PC_INIT => x"0000"
        )
        port map (
            clk         => phi2,
            rst         => rst,
            we          => we,
            data_in     => data_in,
            data_out    => data_out,
            address_out => address_out,
            nmi         => nmi,
            irq         => irq,
            ready       => '1',
            nres        => '0'     
        );
		  
	dataBusMux:process(rom_en, ram_1024_en, ram_6530_en, io_6530_002_en, io_6530_003_en, ram1024_data_out, ram6530_data_out, io6530_002_data_out, io6530_003_data_out)
	begin
		if (rom_en = '1') then
			data_in <= rom_data_out;
--			case address_out is
--				when x"FFFC" => data_in <= x"22";
--				when x"FFFD" => data_in <= x"1C";
--				when x"FFFE" => data_in <= x"78";
--				when x"FFFF" => data_in <= x"56";
--				when x"1C22" => data_in <= x"A2";--ldx 60
--				when x"1C23" => data_in <= x"60";
--				when x"1C24" => data_in <= x"86";--stx 00f2
--				when x"1C25" => data_in <= x"F2";
--				when x"1C26" => data_in <= x"20";--jsr 00f2
--				when x"1C27" => data_in <= x"F2";
--				when x"1C28" => data_in <= x"00";
--				
--				when others  => data_in <= x"EA";
--			end case;
		elsif (ram_1024_en = '1') then
			data_in <= ram1024_data_out;
		elsif (ram_6530_en = '1') then
			data_in <= ram6530_data_out;
		elsif (io_6530_002_en = '1') then
			data_in <= io6530_002_data_out;
		elsif (io_6530_003_en = '1') then
			data_in <= io6530_003_data_out;
		else
			data_in <= "ZZZZZZZZ";
		end if;
	end process;
	
	provideMemClock:process(CLK_20)
	begin
		if(CLK_20'event and CLK_20 = '1')then
			if (oneSecCount >= 20000) then
					oneSecCount <= 0;
					phi4 <= not(phi4);
--					ledValue <= std_logic_vector( unsigned(ledValue) + 1 );
			else
				oneSecCount <= oneSecCount + 1;
			end if;
		end if;
	end process;

	provideCpuClock:process(phi4)
	begin
		if(phi4'event and phi4 = '1')then
			phi2 <= not(phi2);
		end if;
	end process;

	signalCountProcess:process(phi2)
	begin
		if(phi2'event and phi2 = '1')then
			if (signalCount >= 2) then
					rst <= '0';
			else
				signalCount <= signalCount + 1;
			end if;
		end if;
	end process;

	draw_segment : process(led_output, ledOutputDebug)
	begin
		if(led_output /= ZEROS) then
			VIDEO_R <= "01111111";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		elsif (ledOutputDebug /= "000000000") then
			VIDEO_R <= "01111111";
			VIDEO_G <= "01111111";
			VIDEO_B <= "01111111";
		else
			VIDEO_R <= "00000000";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		end if;
	end process;
		

--	generateLedValues : for i in 0 to 5 generate	
--	begin
--		with ledValue((5-i)*4 + 3 downto (5-i)*4) select ledSegments(i) <=
--			"0111111" when x"0",
--			"0000110" when x"1",
--			"1011011" when x"2",
--			"1001111" when x"3",
--			"1100110" when x"4",
--			"1101101" when x"5",
--			"1111101" when x"6",
--			"0000111" when x"7",
--			"1111111" when x"8",
--			"1101111" when x"9",
--			"1110111" when x"a",
--			"1111100" when x"b",
--			"0111001" when x"c",
--			"1011110" when x"d",
--			"1111001" when x"e",
--			"1110001" when x"f";
--	end generate;


	processIndicators : process(io_6530_002_portb_out, io_6530_002_porta_out)
	begin
		if (io_6530_002_portb_out(4 downto 1) = x"4") then 
			ledSegments(5) <= io_6530_002_porta_out(6 downto 0);
			ledSegments(4) <= "0000000"; 
			ledSegments(3) <= "0000000"; 
			ledSegments(2) <= "0000000"; 
			ledSegments(1) <= "0000000"; 
			ledSegments(0) <= "0000000"; 
		elsif (io_6530_002_portb_out(4 downto 1) = x"5") then 
			ledSegments(5) <= "0000000";
			ledSegments(4) <= io_6530_002_porta_out(6 downto 0); 
			ledSegments(3) <= "0000000"; 
			ledSegments(2) <= "0000000"; 
			ledSegments(1) <= "0000000"; 
			ledSegments(0) <= "0000000"; 
		elsif (io_6530_002_portb_out(4 downto 1) = x"6") then 
			ledSegments(5) <= "0000000";
			ledSegments(4) <= "0000000"; 
			ledSegments(3) <= io_6530_002_porta_out(6 downto 0); 
			ledSegments(2) <= "0000000"; 
			ledSegments(1) <= "0000000"; 
			ledSegments(0) <= "0000000"; 
		elsif (io_6530_002_portb_out(4 downto 1) = x"7") then 
			ledSegments(5) <= "0000000";
			ledSegments(4) <= "0000000"; 
			ledSegments(3) <= "0000000"; 
			ledSegments(2) <= io_6530_002_porta_out(6 downto 0); 
			ledSegments(1) <= "0000000"; 
			ledSegments(0) <= "0000000"; 
		elsif (io_6530_002_portb_out(4 downto 1) = x"8") then 
			ledSegments(5) <= "0000000";
			ledSegments(4) <= "0000000"; 
			ledSegments(3) <= "0000000"; 
			ledSegments(2) <= "0000000"; 
			ledSegments(1) <= io_6530_002_porta_out(6 downto 0); 
			ledSegments(0) <= "0000000"; 
		elsif (io_6530_002_portb_out(4 downto 1) = x"9") then 
			ledSegments(5) <= "0000000";
			ledSegments(4) <= "0000000"; 
			ledSegments(3) <= "0000000"; 
			ledSegments(2) <= "0000000"; 
			ledSegments(1) <= "0000000"; 
			ledSegments(0) <= io_6530_002_porta_out(6 downto 0); 
		else
			ledSegments(5) <= "0000000";
			ledSegments(4) <= "0000000"; 
			ledSegments(3) <= "0000000"; 
			ledSegments(2) <= "0000000"; 
			ledSegments(1) <= "0000000"; 
			ledSegments(0) <= "0000000"; 
		end if;
	end process;
		
	generateDebugAddr : for i in 0 to 3 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> 0 + i*50,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(i),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(i)
			);
	end generate;

	generateDebugDataIn : for i in 0 to 1 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> 220 + i*50,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(i+4),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(i+4)
			);
	end generate;

	generateDebugDataOut : for i in 0 to 1 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> 340 + i*50,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(i+6),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(i+6)
			);
	end generate;

	segmentInstDebugStatus : entity work.segment
			port map (
				xoffset 	=> 460,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(8),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(8)
			);


	generateLedValuesDebug : for i in 0 to 7 generate	
	begin
		with ledValueDebug((7-i)*4 + 3 downto (7-i)*4) select ledSegmentsDebug(i) <=
			"0111111" when x"0",
			"0000110" when x"1",
			"1011011" when x"2",
			"1001111" when x"3",
			"1100110" when x"4",
			"1101101" when x"5",
			"1111101" when x"6",
			"0000111" when x"7",
			"1111111" when x"8",
			"1101111" when x"9",
			"1110111" when x"a",
			"1111100" when x"b",
			"0111001" when x"c",
			"1011110" when x"d",
			"1111001" when x"e",
			"1110001" when x"f";
	end generate;


	mem_clock <= not(phi4) and not(phi2);

	ledValueDebug(31 downto 16) <= address_out(15 downto 0);
	ledValueDebug(15 downto 8) <= data_in(7 downto 0);
	ledValueDebug(7 downto 0) <= data_out(7 downto 0);
	
	ledSegmentsDebug(8)(0) <= phi2;
	ledSegmentsDebug(8)(1) <= rst;

	ledSegmentsDebug(8)(3) <= not(phi4);

	ledSegmentsDebug(8)(6) <= we;
	
--	ledValue(7 downto 0) <= io_6530_002_porta_out;
--	ledValue(15 downto 8) <= io_6530_002_portb_out;
--	ledValue(23 downto 16) <= x"AA";
	
	
end behavior;
	
