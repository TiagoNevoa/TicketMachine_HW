library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IOS is
port(
		MCLK, Fsh, Reset : in std_logic;  -- MCLK usa clock da placa. Reset é switch. Fsh é um switch
		SCLK, SDX, NOT_SS : in std_logic;  -- vem do software
		busy, WrT, WrL : out std_logic;
		Dout: out STD_LOGIC_VECTOR (8 downto 0)
		);
end IOS;

architecture behavioral of IOS is

COMPONENT SerialReceiver
	port(	DX : in std_logic;
		CLK : in std_logic;
		MCLK : in std_logic;
		NOT_SS : in std_logic;
		Accept : in std_logic;
		Reset : in std_logic;
		DataOut : out  STD_LOGIC_VECTOR (9 downto 0);
		Dxval, busy : out std_logic);
END COMPONENT;

COMPONENT Dispatcher
port(
		Reset : in  std_logic;
		Fsh: in std_logic;
		Dval: in std_logic;
		Din: in STD_LOGIC_VECTOR (9 downto 0);
		WrT: out std_logic;
		Dout: out STD_LOGIC_VECTOR (8 downto 0);
		WrL: out std_logic;
		MCLK: in std_logic;
		done: out std_logic		
);
END COMPONENT;

COMPONENT clkDIV
GENERIC (div : NATURAL);
port ( clk_in: in std_logic;
		 clk_out: out std_logic	
);
END COMPONENT;

signal sDoneAccept, sDXval, signalCLK, signalMCLK, signalClkDiv : std_logic;
signal sD : STD_LOGIC_VECTOR (9 downto 0);

begin
signalMCLK <= MCLK;
signalCLK <= SCLK; -- signal para clock porque clock é partilhado com serial receiver e dispatcher

clkDIV0: clkDIV 
GENERIC MAP ( div => 20 )
PORT MAP (
	clk_in => signalMCLK,
	clk_out => signalClkDiv);


serialR: SerialReceiver PORT MAP (
	DX => SDX,
	Reset => Reset,
	MCLK => signalMCLK,
	CLK => signalCLK,
	NOT_SS => NOT_SS,
	Accept => sDoneAccept,
	busy => busy,
	Dxval => sDXval,
	DataOut => sD);
		
Disp: Dispatcher PORT MAP (
	MCLK => signalClkDiv,
	Reset => Reset,
	Fsh => Fsh,
	Dval => sDXval,
	Din => sD,
	WrT => WrT,
	Dout => Dout,
	WrL => WrL,	
	done => sDoneAccept);

end behavioral;