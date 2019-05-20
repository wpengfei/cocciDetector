#!/usr/bin/python
# -*- coding: UTF-8 -*-

from Tkinter import *
import tkFileDialog 
import tkMessageBox
import os
import thread
import commands
import subprocess
from time import sleep
#import _subprocess




#创建根窗口
root = Tk()
#设置窗口标题
root.title("cocciDetector")
#设置窗口大小
root.geometry("800x600")

#在窗体中创建一个框架，用它来承载其他小部件
control = Frame(root)
control.pack()

display = Frame(root)
display.pack()

filterframe = Frame(root)
filterframe.pack()

#global variables
path_dir = StringVar()
#path_dir.set("/home/wpf/Desktop/cocci/testdir")
path_dir.set("/home/wpf/Desktop/cocciDetector/testdir")


path_new = StringVar()
path_old = StringVar()


var = IntVar() #varibal for the radiobox
var.set(1)
kernel_str = "linux" #set default value

RR = IntVar() #varibal for the checkbox
WR = IntVar()
RW = IntVar() 
IL = IntVar()
RR.set(1)  #set default value
WR.set(0) 
RW.set(0) 
IL.set(0)

#callback functions
def onSelectPath():
    #path_ = tkFileDialog.askopenfilename()
    path_ = tkFileDialog.askdirectory()
    path_dir.set(path_)

def onSelectOldPath():
    path_ = tkFileDialog.askopenfilename()
    path_old.set(path_)

def onSelectNewPath():
    path_ = tkFileDialog.askopenfilename()
    path_new.set(path_)

def onRatioSelect():
    global kernel_str
    if var.get() == 1:
        kernel_str = "linux"
    elif var.get() == 2:
        kernel_str = "freebsd"

def onCheckbutton():
    return


def clean_old_files(k_str,t_str):
    global T
    result_str = k_str + "_" + t_str + "_result.txt"
    outcome_str = k_str + "_" + t_str + "_outcome"
    if os.path.exists(outcome_str):
        os.system("rm -r "+outcome_str)
    if os.path.isfile(result_str): 
        os.system("rm -r "+result_str)

    


def prepare_dirs(k_str,t_str):
    result_str = k_str + "_" + t_str + "_result.txt"
    outcome_str = k_str + "_" + t_str + "_outcome"
    #print "result_str",result_str
    #print "outcome_str",outcome_str
    if os.path.exists(outcome_str):
        #os.remove(outcome_str) #protected by Mac System Integrity Protection(SIP)
        os.system("rm -r "+outcome_str)
        #os.mkdir(outcome_str)
        os.system("mkdir "+outcome_str)
    else:
        os.system("mkdir "+outcome_str)   
    
    if os.path.isfile(result_str): 
        #os.remove(result_str)
        os.system("rm -r "+result_str)
        #os.mknod("te.txt") 
        filehandler = open(result_str,"w") 
        filehandler.close()
    else:
        filehandler = open(result_str,"w") 
        filehandler.close()

    T.insert(END, "=>Files and directories are prepared.\n")    

            

def copy_files(out,rfile):
    global T
    cmd =["python", "src/copy_files.py", out + "/", rfile] 
    #print "cmd=",cmd
    ps = subprocess.Popen(cmd, 
                        stdout=subprocess.PIPE,
                        stdin=subprocess.PIPE,
                        stderr=subprocess.STDOUT
                        #shell=True
                        )  # use shell when cmd is a string 
    while True:      
        data = ps.stdout.readline()
        T.insert(END, str(data)) #redirect the result to the text box
        if data == '' and ps.poll() != None:             
            break

def start_detect(cmd):
    global T

    # for the problem in Windows that subprocess does not work well with pyinstaller
    #si = subprocess.STARTUPINFO()
    #si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    ps = subprocess.Popen(cmd, 
                        stdout=subprocess.PIPE,
                        stdin=subprocess.PIPE,
                        stderr=subprocess.STDOUT,
                        #shell=True,
                        close_fds=True
                        #startupinfo=si
                        )  # use shell when cmd is a string 

    while True:      
        data = ps.stdout.readline()
        T.insert(END, str(data)) #redirect the result to the text box
        if data == '' and ps.poll() != None:             
            break

    #ps.stdout.close()
    #ps.stderr.close()

def thread_task(k_str):
    #os.system("spatch -cocci_file pattern_match_linux_RR.cocci -D count=0 -dir testdir")
    if RR.get() == 1:
        prepare_dirs(k_str,"RR")
        #os.system(cmd) 
        #(status, output) = commands.getstatusoutput(cmd)
        #cmd = "spatch --sp-file linux_RR.cocci --dir testdir"
        cmd = ["spatch","--sp-file","src/"+k_str+"_RR.cocci","--dir",path_dir.get()]
        
        T.insert(END, "=>Start detect RR type for "+k_str+".\n")

        start_detect(cmd)

        copy_files(k_str+"_RR_outcome", k_str+"_RR_result.txt") 
        
    if WR.get() == 1:
        prepare_dirs(k_str,"WR")
        
        cmd = ["spatch","--sp-file","src/"+k_str+"_WR.cocci","--dir",path_dir.get()]

        T.insert(END, "=>Start detect WR type for "+k_str+".\n")
        
        start_detect(cmd)

        copy_files(k_str+"_WR_outcome", k_str+"_WR_result.txt") 

    if RW.get() == 1:
        prepare_dirs(k_str,"RW")
        
        cmd = ["spatch","--sp-file","src/"+k_str+"_RW.cocci","--dir",path_dir.get()]

        T.insert(END, "=>Start detect RW type for "+k_str+".\n")
        
        start_detect(cmd)

        copy_files(k_str+"_RW_outcome", k_str+"_RW_result.txt") 

    if IL.get() == 1:
        prepare_dirs(k_str,"IL")
        
        cmd = ["time","spatch","--sp-file","src/"+k_str+"_IL.cocci","--dir",path_dir.get()]

        T.insert(END, "=>Start detect IL type for "+k_str+".\n")
        
        start_detect(cmd)

        copy_files(k_str+"_IL_outcome", k_str+"_IL_result.txt") 

    thread.exit_thread()

def onStartButtonClick():

    global kernel_str
    global path

    #check the input values
    if path_dir.get() == "":
        tkMessageBox.showwarning("Error","Please select target directory")
        return
    if RR.get() + RW.get() + WR.get() +IL.get() < 1:
        tkMessageBox.showwarning("Error","Please toggle bug types")
        return
    #tkMessageBox.showinfo("Error","s")
 
    thread.start_new_thread(thread_task,(kernel_str,))# start new thread to avoid blocking the process

def onCleanButtonClick():
    global T
    clean_old_files("linux","RR")
    clean_old_files("linux","WR")
    clean_old_files("linux","RW")
    clean_old_files("linux","IL")
    clean_old_files("freebsd","RR")
    clean_old_files("freebsd","WR")
    clean_old_files("freebsd","RW")
    clean_old_files("freebsd","IL")
    T.delete(1.0,END)
    T.insert(END, "=>Old files and directories are removed.\n")

def onShowNewFile():
    global T

    #check the input values
    if path_old.get() == "":
        tkMessageBox.showwarning("Error","Please choose the old result file.")
        return
    if path_new.get() == "":
        tkMessageBox.showwarning("Error","Please choose the new result file.")
        return

    cmd = ["python", "src/new_file_filter.py", path_old.get(), path_new.get()]
    ps = subprocess.Popen(cmd, 
                        stdout=subprocess.PIPE,
                        stdin=subprocess.PIPE,
                        stderr=subprocess.STDOUT
                        #shell=True
                        )  # use shell when cmd is a string 
    while True:      
        data = ps.stdout.readline()
        T.insert(END, str(data)) #redirect the result to the text box
        sleep(0.01)
        T.see(END)
        if data == '' and ps.poll() != None:             
            break
       


Label(control, text = "Set target directory:").grid(row = 1, column = 0) 
Entry(control, textvariable = path_dir).grid(row = 1, column = 1)
Button(control, text = "Browse", command = onSelectPath).grid(row = 1, column = 2)

Label(control, text = "Select the kernel type:").grid(row = 2, column = 0) 
R1 = Radiobutton(control, text="Linux/Android", variable=var, value=1,command = onRatioSelect)
R1.grid(row = 2, column = 1)
R2 = Radiobutton(control, text="FreeBSD/Darwin-xnu",variable=var,value=2,command = onRatioSelect)
R2.grid(row = 3, column = 1)


Label(control, text = "Select the bug type:").grid(row = 4, column = 0) 

 
Checkbutton(control,
            variable = RR,
            text = 'Read-Read (double fetch)',
            onvalue = 1, 
            offvalue = 0,
            command = onCheckbutton).grid(row = 4, column = 1)

   
Checkbutton(control,
            variable = WR,
            text = 'Write-Read (read after write)',
            onvalue = 1, 
            offvalue = 0,
            command = onCheckbutton).grid(row = 5, column = 1)

 
Checkbutton(control,
            variable = RW,
            text = 'Read-Write (write after read)',
            onvalue = 1, 
            offvalue = 0, 
            command = onCheckbutton).grid(row = 6, column = 1)

Checkbutton(control,
            variable = IL,
            text = 'infomation leak',
            onvalue = 1, 
            offvalue = 0, 
            command = onCheckbutton).grid(row = 7, column = 1)


clean_btn = Button(control, text="Clean Old files", width = 10, height = 1, command = onCleanButtonClick)
clean_btn.grid( row = 8, column = 1)

start_btn = Button(control, text="Start Detect",  width = 10, height = 1, bg = 'royalblue', command = onStartButtonClick)
start_btn.configure(bg = 'royalblue')
start_btn.grid( row = 8, column = 2)

# text box and scroll bar
S = Scrollbar(display)
T = Text(display, state = NORMAL,height=20, width=100)
S.pack(side=RIGHT, fill=Y)
T.pack(side=LEFT, fill=Y)
S.config(command=T.yview)
T.config(yscrollcommand=S.set)






Label(filterframe, text = "Choose old result file:").grid(row = 1, column = 0) 
Entry(filterframe, textvariable = path_old).grid(row = 1, column = 1)
Button(filterframe, text = "Browse", command = onSelectOldPath).grid(row = 1, column = 2)

Label(filterframe, text = "Choose new result file:").grid(row = 2, column = 0) 
Entry(filterframe, textvariable = path_new).grid(row = 2, column = 1)
Button(filterframe, text = "Browse", command = onSelectNewPath).grid(row = 2, column = 2)


Button(filterframe, text = "Show new files", bg = 'royalblue',command = onShowNewFile).grid(row = 3, column = 2)

'''
var_msg = StringVar()
msg = Message( root, textvariable=var_msg, width=80)

var_msg.set("Hey!? How are you doing?")
msg.pack()

'''




root.mainloop()

















