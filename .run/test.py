from colorama import Fore, Style
import os
import subprocess

def list_files(filepath, filetype):
   paths = []
   for root, dirs, files in os.walk(filepath):
      for file in files:
         if file.lower().endswith(filetype.lower()):
            paths.append(os.path.join(root, file))
   return(paths)

def run_fault(filepath):
   cmd_str = "fault -f={}".format(filepath)
   p = subprocess.run(cmd_str, shell=True, capture_output=True)
   if p.stderr.decode() == "":
        print(Fore.GREEN + u'{} \N{check mark}'.format(filepath))
   else:
        print(Fore.RED + u'FAIL! {}'.format(filepath))
        print(p.stderr.decode())
   print(Style.RESET_ALL)


sys = list_files('../.', '.fsystem')
print("Running fsystem files...")
for v in sys:
   run_fault(v)
specs = list_files('../.', '.fspec')
print("Running fspec files...")
for v in specs:
   run_fault(v)