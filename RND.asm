//----------------------------------------------------------
// RND
//
//java -jar kickass.jar RND.asm
//
//http://unusedino.de/ec64/technical/project64/mapping_c64.html
//http://www.unusedino.de/ec64/technical/misc/c64/romlisting.html
//https://github.com/OldSkoolCoder/Tutorials/blob/master/08%20-%20Tutorial%20Eight.asm
//https://www.c64-wiki.com/wiki/Main_Page
//https://www.pagetable.com/c64disasm/
//https://gist.github.com/cbmeeks/4287745eab43e246ddc6bcbe96a48c19
//https://codebase64.org/doku.php?id=base:kernal_floating_point_mathematics#movement
/*
function RND(start, end) {
    return Math.floor(Math.random() * (++end - start) + start);
  }

*/
//----------------------------------------------------------

#import "Include\LIB_SymbolTable.asm"

//------------------------DISK------------------------------

.disk [filename= "RND.d64", name = "RND"]
{
[name="RND", type="prg", segments="RND" ],
}

//------------------------BASIC-----------------------------

.segment RND []
#import "Include\LS_StandardBasicStart.asm"

//-----------------------CONST-----------------------------------

//-----------------------START------------------------------

		* = $0810 "Main"
Start:
		lda #50
		sta temp8
		
cont:	
		RandomNumber(10, 12)
		//jsr FOUT
		//PrintText($0100)
		//Console8(WINT)
		Console16(WINT)
		Comma()
		//ConsoleX()
		//EndLine()
		//Console32($8B)
		//EndLine()
		dec temp8
		bne	cont
		rts

//-----------------------SUBS-------------------------------
subs:	* = subs "Subroutines"
//------ IMPORTS ----

#import "Include\LS_ConsolePrint.asm" 	
#import "Include\LS_System.asm"

rnd_XY:
{			
//output: random number (0, 32767) in WINT; 


			//reseed, to avoid repeated sequence
			lda #00
			jsr RND
			
			//++end 
			inc ZP3
			bne skip1
			inc ZP4
skip1:
			//- start
			lda ZP3
			sec
			sbc ZP1
			sta ZP3
			lda ZP4
			sbc ZP2
			sta ZP4			
toFloat:
			ldy ZP3
			lda ZP4
			jsr GIVAYF //A(h),Y(L) - FAC
			
			ldx #<flt
			ldy #>flt
			jsr MOVMF	//store FAC to flt
				
			//get actual RND(1)
			lda #$7f
			jsr RND
			
			//multiply by ++end - start
			lda #<flt
			ldy #>flt
			jsr FMULT
			
			//to integer
			jsr FAINT
			
			//FAC to int;
			jsr AYINT
			lda $65			
			clc
			adc ZP1
			sta WINT
			lda $64
			adc ZP2
			sta WINT+1
over:
			rts
			
}

//-----------------------TEXT-------------------------------
			
//-----------------------DATA-------------------------------
data: 		* = data "Data RND"

temp8:			.byte 0
flt:			.byte 0,0,0,0,0

//-----------------------MACROS-----------------------------
.macro RandomNumber(start, end){
/*
limits: 0 - 32767
arguments: 
	start -> ZP1, lower inclusive
	end -> ZP3, upper inclusive
return: WINT: 16-bit int
*/
		lda #<end	
		sta ZP3
		lda #>end
		sta ZP4
		lda #<start
		sta ZP1
		lda #>start
		sta ZP2
		jsr rnd_XY
}

.macro SetSIDforRandom(){
		lda #$ff
		sta FV3LO
		sta FV3HI
		lda #$80
		sta CTRLREG_V3
}
