import sys

# explore all the files to get the common prefix, 
# which is the max length of the identical part of the file path from the root directory
def get_prefix(f):
	array = []
	prefix = ""

	handler = open(f,"r")
	if not handler:
		print "Open file error!"
		return

	while True:
		item = handler.readline()
		if not item:
			break
		elif item[0] == 'N' and item[1] == 'o' and item[2] == '.':
			pass
		elif item[0] == '-' and item[1] == '-':
			pass
		else:
			array.append(item)
	#print array
	l = len(array)
	n = len(array[0])
	for i in range(n):
		flag = 0
		for j in range(1,l):
			if array[0][i] != array[j][i]:
				flag = 1
				break

		if flag == 0 :
			prefix = prefix + array[0][i]
		else:
			print "prefix = ", prefix
			return prefix

# real_dir is the file path without the prefix part
# aka onlu the part in the kernel directoy
def get_real_dir(prefix, dire):
	l1 = len(prefix)
	l2 = len(dire)
	assert l1 < l2
	return dire[l1:-1]

#get_prefix(new_handler)



def check_oldfile(real_new_dir, new_first, new_second):
	
	
	old_handler = open(old_file,"r")
	if not old_handler:
		print "open old_file failed!"
		return 

	exist = 0
	while True:
		old_num = old_handler.readline()
		old_dir = old_handler.readline()
		old_first = old_handler.readline()
		old_second = old_handler.readline()
		line = old_handler.readline()
		'''
		print "=>", old_num
		print "=>", old_dir
		print "=>", old_first
		print "=>", old_second
		print "=>", line
		'''
		if (not old_num) or (not old_dir) or (not old_first) or (not old_second) or (not line):
			break
		else:
			real_old_dir = get_real_dir(old_prefix, old_dir)
			#print "real_old_dir=", real_old_dir

			if real_old_dir == real_new_dir and new_first == old_first and old_second == new_second:
				exist = 1

	old_handler.close()
	#print "exist", exist
	return exist

def main():
	global old_file
	global old_prefix
	count = 0
	print "->Start to filter new files."

	old_file = sys.argv[1]
	new_file = sys.argv[2]
	 
	print "old_file: ", old_file
	print "new_file: ", new_file

	old_prefix = get_prefix(old_file)
	new_prefix = get_prefix(new_file)


	new_handler = open(new_file,"r")
	if not new_handler:
		print "open new_file failed!"

	# go over the new files
	while True:
		# get the info of a result from the new_file
		new_num = new_handler.readline()
		new_dir = new_handler.readline()
		new_first = new_handler.readline()
		new_second = new_handler.readline()
		line = new_handler.readline()
		'''
		print "->", new_num
		print "->", new_dir
		print "->", new_first
		print "->", new_second
		print "->", line
		'''
		if (not new_num) or (not new_dir) or (not new_first) or (not new_second) or (not line):
			print "Finished filtering."
			break
		else:
			real_new_dir = get_real_dir(new_prefix, new_dir)
			#print "real_new_dir=", real_new_dir
			ret = check_oldfile(real_new_dir, new_first, new_second)
			#print "ret = ", ret
			if ret == 0:
				print new_num[:-1] # remove '\n'
				print new_dir[:-1]
				print new_first[:-1]
				print new_second[:-1]
				print line[:-1]
				count = count + 1
			#else:
				#print "find", real_new_dir, "from old result file"
	print "=============",count, "files remained=========="

main()










