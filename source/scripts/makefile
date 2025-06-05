set -e

compileCopperlist=0	# could be 0 or 1
compileVectorTable=0	# could 0 or 64

echo #############

if [ $compileCopperlist -ne 0 ]		# compile coplist
then
	$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.stage4.s -o	 $AMIDEV/stage0/main0.cop		# Sky Stage!
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.stage1.s -o $AMIDEV/stage1/main1.cop		# Sun Stage!
	#Needed for CD32 debugging
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.stage1.s -o $AMIDEV/builds/prerelease/100923CD/stage1/main1.cop		# Sun Stage!
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.stage2.s -o $AMIDEV/stage2/main2.cop
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.stage3.s -o $AMIDEV/stage3/main3.cop
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.bone.s -o $AMIDEV/stage4/main4.cop
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.stage5.s -o $AMIDEV/stage5/main5.cop
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.title.s -o $AMIDEV/title/title.cop
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.intro.s -o $AMIDEV/title/intro.cop

#needed to debug crash on CD32
	#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/copper/coplist.intro.s -o $AMIDEV/builds/prerelease/100923/title/intro.cop

fi


if [ $compileVectorTable -ne 0 ]		# compile bullet vector table
then
	echo "compiling bullet vector table"
	gcc $AMIDEV/source/createBulletVectorTable.c -o $AMIDEV/bulletVectorTable.exe	#compile
	chmod +x $AMIDEV/bulletVectorTable.exe	#make executable
	$AMIDEV/bulletVectorTable.exe $compileVectorTable $AMIDEV/incbin/bulletVectorTable #create table with x entries in x and y coord syste,
fi

#this compiles music track executable if not outcommented
#$AMIDEV/vasmm68k_mot -Fhunkexe -m68020up -nocase $AMIDEV/source/audioManager.s -o $AMIDEV/px.bin

#this compiles gamecode
$AMIDEV/vasmm68k_mot -Fhunk -nocase -m68020up -opt-jbra -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/rrx.s -o $AMIDEV/build/rrx.o
$AMIDEV/vlink -bamigahunk $AMIDEV/build/rrx.o -o $AMIDEV/rrx



#needed to debug visual glitch on CD32
#$AMIDEV/vasmm68k_mot -regsymredef -Fhunkexe -nocase -nosym -m68020up -opt-jbra -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/px.s -o $AMIDEV/builds/prerelease/110923/rp3.bin

#$AMIDEV/vasmm68k_mot -regsymredef -Fhunkexe -nocase -nosym -m68020up -opt-jbra -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/px.s -o $AMIDEV/builds/beta/px.bin
# -showopt shop optimizations
# -quiet do not size of code segments
# -nosym strips symbols, reduces filesize significantly



if [ $? -eq 0 ]
then
  echo "Success, rrx.o is ready for launch"
 # osascript $AMIDEV/source/scripts/launchBin.scpt	#init macro to launch .bin on Amiga
  exit 0
else
  echo "Failure in source file"
  exit $!
fi


