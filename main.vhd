----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:32:33 05/16/2019 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Generic (N : INTEGER:=50*10**6); -- 50*10^6 Hz Clock
    Port ( MCLK : in  STD_LOGIC;
			  encoder : in  STD_LOGIC_VECTOR (5 downto 0);
           modeNum : in  STD_LOGIC;
			  modeLet : in  STD_LOGIC;
           play : in  STD_LOGIC;
           add : in  STD_LOGIC;
           delete : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
           display : out  STD_LOGIC_VECTOR (9 downto 0));
end main;

architecture Behavioral of main is

--Clock Divider
signal CLK_DIV : STD_LOGIC;

--Read/Write Output
signal bar : STD_LOGIC_VECTOR (9 downto 0);

--Morse code representation tables
type MORSE_NUMS is array (integer range <> ) of std_logic_vector(0 to 18);
type MORSE_CHARS is array (integer range <> ) of std_logic_vector(0 to 12);
type MORSE_CHAR_LENGTHS is array ( integer range <> ) of integer range 0 to 255;

--Numbers
CONSTANT  MNUM: MORSE_NUMS(0 to 10) := (
"1110111011101110111", "1011101110111011100", "1010111011101110000",
-- 0 1 2
"1010101110111000000", "1010101011100000000", "1010101010000000000",
-- 3 4 5 
"1110101010100000000", "1110111010101000000", "1110111011101010000", "1110111011101110100",
-- 6 7 8 9
"0000000000000000000"
-- SPACE
);
CONSTANT  MNUML : MORSE_CHAR_LENGTHS(0 to 10) := ( 
19, 17, 15,
13, 11, 9,
11, 13, 15, 17, 7);

CONSTANT  MLET: MORSE_CHARS(0 to 26) := (
"0000000000000", "1011100000000", "1110101010000", "1110101110100", "1110101000000", "1000000000000",
-- SPACE a b c d e
"1010111010000", "1110111010000", "1010101000000", "1010000000000", "1011101110111",
-- f g h i j
"1110101110000", "1011101010000", "1110111000000", "1110100000000", "1110111011100",
-- k l m n o
"1011101110100", "1110111010111", "1011101000000", "1010100000000", "1110000000000",
-- p q r s t
"1010111000000", "1010101110000", "1011101110000", "1110101011100", "1110101110111",
-- u v w x y
"1110111010100"
-- z 
);
CONSTANT  MLETL : MORSE_CHAR_LENGTHS(0 to 26) := ( 
7, 5, 9, 11, 7, 1,
   9, 9, 7, 3, 13,
   9, 9, 7, 5, 11,
   11, 13, 7, 5, 3,
   7, 9, 9, 11, 13,
   11
);

--Counters
signal charpos : integer := 0;
signal seqpos : integer := 0;

--Num Mode
signal numMode : boolean := false;

--Memory
type MEMORYARRAY is array ( integer range <> ) of std_logic_vector(5 downto 0);
constant memLimit : integer := 64;
signal memory : MEMORYARRAY (0 to memLimit);
signal memSize : integer := 0;


-- State variables
constant init: STD_LOGIC_VECTOR(9 downto 0) := "0000000001";
constant playcode: STD_LOGIC_VECTOR(9 downto 0) := "0000000010";
constant charSep: STD_LOGIC_VECTOR(9 downto 0) := "0000000100";
constant setnummode: STD_LOGIC_VECTOR(9 downto 0) := "0000001000";
constant setletmode: STD_LOGIC_VECTOR(9 downto 0) := "0000010000";
constant addNewChar: STD_LOGIC_VECTOR(9 downto 0) := "0000100000";
constant deleteChar: STD_LOGIC_VECTOR(9 downto 0) := "0001000000";
constant resetRec: STD_LOGIC_VECTOR(9 downto 0) := "0010000000";
constant clear: STD_LOGIC_VECTOR(9 downto 0) := "0100000000";
constant done: STD_LOGIC_VECTOR(9 downto 0) := "1000000000";

signal State: STD_LOGIC_VECTOR(9 downto 0) := "0100000000";  

begin
--Update display
display <= bar;

-- Clock divider
process(MCLK)
variable Counter : INTEGER range 0 to N;
begin	
		if rising_edge(MCLK) then
			Counter := Counter + 1;
			 -- Clock frequency 1000/2 = 500Hz
			 if (Counter = N/20-1) then 
					Counter := 0;
					CLK_DIV <= not CLK_DIV;				
			 end if;
		end if;
	end process;
		
-- Main Loop
process(CLK_DIV)
begin
		if rising_edge(CLK_DIV) then
			case State is
				--init
				when init =>
					-- Don't do anything
					if (play = '1') then
						seqpos <= 0;
						charpos <= 0;
						State <= playcode;
					elsif (modeNum = '1') then
						State <= setnummode;
					elsif (modeLet = '1') then
						State <= setletmode;
					elsif (add = '1') then
						--ADD CHARACTER BASED ON MODE
						State <= addNewChar;
					elsif (delete = '1') then
						State <= deleteChar;
					elsif (reset = '1') then
						State <= resetRec;
					else
						State <= init;
					end if;
				
				--add a new
				when addNewChar =>
					--If character limit reached skip
					if ( (memSize + 1) >= memLimit) then
						State <= done;
					--Add as a number
					elsif ( (numMode = true) and ( to_integer(unsigned(encoder)) <= 9) ) then
						memory (memsize)  <= encoder;
						--memory  (memsize) <= "000001";
						memsize <= memsize + 1;
						State <= done;
					--Add as a letter
					elsif ( (numMode = false) and ( to_integer(unsigned(encoder)) >= 1) and ( to_integer(unsigned(encoder)) <= 26) ) then
						memory (memsize)  <= std_logic_vector(10 + unsigned(encoder));
						--memory (memsize) <= "000001";
						memsize <= memsize + 1;
						State <= done;					
					--Add space
					else
						memory (memsize) <= "100100";
						memsize <= memsize + 1;
						State <= done;
					end if;
				
				--play the code
				when playcode =>
					--Until the seqpos loop is over
					if (seqpos < memSize) then
						--Play the next character in the sequence from the table
						--memory (seqpos)
						
					   --Determine if number or character
						if ( to_integer(unsigned(memory (seqpos))) < 10) then
							--number-----
							if(charpos < mnuml( to_integer(unsigned(memory (seqpos)))) ) then
								--shift left
								bar <= std_logic_vector(shift_left(unsigned(bar),1));
								--add new bit
								bar (0) <= mnum( to_integer(unsigned(memory (seqpos))) )(charpos);
								--bar (0) <= memory (seqpos)(charpos);
								charpos <= charpos + 1;
								State <= playcode;
							else 
								charpos <= 0;
								State <= charSep;
							end if;
							
						 elsif ( to_integer(unsigned(memory (seqpos))) <= 10+26) then
							--character------
							if(charpos < mletl( to_integer(unsigned(memory (seqpos))) - 10)) then
								--shift left
								bar <= std_logic_vector(shift_left(unsigned(bar), 1));
								--add new bit
								bar (0) <= mlet( to_integer(unsigned(memory (seqpos))) - 10)(charpos);
								charpos <= charpos + 1;
								State <= playcode;
							else 
								charpos <= 0;
								State <= charSep;
							end if;
							
						 else
							--or space--------
							if( charpos < mletl(26) ) then
								--shift left
								bar <= std_logic_vector(shift_left(unsigned(bar), 1));
								--add new bit
								bar (0) <= '0';
								charpos <= charpos + 1;
								State <= playcode;
							else 
								charpos <= 0;
								State <= charSep;
							end if;
							
						 end if;
					--When a character ends but seqpos is still going head on over to the space state
					--When all characters end go to clear
					else
						State <= Clear;
						
					--charpos <= 0;
					--State <= init;
					end if;
				
				--Set Num Mode
				when setnummode => 
					numMode <= true;
					State<=init;
					
				--Set Letter Mode
				when setletmode => 
					numMode <= false;
					State<=init;
				
				--Set Char Seperator
				when charSep =>
					if( charpos < 3 ) then
						--shift left
						bar <= std_logic_vector(shift_left(unsigned(bar), 1));
						--add new bit
						bar (0) <= '0';
						charpos <= charpos + 1;
						State <= charSep;
					elsif (seqpos >= memSize) then
						State <= clear;
					else 
						charpos <= 0;
						seqpos <= seqpos+1;
						State <= playCode;
					end if;
					
				--clear anything still on the screen
				when clear =>
					--If not empty
					if bar /= "0000000000" then
						--Shift leftward
						bar <= std_logic_vector(shift_left(unsigned(bar),1));
						State <= clear;
					else
						State <= done;
					end if;
				
				--Reset Memory
				when resetRec =>
					memsize <= 0;
					State <= done;
					
				--Delete Character
				when deleteChar =>
					if (memsize > 0) then
						memsize <= memsize-1;
					end if;
					State <= done;

				when done =>
					if ( play = '1'  ) then
						State <= done;
					elsif ( add = '1' ) then
						State <= done;
					elsif ( delete = '1' ) then
						State <= done;
					elsif ( reset = '1' ) then
						State <= done;
					else
						State <= init;
					end if;
					
				when others =>
					State <= init;
			end case;
		end if;	
end process;

end Behavioral;