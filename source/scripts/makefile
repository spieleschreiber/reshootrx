set -e


#This one is tested. Compile from shell with command "zsh makefile"
#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source -I $AMIDEV/source/include $AMIDEV/source/copperCode/coplist.stage5.s -o $AMIDEV/uae/dh0/stage5/main5.cop

#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source -I $AMIDEV/source/include $AMIDEV/source/copperCode/coplist.stage4.s -o $AMIDEV/uae/dh0/stage4/main4.cop
#$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source -I $AMIDEV/source/include $AMIDEV/source/copperCode/coplist.stage5.s -o $AMIDEV/uae/dh0/stage5/main5.cop
	$AMIDEV/vasmm68k_mot -Fbin -nocase -quiet -m68020up -I $AMIDEV -I $AMIDEV/source -I $AMIDEV/source/include $AMIDEV/source/copperCode/coplist.stage0.s -o $AMIDEV/uae/dh0/stage0/main0.cop
	



#this compiles music track executable if not outcommented
#$AMIDEV/vasmm68k_mot -Fhunkexe -m68020up -nocase $AMIDEV/source/audioManager.s -o $AMIDEV/px.bin

#this compiles gamecode
#$AMIDEV/vasmm68k_mot -Fhunk -nocase -m68020up -opt-jbra -I $AMIDEV -I #$AMIDEV/source/system $AMIDEV/source/rrx.s -o $AMIDEV/build/rrx.o
#$AMIDEV/vlink -bamigahunk $AMIDEV/build/rrx.o -o $AMIDEV/rrx



#needed to debug visual glitch on CD32
#$AMIDEV/vasmm68k_mot -regsymredef -Fhunkexe -nocase -nosym -m68020up -opt-jbra -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/px.s -o $AMIDEV/builds/prerelease/110923/rp3.bin

#$AMIDEV/vasmm68k_mot -regsymredef -Fhunkexe -nocase -nosym -m68020up -opt-jbra -I $AMIDEV -I $AMIDEV/source/system $AMIDEV/source/px.s -o $AMIDEV/builds/beta/px.bin
# -showopt shop optimizations
# -quiet do not size of code segments
# -nosym strips symbols, reduces filesize significantly



if [ $? -eq 0 ]
then
  echo "Success, rrx is ready for launch"
 # osascript $AMIDEV/source/scripts/launchBin.scpt	#init macro to launch .bin on Amiga
  exit 0
else
  echo "Failure in source file"
  exit $!
fi


