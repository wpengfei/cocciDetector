 
outcome1='linux_RR_outcome'
outcome2='linux_WR_outcome'
outcome3='linux_RW_outcome'

resultfile1='linux_RR_result.txt'
resultfile2='linux_WR_result.txt'
resultfile3='linux_RW_result.txt'

#-------------------------------- RR
if test -d ${outcome1}
then 
	rm -rf ${outcome1}/
	echo Remove ${outcome1} files...
fi

if test -f ${resultfile1}
then 
	rm ${resultfile1}
	echo Remove ${resultfile1}...

fi

#-------------------------------- WR
if test -d ${outcome2}
then 
	rm -rf ${outcome2}/
	echo Remove ${outcome2} files...
fi

if test -f ${resultfile2}
then 
	rm ${resultfile2}
	echo Remove ${resultfile2}...
fi

#-------------------------------- RW
if test -d ${outcome3}
then 
	rm -rf ${outcome3}/
	echo Remove ${outcome3} files...
fi

if test -f ${resultfile3}
then 
	rm ${resultfile3}
	echo Remove ${resultfile3}...
fi

 
outcome1='freebsd_RR_outcome'
outcome2='freebsd_WR_outcome'
outcome3='freebsd_RW_outcome'

resultfile1='freebsd_RR_result.txt'
resultfile2='freebsd_WR_result.txt'
resultfile3='freebsd_RW_result.txt'

#-------------------------------- RR
if test -d ${outcome1}
then 
	rm -rf ${outcome1}/
	echo Remove ${outcome1} files...
fi

if test -f ${resultfile1}
then 
	rm ${resultfile1}
	echo Remove ${resultfile1}...

fi

#-------------------------------- WR
if test -d ${outcome2}
then 
	rm -rf ${outcome2}/
	echo Remove ${outcome2} files...
fi

if test -f ${resultfile2}
then 
	rm ${resultfile2}
	echo Remove ${resultfile2}...
fi

#-------------------------------- RW
if test -d ${outcome3}
then 
	rm -rf ${outcome3}/
	echo Remove ${outcome3} files...
fi

if test -f ${resultfile3}
then 
	rm ${resultfile3}
	echo Remove ${resultfile3}...
fi












