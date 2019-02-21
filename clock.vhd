library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity clock is
  port (
    I_CLK_REF         : in    std_logic;
    I_RESET           : in    std_logic;
    --
    O_CLK             : out   std_logic
    );
end clock;

architecture RTL of clock is

  signal clk_ref_ibuf           : std_logic;
  signal clk_dcm_op_0           : std_logic;
  signal clk_dcm_op_dv          : std_logic;
  signal clk_dcm_0_bufg         : std_logic;
  signal locked_internal        : std_logic;
  signal status_internal        : std_logic_vector(7 downto 0);

begin

  IBUFG0 : IBUFG port map (I=> I_CLK_REF,     O => clk_ref_ibuf);
  BUFG0  : BUFG  port map (I=> clk_dcm_op_0,  O => clk_dcm_0_bufg);
  BUFG1  : BUFG  port map (I=> clk_dcm_op_dv, O => O_CLK);

	dcm_inst : DCM_SP
--    -- pragma translate_off
		generic map (
			CLKIN_DIVIDE_BY_2     => FALSE,
			CLK_FEEDBACK          => "1X",
			DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
			DSS_MODE              => "NONE",
			DUTY_CYCLE_CORRECTION => TRUE,
			CLKOUT_PHASE_SHIFT    => "NONE",
			PHASE_SHIFT           => 0,
			CLKFX_MULTIPLY        => 20,
			CLKFX_DIVIDE          => 32,
			CLKDV_DIVIDE          => 2.0,
			STARTUP_WAIT          => FALSE,
			CLKIN_PERIOD          => 31.25
		 )
--    -- pragma translate_on
		port map (
			CLKIN    => clk_ref_ibuf,
			CLKFB    => clk_dcm_0_bufg,
			DSSEN    => '0',
			PSINCDEC => '0',
			PSEN     => '0',
			PSCLK    => '0',
			RST      => I_RESET,
			CLK0     => clk_dcm_op_0,
			CLK90    => open,
			CLK180   => open,
			CLK270   => open,
			CLK2X    => open,
			CLK2X180 => open,
			CLKDV    => open,
			CLKFX    => clk_dcm_op_dv,
			CLKFX180 => open,
			LOCKED   => locked_internal,
			STATUS   => status_internal,
			PSDONE   => open
		 );
end RTL;
