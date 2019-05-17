//define global variable
@initialize:python@
@@

count = 0

#-----------------------------Post Matching Process------------------------------
def print_and_log(filename,first,second,count):
	
	print "No. ", count, " file: ", filename
	print "--first fetch: line ",first
	print "--second fetch: line ",second
	#print "------------------------------------\n"

	logfile = open('freebsd_WR_result.txt','a')
	logfile.write("No." + count + " File: \n" + str(filename) + "\n")
	logfile.write("--first write: line " + str(first) + "\n")
	logfile.write("--second read: line " + str(second) + "\n")
	logfile.write("-------------------------------\n")
	
	logfile.close()

def post_match_process(p1,p2,usr,alias):
	global count

	filename = p1[0].file
	first = p1[0].line
	second = p2[0].line

	usr_str = str(usr)
	alias_str = str(alias)
	#print "usr1:", usr_str
	#print "usr2:", alias_str
	#print "first:", first
	#print "second:", second

	# remove loop case, first and second fetch are not supposed to be in the same line.
	if first == second: 
		return
	# remove reverse loop case, where first fetch behand second fetch but in last loop .
	if int(first) > int(second):
		return
	# remove case of get_user(a, usr++) or get_user(a, usr + 4)
	if usr_str.find("+") != -1 or alias_str.find("+") != -1:
		return
	# remove case of get_user(a, usr[i]) 
	if usr_str.find("[") != -1 or alias_str.find("[") != -1:
		return 
	# remove case of get_user(a, usr--) or get_user(a, usr - 4)
	if usr_str.find("-") != -1 and usr_str.find("->") == -1:
		return
	if alias_str.find("-") != -1 and alias_str.find("->") == -1:
		return
	# remove false matching of usr ===> (int*)usr , but leave function call like u64_to_ualias(ctl_sccb.sccb)
	if usr_str.find("(") == 0 or alias_str.find("(") == 0:
		return

	print_and_log(filename, first, second, str(count))
	count +=1
	return 
	


//---------------------Pattern Matching Rules-----------------------------------
//----------------------------------- case 1: normal case without usr assignment
@ rule1 disable drop_cast exists @
expression addr,exp1,exp2,usr,size1,size2,offset;
position p1,p2;
identifier func;
type T1,T2;
@@
	func(...){
	...	
(
	put_user(exp1, (T1)usr)@p1
|
	put_user(exp1, usr)@p1	
|
	__put_user(exp1, (T1)usr)@p1
|	
	__put_user(exp1, usr)@p1
|
	copyout(exp1, (T1)usr, size1)@p1
|
	copyout(exp1, usr, size1)@p1
|
	copyout_nofault(exp1, (T1)usr, size1)@p1
|
	copyout_nofault(exp1, usr, size1)@p1

)
	...	when any
		when != usr += offset	
		when != usr = usr + offset
		when != usr++
		when != usr -=offset
		when != usr = usr - offset
		when != usr--
		when != usr = addr
		
(
	get_user(exp2, (T2)usr)@p2
|
	get_user(exp2, usr)@p2
|
	__get_user(exp2, (T2)usr)@p2
|
	__get_user(exp2, usr)@p2
|
	__copy_from_user(exp2, (T2)usr, size2)@p2
|
	__copy_from_user(exp2, usr, size2)@p2
|
	copy_from_user(exp2, (T2)usr, size2)@p2
|
	copy_from_user(exp2, usr, size2)@p2
)	
	...
	}

@script:python@
p11 << rule1.p1;
p12 << rule1.p2;
s1 << rule1.usr;
@@

#print "usr1:", str(s1)
if p11 and p12:
	#coccilib.report.print_report(p11[0],"rule1 First write")
	#coccilib.report.print_report(p12[0],"rule1 Second read")

	post_match_process(p11, p12, s1, s1)
	
//--------------------------------------- case 2: alias = usr at beginning, alias first
@ rule2 disable drop_cast exists @
identifier func;
expression addr,exp1,exp2,usr,alias,size1,size2,offset;
position p0,p1,p2;
type T0,T1,T2;
@@


	func(...){
	...	
(
	alias = (T0)usr@p0 // potential assignment case
|
	alias = usr@p0
)
	... 
(
	put_user(exp1, (T1)alias)@p1
|
	put_user(exp1, alias)@p1
|
	__put_user(exp1, (T1)alias)@p1
|
	__put_user(exp1, alias)@p1
|
	copyout(exp1, (T1)alias, size1)@p1
|
	copyout(exp1, alias, size1)@p1
|
	copyout_nofault(exp1, (T1)alias, size1)@p1
|
	copyout_nofault(exp1, alias, size1)@p1
)
	...	
	when != usr += offset
	when != usr = usr + offset
	when != usr++
	when != usr -=offset
	when != usr = usr - offset
	when != usr--
	when != usr = addr
(
	get_user(exp2, (T2)usr)@p2
|
	get_user(exp2, usr)@p2
|
	__get_user(exp2, (T2)usr)@p2
|
	__get_user(exp2, usr)@p2
|
	__copy_from_user(exp2, (T2)usr, size2)@p2
|
	__copy_from_user(exp2, usr, size2)@p2
|
	copy_from_user(exp2, (T2)usr, size2)@p2
|
	copy_from_user(exp2, usr, size2)@p2
)
	... 
	}

@script:python@
p21 << rule2.p1;
p22 << rule2.p2;
p2 << rule2.alias;
s2 << rule2.usr;
@@
#print "usr2:", str(s2)
#print "alias2:", str(p2)
if p21 and p22:
	#coccilib.report.print_report(p21[0],"rule2 First write")
	#coccilib.report.print_report(p22[0],"rule2 Second read")
	post_match_process(p21, p22, s2, p2)
	

//--------------------------------------- case 3: alias = usr at beginning, usr first
@ rule3 disable drop_cast exists @
identifier func;
expression addr,exp1,exp2,usr,alias,size1,size2,offset;
position p0,p1,p2;
type T0,T1,T2;
@@


	func(...){
	...	
(
	alias = (T0)usr@p0 // potential assignment case
|
	alias = usr@p0
)
	... 
(
	put_user(exp1, (T1)usr)@p1
|
	put_user(exp1, usr)@p1
|
	__put_user(exp1, (T1)usr)@p1
|
	__put_user(exp1, usr)@p1
|
	copyout(exp1, (T1)usr, size1)@p1
|
	copyout(exp1, usr, size1)@p1
|
	copyout_nofault(exp1, (T1)usr, size1)@p1
|
	copyout_nofault(exp1, usr, size1)@p1
)
	...	
	when != alias += offset
	when != alias = alias + offset
	when != alias++
	when != alias -=offset
	when != alias = alias - offset
	when != alias--
	when != alias = addr
(
	get_user(exp2, (T2)alias)@p2
|
	get_user(exp2, alias)@p2
|
	__get_user(exp2,(T2)alias)@p2
|
	__get_user(exp2, alias)@p2
|
	__copy_from_user(exp2, (T2)alias, size2)@p2
|
	__copy_from_user(exp2, alias, size2)@p2
|
	copy_from_user(exp2, (T2)alias, size2)@p2
|
	copy_from_user(exp2, alias, size2)@p2
)
	... 
	}

@script:python@
p31 << rule3.p1;
p32 << rule3.p2;
p3 << rule3.alias;
s3 << rule3.usr;
@@
#print "usr3:", str(s3)
#print "alias3:", str(p3)
if p31 and p32:
	#coccilib.report.print_report(p31[0],"rule3 First write")
	#coccilib.report.print_report(p32[0],"rule3 Second read")
	post_match_process(p31, p32, s3, p3)
	
//----------------------------------- case 4: alias = usr at middle

@ rule4 disable drop_cast exists @
identifier func;
expression addr,exp1,exp2,usr,alias,size1,size2,offset;
position p0,p1,p2;
type T0,T1,T2;
@@


	func(...){
	...	
(
	put_user(exp1, (T1)usr)@p1
|
	put_user(exp1, usr)@p1
|
	__put_user(exp1, (T1)usr)@p1
|
	__put_user(exp1, usr)@p1
|
	copyout(exp1, (T1)usr, size1)@p1
|
	copyout(exp1, usr, size1)@p1
|
	copyout_nofault(exp1, (T1)usr, size1)@p1
|
	copyout_nofault(exp1, usr, size1)@p1
)
	...	
	when != usr += offset
	when != usr = usr + offset
	when != usr++
	when != usr -=offset
	when != usr = usr - offset
	when != usr--
	when != usr = addr

(
	alias = (T0)usr@p0 // potential assignment case
|
	alias = usr@p0
)
	... 
	when != alias += offset
	when != alias = alias + offset
	when != alias++
	when != alias -=offset
	when != alias = alias - offset
	when != alias--
	when != alias = addr

(
	get_user(exp2, (T2)alias)@p2
|
	get_user(exp2, alias)@p2
|
	__get_user(exp2, (T2)alias)@p2
|
	__get_user(exp2, alias)@p2
|
	__copy_from_user(exp2, (T2)alias, size2)@p2
|
	__copy_from_user(exp2, alias, size2)@p2
|
	copy_from_user(exp2, (T2)alias, size2)@p2
|
	copy_from_user(exp2, alias, size2)@p2
)
	... 
	}

@script:python@
p41 << rule4.p1;
p42 << rule4.p2;
p4 << rule4.alias;
s4 << rule4.usr;
@@
#print "usr4:", str(s4)
#print "alias4:", str(p4)
if p41 and p42:
	#coccilib.report.print_report(p41[0],"rule4 First write")
	#coccilib.report.print_report(p42[0],"rule4 Second read")
	post_match_process(p41, p42, s4, p4)
	


//----------------------------------- case 5: first element, then alias, copy from structure
@ rule5 disable drop_cast exists @
identifier func, e1;
expression addr,exp1,exp2,usr,size1,size2,offset;
position p1,p2;
type T1,T2;
@@


	func(...){
	...	
(
	put_user(exp1, (T1)usr->e1)@p1
|
	put_user(exp1, usr->e1)@p1
|
	put_user(exp1, &(usr->e1))@p1
|
	__put_user(exp1, (T1)usr->e1)@p1
|
	__put_user(exp1, usr->e1)@p1
|
	__put_user(exp1, &(usr->e1))@p1
|
	copyout(exp1, (T1)usr->e1, size1)@p1
|
	copyout(exp1, usr->e1, size1)@p1
|
	copyout(exp1, &(usr->e1), size1)@p1
|
	copyout_nofault(exp1, (T1)usr->e1, size1)@p1
|
	copyout_nofault(exp1, usr->e1, size1)@p1
|
	copyout_nofault(exp1, &(usr->e1), size1)@p1
)
	...	
	when != usr += offset
	when != usr = usr + offset
	when != usr++
	when != usr -=offset
	when != usr = usr - offset
	when != usr--
	when != usr = addr
(
	get_user(exp2, (T2)usr)@p2
|
	get_user(exp2, usr)@p2
|
	__get_user(exp2, (T2)usr)@p2
|
	__get_user(exp2, usr)@p2
|
	__copy_from_user(exp2, (T2)usr, size2)@p2
|
	__copy_from_user(exp2, usr, size2)@p2
|
	copy_from_user(exp2, (T2)usr, size2)@p2
|
	copy_from_user(exp2, usr, size2)@p2
)
	... 
	}

@script:python@
p51 << rule5.p1;
p52 << rule5.p2;
s5 << rule5.usr;
e5 << rule5.e1;
@@
#print "usr5:", str(s5)
#print "e5:", str(e5)
if p51 and p52:
	#coccilib.report.print_report(p51[0],"rule5 First write")
	#coccilib.report.print_report(p52[0],"rule5 Second read")
	post_match_process(p51, p52, s5, e5)
	

//----------------------------------- case 6: first element, then alias, copy from pointer
@ rule6 disable drop_cast exists @
identifier func, e1;
expression addr,exp1,exp2,usr,size1,size2,offset;
position p1,p2;
type T1,T2;
@@
	func(...){
	...	
(
	put_user(exp1, (T1)usr.e1)@p1
|
	put_user(exp1, usr.e1)@p1
|
	put_user(exp1, &(usr.e1))@p1
|
	__put_user(exp1, (T1)usr.e1)@p1
|
	__put_user(exp1, usr.e1)@p1
|
	__put_user(exp1, &(usr.e1))@p1
|
	copyout(exp1, (T1)usr.e1, size1)@p1
|
	copyout(exp1, usr.e1, size1)@p1
|
	copyout(exp1, &(usr.e1), size1)@p1
|
	copyout_nofault(exp1, (T1)usr.e1, size1)@p1
|
	copyout_nofault(exp1, usr.e1, size1)@p1
|
	copyout_nofault(exp1, &(usr.e1), size1)@p1
)
	...	
	when != &usr += offset
	when != &usr = &usr + offset
	when != &usr++
	when != &usr -=offset
	when != &usr = &usr - offset
	when != &usr--
	when != &usr = &addr
(
	get_user(exp2, (T2)&usr)@p2
|
	get_user(exp2, &usr)@p2
|
	__get_user(exp2, (T2)&usr)@p2
|
	__get_user(exp2, &usr)@p2
|
	__copy_from_user(exp2, (T2)&usr, size2)@p2
|
	__copy_from_user(exp2, &usr, size2)@p2
|
	copy_from_user(exp2, (T2)&usr, size2)@p2
|
	copy_from_user(exp2, &usr, size2)@p2
)
	... 
	}

@script:python@
p61 << rule6.p1;
p62 << rule6.p2;
s6 << rule6.usr;
e6 << rule6.e1;
@@
#print "usr6:", str(s6)
#print "e6:", str(e6)
if p61 and p62:
	#coccilib.report.print_report(p61[0],"rule6 First write")
	#coccilib.report.print_report(p62[0],"rule6 Second read")
	post_match_process(p61, p62, s6, e6)
	


