import sys
import os
import os.path
import shutil

class Tool:
	def __init__(self, outcome, log):
		if not os.path.exists(outcome):
			os.mkdir(outcome)
			#os.path.isfile('test.txt') 

		self.result_handler = open(log,"r")
		if not self.result_handler:
			print "open result failed!"

		self.buffer = ""

		self.outcome = outcome

		self.log = log

		self.counter = 0

	def get_dst(self, src):
		p = src.rfind('/')
		filename = src[p+1:]
		return self.outcome +str(self.counter)+"-"+filename

	def tailor(self, str): #delete '\n'
		s = len(str)
		return str[:s-1]
		
	def main(self):
		
		while True:
			src = self.result_handler.readline()
			if not src:
				print "Finished copying."
				break
			else:
				if src[0] != 'N' and src[0] != '-' :
					if src != self.buffer :
						self.counter = self.counter + 1
						dst = self.get_dst(src)
						s = self.tailor(src)
						d = self.tailor(dst)
						print "Copying from: ", s, "\tto: ", d
						shutil.copy(s,d) 
						#shutil.move('d:/c.png','e:/')
						#shutil.rmtree('d:/dd')
						self.buffer = src
					
					
	def finish(self):
		self.result_handler.close()
		print self.counter, "file copied"

###########################################
#argv[1]  outcome directory
#argv[2]  result log file
print sys.argv[1], sys.argv[2]
mytool = Tool(sys.argv[1], sys.argv[2])
mytool.main()
mytool.finish()




