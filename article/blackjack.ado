*! blackjack.ado -  Blackjack 21 Card Game
*! Eric Booth <eric.a.booth@gmail.com>   <ebooth@tamu.edu>
*! Last Modified: Jan 2010
*! Syntax:  blackjack



cap program drop blackjack
program def blackjack
syntax

*********************************
**set environ conditions**
version 11
set more off
loc rm "`c(rmsg)'"
set rmsg off
preserve


*********************************
**Betting System**
	*^ Player Cash Default is $1000; stored in global $BJCASH_TTOTAL
	if "$BJCASH_TTOTAL" == ""  global BJCASH_TTOTAL  500
	if "$BJCASH_TTOTAL" == "0"  global BJCASH_TTOTAL  500
	noi di in white "`c(username)' has \$ $BJCASH_TTOTAL"
	noi di in white "Bet Amount?", _request(bet)
	if "$bet" == "m" | "$bet" == "max" global bet =  $BJCASH_TTOTAL
	noi di in white _col(5) `"Player All-in (\$ $BJCASH_TTOTAL)"'
		**error check the bet**
		if $bet > $BJCASH_TTOTAL {
				noi di in red "Bet must be <= $BJCASH_TTOTAL ", _continue
				noi di in white "New Bet Amount?", _request(bet)
				}
		if $bet > $BJCASH_TTOTAL {
				noi di in red "Bet must be <= $BJCASH_TTOTAL, goodbye "
				exit
				}
				
				
*********************************
**select initial cards & remove them from list if more than 4**
	
	**create dataset with all possible cards**
		qui {
			clear
			numlist "2/10", integer ascending
			loc nonfacecards "`r(numlist)'"
			set obs 52
			tempvar card
			g `card' = ""
			loc i = 1
			foreach v in 189 215 198 207 {
				foreach n in `nonfacecards' "J" "Q" "K" "A"  {
				qui replace `card' = "`n'`=char(`v')'" in `i'
				 loc i `++i'
				}
			}
		}
	**allcards**
	tempvar dealorder d1
	g `d1' =  int(abs(uniform()*100))
	sort `d1'
	g `dealorder' = _n
	tempvar d1 d2 d3 d4 d5 p1 p2 p3 p4 p5  //dealer & player can get at most 5 cards each
		g `p1' = "`=`card'[1]'"
		g `d1' = "`=`card'[2]'"
		g `p2' = "`=`card'[3]'"
		g `d2' = "`=`card'[4]'"
		g `p3' = "`=`card'[5]'"
		g `d3' = "`=`card'[6]'"
		g `p4' = "`=`card'[7]'"
		g `d4' = "`=`card'[8]'"	
		g `p5' = "`=`card'[9]'"
		g `d5' = "`=`card'[10]'"		
	**for adding the card totals**
		forval n = 1/5 {
			foreach l in p d {
				qui g a``l'`n'' = substr(``l'`n'',1, 1)
				 cap confirm string variable a``l'`n''
				if !_rc {
				qui replace a``l'`n'' = "10" if inlist(a``l'`n'', "J", "Q", "K")
				qui replace a``l'`n'' = "11" if a``l'`n''== "A"
				qui replace a``l'`n'' = "10" if a``l'`n''== "1"
				qui destring a``l'`n'', replace force 
						}
					}
				}
*********************************
**display cards and prompt user**	



	**********************************************
	**d1, p1, p2.  initial draw for dealer & player	
		*---d1---*
		di in g as smcl "{hline}"
		noi di in y "DEALER:  "
		noi di _skip(1) "---------------" _skip(3) "---------------"
		noi di _skip(1) "|`=`d1''           |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
		noi di _skip(1) "|             |"  _skip(3) "|             |"
		noi di _skip(1) "|             |"  _skip(3) "|             |"
		noi di _skip(1) "|           `=`d1''|" _skip(3) "|             |"
		noi di _skip(1) "---------------" _skip(3) "---------------"
		*---p1 & p2---*
		noi di in g "     "
		noi di in g "PLAYER (`c(username)'):  "
		noi di _skip(1) "---------------" _skip(3) "---------------"
		noi di _skip(1) "|`=`p1''           |" _skip(3) "|`=`p2''           |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|           `=`p1''|" _skip(3) "|            `=`p2''|"
		noi di _skip(1) "---------------" _skip(3) "---------------"
		di in g "{ul:Suits}: Diamond(`=char(215)'); Club(`=char(189)'); Spade(`=char(198)'); Heart(`=char(207)')"
		di in g as smcl "{hline}"
			***add it up***
			loc playertotal = `=a`p1'' + `=a`p2''
			****di in red "`=a`p1'' :: `playertotal'"
				
					**check for initial 21**
					if "`playertotal'" == "21" {
									*---REVEAL:  d1 & d2---*
									di in g as smcl "{hline}"
									noi di in y "DEALER CARDS:  "
									noi di _skip(1) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|"
									noi di _skip(1) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
							di  _col(20) "BLACKJACK!!!  (Total=21), `c(username)' WINS"
									**SETTLE BET (1 1/2 times bet)**
									global bet = $bet * 1.5
									global BJCASH_TTOTAL = $BJCASH_TTOTAL + $bet
									noi di in white  _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
									di as smcl _col(2) " " _n
							exit
					}

			***player decision**
			noi di "HIT(H) or STAND(S)??", _request(answer1)   
					**check answer**
					if !inlist("$answer1", "H", "S", "h", "s") {
				 		noi di in red `"You must type the "H" or "S" key into the Command Window and Press Return."'
				 		noi di "HIT(H) or STAND(S)??", _request(answer1)   
				 		}
			
			
			

		
**********************player HITS****************************
	
		**p3-p5**
if `"$answer1"' == "H" | `"$answer1"' == "h" {
	**HIT 3RD CARD**
		*---report d1---*
		di in g as smcl "{hline}"
		noi di in y "DEALER:  "
		noi di _skip(1) "---------------" _skip(3) "---------------"
		noi di _skip(1) "|`=`d1''           |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
		noi di _skip(1) "|             |"  _skip(3) "|             |"
		noi di _skip(1) "|             |"  _skip(3) "|             |"
		noi di _skip(1) "|           `=`d1''|" _skip(3) "|             |"
		noi di _skip(1) "---------------" _skip(3) "---------------"
		
		*---p3---*
		noi di in g "     "
		di in g as smcl "{hline}"
		noi di in g "PLAYER (`c(username)') HITS ONCE:  "
		noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------"
		noi di _skip(1) "|`=`p1''           |" _skip(3) "|`=`p2''           |" _skip(3) "|`=`p3''          |"
		noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
		noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|           `=`p1''|" _skip(3) "|           `=`p2''|" _skip(3) "|           `=`p3''|"
		noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------"
		di in g "{ul:Suits}: Diamond(`=char(215)'); Club(`=char(189)'); Spade(`=char(198)'); Heart(`=char(207)')"
		di in g as smcl "{hline}"
			**ADDITUP**											
			loc playertotal = `=a`p1'' + `=a`p2'' + `=a`p3''
				**check for ace pushing over 21**
				if `playertotal' > 21 {
					loc pone `=a`p1''
					if `pone' == 11 loc pone 1
					loc ptwo `=a`p2''
					if `ptwo' == 11 loc ptwo 1
					loc pthree `=a`p3''
					if `pthree' == 11 loc pthree 1
					loc playertotal = `pone' + `ptwo' + `pthree'
							}
				*******************************	
			 		***check for 21**
						if "`playertotal'" == "21" {
									*---REVEAL:  d1 & d2---*
									di in g as smcl "{hline}"
									noi di in y "DEALER's CARDS:  "
									noi di _skip(1) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|"
									noi di _skip(1) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
							di  _col(20) "`c(username)' WINS (Total=21)"
									**SETTLE BET**
									global BJCASH_TTOTAL = $BJCASH_TTOTAL + $bet
									noi di in white  _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
						exit
					}
				***check for bust***
				if `playertotal' > 21 {
									*---REVEAL:  d1 & d2---*
									di in g as smcl "{hline}"
									noi di in y "DEALER's CARDS:  "
									noi di _skip(1) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|"
									noi di _skip(1) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
				noi di _col(20)  "`c(username)' Busts (Total= `playertotal')"
				noi di  _col(20) "Dealer WINS!!"
						**SETTLE BET**
						global BJCASH_TTOTAL = $BJCASH_TTOTAL - $bet
						noi di in white  _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
						di as smcl _col(2) " " _n
				exit
				}
		***player decision**
		noi di "HIT(H) or STAND(S)??", _request(answer1)   
		**check answer**
		if !inlist("$answer1", "H", "S", "h", "s") {
		noi di in red `"You must type the "H" or "S" key into the Command Window and Press Return."'
		noi di "HIT(H) or STAND(S)??", _request(answer1)   
		 		}			
		 		
		 		**PLAYER HIT 4TH CARD**			
					if `"$answer1"' == "H" | `"$answer1"' == "h" {
					*---report d1---*
					di in g as smcl "{hline}"
					noi di in y "DEALER:  "
					noi di _skip(1) "---------------" _skip(3) "---------------"
					noi di _skip(1) "|`=`d1''           |" _skip(3) "|             |"
					noi di _skip(1) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
					noi di _skip(1) "|             |"  _skip(3) "|             |"
					noi di _skip(1) "|             |"  _skip(3) "|             |"
					noi di _skip(1) "|           `=`d1''|" _skip(3) "|             |"
					noi di _skip(1) "---------------" _skip(3) "---------------"
					
					*---p4---*
					noi di in g "     "
					di in g as smcl "{hline}"
					noi di in g "PLAYER (`c(username)') HITS TWICE:  "
					noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
					noi di _skip(1) "|`=`p1''           |" _skip(3) "|`=`p2''            |" _skip(3) "|`=`p3''           |"  _skip(3) "|`=`p4''           |"
					noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
					noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|           `=`p1''|" _skip(3) "|            `=`p2''|" _skip(3) "|           `=`p3''|"  _skip(3) "|           `=`p4''|"
					noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
					di in g "{ul:Suits}: Diamond(`=char(215)'); Club(`=char(189)'); Spade(`=char(198)'); Heart(`=char(207)')"
					di in g as smcl "{hline}"
						**ADDITUP**											
						loc playertotal = `=a`p1'' + `=a`p2'' + `=a`p3''  + `=a`p4''
							**check for ace pushing over 21**
							if `playertotal' > 21 {
								loc pone `=a`p1''
								if `pone' == 11 loc pone 1
								loc ptwo `=a`p2''
								if `ptwo' == 11 loc ptwo 1
								loc pthree `=a`p3''
								if `pthree' == 11 loc pthree 1
								loc pfour `=a`p4''
								if `pfour' == 11 loc pfour 1								
								loc playertotal = `pone' + `ptwo' + `pthree' + `pfour'
										}
								*******************************	
								***check for bust***
								if `playertotal' > 21 {
									*---REVEAL:  d1 & d2---*
									di in g as smcl "{hline}"
									noi di in y "DEALER's CARDS:  "
									noi di _skip(1) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|"
									noi di _skip(1) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
								noi di  _col(20) "`c(username)' Busts (Total= `playertotal')"
								noi di  _col(20) "Dealer WINS!!"
									**SETTLE BET**
									global BJCASH_TTOTAL = $BJCASH_TTOTAL - $bet
									noi di in white  _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
									di as smcl _col(2) " " _n
								exit
								}
							 	***check for 21**
								if "`playertotal'" == "21" {
									di  _col(20) "`c(username)' WINS (Total=21)"
									**SETTLE BET**
									global BJCASH_TTOTAL = $BJCASH_TTOTAL + $bet
									noi di in white _col(20)  "`c(username)' has \$ $BJCASH_TTOTAL"
									di as smcl _col(2) " " _n
									exit
								   }
				***player decision**
				noi di "HIT(H) or STAND(S)??", _request(answer1)   
				**check answer**
				if !inlist("$answer1", "H", "S", "h", "s") {
				noi di in red `"You must type the "H" or "S" key into the Command Window and Press Return."'
				noi di "HIT(H) or STAND(S)??", _request(answer1)   
				 		}			
		 		
		 		
		 		**PLAYER HIT 5TH CARD**			
					if `"$answer1"' == "H" | `"$answer1"' == "h" {
					*---report d1---*
					di in g as smcl "{hline}"
					noi di in y "DEALER:  "
					noi di _skip(1) "---------------" _skip(3) "---------------"
					noi di _skip(1) "|`=`d1''           |" _skip(3) "|             |"
					noi di _skip(1) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
					noi di _skip(1) "|             |"  _skip(3) "|             |"
					noi di _skip(1) "|             |"  _skip(3) "|             |"
					noi di _skip(1) "|           `=`d1''|" _skip(3) "|             |"
					noi di _skip(1) "---------------" _skip(3) "---------------"
					
					*---p5---*
					noi di in g "     "
					di in g as smcl "{hline}"
					noi di in g "PLAYER (`c(username)') FINAL HIT:  "
					noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
					noi di _skip(1) "|`=`p1''           |" _skip(3) "|`=`p2''            |" _skip(3) "|`=`p3''           |"  _skip(3) "|`=`p4''            |" _skip(3) "|`=`p5''            |"
					noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
					noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
					noi di _skip(1) "|           `=`p1''|" _skip(3) "|            `=`p2''|" _skip(3) "|            `=`p3''|"  _skip(3) "|            `=`p4''|" _skip(3) "|            `=`p5''|"
					noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
					di in g "{ul:Suits}: Diamond(`=char(215)'); Club(`=char(189)'); Spade(`=char(198)'); Heart(`=char(207)')"
					di in g as smcl "{hline}"
						**ADDITUP**											
						loc playertotal = `=a`p1'' + `=a`p2'' + `=a`p3''  + `=a`p4'' + `=a`p5''
							**check for ace pushing over 21**
							if `playertotal' > 21 {
								loc pone `=a`p1''
								if `pone' == 11 loc pone 1
								loc ptwo `=a`p2''
								if `ptwo' == 11 loc ptwo 1
								loc pthree `=a`p3''
								if `pthree' == 11 loc pthree 1
								loc pfour `=a`p4''
								if `pfour' == 11 loc pfour 1								
								loc pfive `=a`p5''
								if `pfive' == 11 loc pfive 1
								loc playertotal = `pone' + `ptwo' + `pthree' + `pfour' + `pfive'
										}
								*******************************	
								***check for bust***
								if `playertotal' > 21 {
									*---REVEAL:  d1 & d2---*
									di in g as smcl "{hline}"
									noi di in y "DEALER's CARDS:  "
									noi di _skip(1) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|"
									noi di _skip(1) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
								noi di  _col(20) "`c(username)' Busts (Total= `playertotal')"
								noi di  _col(20) "Dealer WINS!!"
									**SETTLE BET**
									global BJCASH_TTOTAL = $BJCASH_TTOTAL - $bet
									noi di in white  _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
									di as smcl _col(2) " " _n
									exit
								}
							 	***check for 21 or less**
								if `playertotal' <= "21" {
									di  _col(20) "`c(username)' wins with 5 cards (Total=`playertotal')"
									**SETTLE BET**
									global BJCASH_TTOTAL = $BJCASH_TTOTAL + $bet
									noi di in white  _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
									di as smcl _col(2) " " _n
									exit
								   }				
								global answer2 s
						
		}  //THIRD HIT BRACKET			
	}  //SECOND HIT BRACKET
}  //FIRST HIT BRACKET

	
				 		
**********************player STANDS****************************
if `"$answer1"' == "S" | `"$answer1"' == "s" | `"$answer2"' == "s" {
				noi di in g "---> PLAYER STANDS"
				sleep 500
				//note:  d2-d5 (automatic)//
					
					*---d1 & d2---*
		di in g as smcl "{hline}"
		di in g as smcl "{hline}"
		di in g as smcl "{hline}"
		noi di in y "DEALER's CARDS:  "
		noi di _skip(1) "---------------" _skip(3) "---------------"
		noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|             |" _skip(3) "|             |"
		noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
		noi di _skip(1) "|             |"  _skip(3) "|             |"
		noi di _skip(1) "|             |"  _skip(3) "|             |"
		noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|"
		noi di _skip(1) "---------------" _skip(3) "---------------"
		di in g as smcl "{hline}"
			**ADDITUP**
			loc dealertotal = `=a`d1'' + `=a`d2''
			sleep 1500
				if `dealertotal' < `playertotal' {
				**additional cards for dealer??**
					if `dealertotal' < 14 | (`dealertotal' < `playertotal' & `dealertotal' < 19) {
											*---d1/d2 + d3---*
									noi di in y "DEALER HITS...  "
									noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''           |" _skip(3) "|`=`d3''          |"
									noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|           `=`d2''|" _skip(3) "|           `=`d3''|"
									noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
										**ADDITUP**											
										loc dealertotal = `=a`d1'' + `=a`d2'' + `=a`d3'' 
													**check for ace pushing over 21**
													if `dealertotal' > 21 {
														loc one `=a`d1''
														if `one' == 11 loc one 1
														loc two `=a`d2''
														if `two' == 11 loc two 1
														loc three `=a`d3''
														if `three' == 11 loc three 1
													loc dealertotal = `one' + `two' + `three'
															}
													*******************************			
										sleep 1500
							}
					if `dealertotal' < 14 | (`dealertotal' < `playertotal' & `dealertotal' < 19)   {
											*---d1/d2 + d3 + d4---*
									noi di in y "DEALER HITS...  "
									noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |" _skip(3) "|`=`d3''           |"  _skip(3) "|`=`d4''           |"
									noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|" _skip(3) "|           `=`d3''|"  _skip(3) "|           `=`d4''|"
									noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
										**ADDITUP**
										loc dealertotal = `=a`d1'' + `=a`d2'' + `=a`d3'' + `=a`d4''
												**check for ace pushing over 21**
													if `dealertotal' > 21 {
														loc one `=a`d1''
														if `one' == 11 loc one 1
														loc two `=a`d2''
														if `two' == 11 loc two 1
														loc three `=a`d3''
														if `three' == 11 loc three 1
														loc four `=a`d4''
														if `four' == 11 loc four 1
													loc dealertotal = `one' + `two' + `three' + `four'
															}
													*******************************	
										sleep 2200
								}
					if `dealertotal' < 14  | (`dealertotal' < `playertotal' & `dealertotal' < 19)  {
											*---d1/d2 + d3 + d4---*
									noi di in y "DEALER HITS...  "
									noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
									noi di _skip(1) "|`=`d1''           |" _skip(3) "|`=`d2''            |" _skip(3) "|`=`d3''           |"  _skip(3) "|`=`d4''            |" _skip(3) "|`=`d5''            |"
									noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |" _skip(3) "|   {{ul:Stata}}   |"
									noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|             |"  _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |" _skip(3) "|             |"
									noi di _skip(1) "|           `=`d1''|" _skip(3) "|            `=`d2''|" _skip(3) "|            `=`d3''|"  _skip(3) "|            `=`d4''|" _skip(3) "|            `=`d5''|"
									noi di _skip(1) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------" _skip(3) "---------------"
									di in g as smcl "{hline}"
										**ADDITUP**
										loc dealertotal = `=a`d1'' + `=a`d2'' + `=a`d3'' + `=a`d4'' + `=a`d5''
												**check for ace pushing over 21**
													if `dealertotal' > 21 {
														loc one `=a`d1''
														if `one' == 11 loc one 1
														loc two `=a`d2''
														if `two' == 11 loc two 1
														loc three `=a`d3''
														if `three' == 11 loc three 1
														loc four `=a`d4''
														if `four' == 11 loc four 1
														loc five `=a`d5''
														if `five' == 11 loc five 1
													loc dealertotal = `one' + `two' + `three' + `four' + `five'
															}
													*******************************	
												sleep 1500
					}
			}		
	}
		
		
		
		


***********************************
**GAME RESULTS AFTER BUST OR STAND**
di as smcl " " _n
											*di in r "`dealertotal' |  `playertotal'"
if `dealertotal' > `playertotal' & `dealertotal' <= 21 {
	noi di _col(20) "Dealer=`dealertotal', Player=`playertotal'"
	noi di _col(20) "DEALER WINS!!"
		**SETTLE BET**
		global BJCASH_TTOTAL = $BJCASH_TTOTAL - $bet
		noi di in white _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
	exit
	}
if `dealertotal' > 21 {
	noi di _col(20) "Dealer Busts (Total= `dealertotal')"
	noi di _col(20) "`c(username)' WINS!! (Total = `playertotal')"
			**SETTLE BET**
			global BJCASH_TTOTAL = $BJCASH_TTOTAL + $bet
			noi di in white _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
	exit
	}
if `dealertotal' < `playertotal' {
	noi di _col(20) "Dealer=`dealertotal', Player=`playertotal'"
	noi di _col(20) "`c(username)' WINS!!"
			**SETTLE BET**
			global BJCASH_TTOTAL = $BJCASH_TTOTAL + $bet
			noi di in white _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
	exit
	}		
if `dealertotal' == `playertotal' & `dealertotal' < 21 & `playertotal' < 21 {
	noi di _col(20) "Dealer=`dealertotal', Player=`playertotal'"
	noi di _col(20) "PUSH"
				**SETTLE BET**
			**global BJCASH_TTOTAL = $BJCASH_TTOTAL - $bet
			noi di in white _col(20) "`c(username)' has \$ $BJCASH_TTOTAL"
}
di as smcl _col(2) " " _n
*******************************			
**restore environ conditions**
set rmsg `rm'
restore
end



