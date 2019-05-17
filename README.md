Project of double-fetch bug detection.

This work consists of three parts, the text level filtration, coccinelle-based pattern matching, and automatic patching tool. 

(1) /text-filter: Source code of the text level filtration method. Detailed introduction and instruction please check readme.txt in its directory.

(2) /cocci: Source code of the Coccinelle-based pattern matching method. Detailed introduction and instruction please check readme.txt in its directory. 

(3) /auto_fix: Source code of the Coccinelle-based automatic double-fetch bug patching tool.


# How to generate the gui
sudo apt-get install python-tk
sudo apt-get install python-pip
pip install pyinstaller

pyinstaller -F -w pygui.py



#How to use

1. For linux, double click start-gui excutable.

2. For other platforms, run "python start-gui.py" to use the gui,
or run the sripts "./startcocci_linux.sh", "./startcocci_freebsd.sh" instead.
However, the targets should be in the testdir/ when using the script (or modify the scipts).

3. Use "./clean.sh" to clean the old files.

4. Use "python src/new_file_filter old_result.txt new_result.txt" to filter 
out the new reports since the last detection
