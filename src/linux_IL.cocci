//define global variable
@initialize:python@
@@

count = 0

#-----------------------------Post Matching Process------------------------------
def print_and_log(filename,first,second):
	global count
	count = count + 1

	print "No. ", count, " file: ", filename
	print "--malloc: line ",first
	print "--copy: line ",second
	#print "------------------------------------\n"

	logfile = open('linux_IL_result.txt','a')
	logfile.write("No." + str(count) + " File: \n" + str(filename) + "\n")
	logfile.write("--malloc: line " + str(first) + "\n")
	logfile.write("--copy: line " + str(second) + "\n")
	logfile.write("-------------------------------\n")
	
	logfile.close()
	


@ rule1 @
expression kbuf,user,size;
position p1,p2;
identifier func;
type T1,T2;
@@
	func(...){
	...	
(
	kbuf = kmalloc(...)@p1
|
	kbuf = vmalloc(...)@p1
|
	kbuf = kmem_cache_alloc(...)@p1
|
	kbuf = kmem_cache_create(...)@p1 	
)
	...	when any


	copy_to_user(user, kbuf, size)@p2


	...
}

@script:python@
p1 << rule1.p1;
p2 << rule1.p2;
s1 << rule1.kbuf;
@@

#print "usr1:", str(s1)
if p1 and p2:
	coccilib.report.print_report(p1[0],"rule1 malloc")
	coccilib.report.print_report(p2[0],"rule1 copy")
	print_and_log(p1[0].file, p1[0].line, p2[0].line)
	


