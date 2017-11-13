*****************************
*
*       STATA Hangman
*
*****************************
* Author:    Marek Hlavac
* Date  :    13 December 2010
*****************************

clear all
set mem 10m
set more off

global mistakes = 0        // mistake counter
global number_of_rounds = 0 // how many rounds you have played
global number_of_victories = 0 // how many times have you won?
global word_to_guess = ""  // what word should player guess?

program define display_used_letters
 di " "
 di "USED LETTERS: $used_letters"
 di "------------------------------------------------------"
end

*** draws hangman in each one of six stages
program define draw_hangman_0
	set more off
	di
	di "================="
	di "||           |   "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||__             "
	display_used_letters
end

program define draw_hangman_1
	set more off
	di
	di "================="
	di "||          _|_  "
	di "||         /   \ "
	di "||         |   | "
	di "||         \___/ "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||__             "
	display_used_letters
end

program define draw_hangman_2
	set more off
	di
	di "================="
	di "||          _|_  "
	di "||         /   \ "
	di "||         |   | "
	di "||         \___/ "
	di "||           |   "
	di "||           |   "
	di "||           |   "
	di "||           |   "
	di "||           |   "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||__             "
	display_used_letters
end	

program define draw_hangman_3
	set more off
	di
	di "================="
	di "||          _|_  "
	di "||         /   \ "
	di "||         |   | "
	di "||         \___/ "
	di "||        \  |   "
	di "||         \_|   "
	di "||           |   "
	di "||           |   "
	di "||           |   "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||__             "
	display_used_letters
end	

program define draw_hangman_4
	set more off
	di
	di "================="
	di "||          _|_  "
	di "||         /   \ "
	di "||         |   | "
	di "||         \___/ "
	di "||        \  |  /"
	di "||         \_|_/ "
	di "||           |   "
	di "||           |   "
	di "||           |   "
	di "||               "
	di "||               "
	di "||               "
	di "||               "
	di "||__             "
	display_used_letters
end	


program define draw_hangman_5
	set more off
	di
	di "================="
	di "||          _|_  "
	di "||         /   \ "
	di "||         |   | "
	di "||         \___/ "
	di "||        \  |  /"
	di "||         \_|_/ "
	di "||           |   "
	di "||           |   "
	di "||           |   "
	di "||          /    "
	di "||         /     "
	di "||               "
	di "||               "
	di "||__             "
	display_used_letters
end	

program define draw_hangman_6
	set more off
	di
	di "================="
	di "||          _|_  "
	di "||         /   \ "
	di "||         |   | "
	di "||         \___/        Y O U"
	di "||        \  |  /      H A V E"
	di "||         \_|_/       L O S T"
	di "||           |   "
	di "||           |         CORRECT ANSWER:"
	di "||           |         $word_to_guess"
	di "||          / \  "
	di "||         /   \ "
	di "||               "
	di "||               "
	di "||__             "
    di " "
	
    di " "
    di "********************************"
    di " SORRY - YOU HAVE LOST "
    di "
    di " Your statistics:"
    di " - Rounds played : $number_of_rounds"
    di " - Victories     : $number_of_victories"
    di " - Win percentage: " + $number_of_victories/$number_of_rounds*100 
    di "********************************"
 
	new
end	

program define display_word
 set more off
 di "------------------------------------------------------"
 di " "
 di "$category_to_guess: $guess_shape"
 di " "
 draw_hangman_$mistakes
end

* start new game
program define new
 global mistakes = 0
 global used_letters= ""    // letters that have already been used
 global number_of_rounds=$number_of_rounds+1
 
 local seed = tc(`c(current_date)' `c(current_time)')/1000
 set seed `seed'

 local pick = 1+int((_N)*runiform())
 global word_to_guess=" "+word[`pick']+" "
 global category_to_guess=category[`pick']
 
 global guess_shape="$word_to_guess"
 foreach ch in "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" ///
               "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" ///
			   "1" "2" "3" "4" "5" "6" "7" "8" "9" "0"  {
	global guess_shape=subinstr("$guess_shape","`ch'",".",.)
 }
 display_word
end

program define victory_0
 set more off
 // empty
 di " "
end	

program define victory_1
 set more off
 global number_of_victories=$number_of_victories+1
 
 di " "
 di "********************************"
 di " CONGRATULATIONS - YOU HAVE WON "
 di "
 di " Your statistics:"
 di " - Rounds played : $number_of_rounds"
 di " - Victories     : $number_of_victories"
 di " - Win percentage: " + $number_of_victories/$number_of_rounds*100 
 di "********************************"
 
 di " "
 
 new
end	

program define add_used_letter_0 
args placeholder
 // empty
end

program define add_used_letter_1   // if letter not found, add it to list
args lower_letter
 global used_letters="$used_letters `lower_letter'"
 global mistakes=$mistakes+1
end

program define replace_letter_0
args placeholder
 // empty
end

program define replace_letter_1
args position lower_letter
 global guess_shape=substr("$guess_shape",1,`position'-1)+substr("$word_to_guess",`position',1)+substr("$guess_shape",`position'+1,length("$guess_shape")-`position')
end

program define guess
args letter
 local found = 0
 local lower_letter = lower(substr("`letter'",1,1))
 local upper_letter = upper(substr("`letter'",1,1))
  
 local word_length=length("$word_to_guess")
 
 global before_change="$guess_shape"
 forvalues i=1/`word_length' {
	local found_here=(strpos(substr("$word_to_guess",`i',1),"`lower_letter'")==1)|(strpos(substr("$word_to_guess",`i',1),"`upper_letter'")==1)
	replace_letter_`found_here' `i' 
 }
 local no_change=("$before_change"=="$guess_shape") & (strpos("$used_letters","`lower_letter'")==0)
 add_used_letter_`no_change' `lower_letter'
 
 display_word
 
 local victory=("$guess_shape"=="$word_to_guess")&($mistakes<6)
 victory_`victory'
end

use "hangman_data", clear

******************************************
*
*             STATA Hangman
*
******************************************
* Author:    Marek Hlavac
* Date  :    13 December 2010
******************************************
* Commands:
*
*   guess a
*   guess b
*   guess c, etc. = guess letters
*
*   new = new game
*
******************************************

new 
