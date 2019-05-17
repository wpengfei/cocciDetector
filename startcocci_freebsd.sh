 
testdir='testdir'
outcome1='freebsd_RR_outcome'
outcome2='freebsd_WR_outcome'
outcome3='freebsd_RW_outcome'

resultfile1='freebsd_RR_result.txt'
resultfile2='freebsd_WR_result.txt'
resultfile3='freebsd_RW_result.txt'


if ! test -d ${testdir}
then 
	mkdir ${testdir}
	echo Make ${testdir}...
fi


#-------------------------------- RR
if test -d ${outcome1}
then 
	rm -rf ${outcome1}/
	mkdir ${outcome1}
	echo Remove old ${outcome1} files...
else
	mkdir ${outcome1}
	echo Make ${outcome1} dir...
fi

if test -f ${resultfile1}
then 
	rm ${resultfile1}
	touch ${resultfile1}
	echo Remove ${resultfile1}...
else
	touch ${resultfile1}
	echo Make ${resultfile1} file...
fi

echo Start analyzing...
spatch -cocci_file src/freebsd_RR.cocci  -dir ${testdir}
#--disable-worth-trying-opt

python src/copy_files.py ${outcome1}"/" ${resultfile1}

echo Finished analyzing RR "type".


#-------------------------------- WR
if test -d ${outcome2}
then 
	rm -rf ${outcome2}/
	mkdir ${outcome2}
	echo Remove old ${outcome2} files...
else
	mkdir ${outcome2}
	echo Make ${outcome2} dir...
fi

if test -f ${resultfile2}
then 
	rm ${resultfile2}
	touch ${resultfile2}
	echo Remove ${resultfile2}...
else
	touch ${resultfile2}
	echo Make ${resultfile2} file...
fi

echo Start analyzing...
spatch -cocci_file src/freebsd_WR.cocci -dir ${testdir}
#--disable-worth-trying-opt

python src/copy_files.py ${outcome2}"/" ${resultfile2}

echo Finished analyzing WR "type".


#-------------------------------- RW
if test -d ${outcome3}
then 
	rm -rf ${outcome3}/
	mkdir ${outcome3}
	echo Remove old ${outcome3} files...
else
	mkdir ${outcome3}
	echo Make ${outcome3} dir...
fi

if test -f ${resultfile3}
then 
	rm ${resultfile3}
	touch ${resultfile3}
	echo Remove ${resultfile3}...
else
	touch ${resultfile3}
	echo Make ${resultfile3} file...
fi

echo Start analyzing...
spatch -cocci_file src/freebsd_RW.cocci -dir ${testdir}
#--disable-worth-trying-opt

python src/copy_files.py ${outcome3}"/" ${resultfile3}

echo Finished analyzing RW "type".






