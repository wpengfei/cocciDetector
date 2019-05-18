
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
