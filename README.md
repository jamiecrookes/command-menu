# command-menu - PowerShell Favourites Menu

# Introduction
This module provides a hotkey driven menu for all your favourite commands
whilst using a PowerShell prompt.

If, like me, you are constantly forgetting the names of certain commands,
functions or anything else you would normally type into a PowerShell command 
line then you may find this tool of use.

Simply populate a file in your home directory called `commandmenu.txt` with
a list (1 per line) of all the commands you wish to have access to at the press 
of a hotkey (ctrl+g). Once populated and you have the module loaded you can press
ctrl+g and an arrow key driven menu will appear liosting those commands. You can
then press enter on your desired command and the menu will dissapear leaving
the command you selected sat on the command prompt ready for parameters or pressing
enter on to execute.

# Requirements
- A file in your home directory called commandmenu.txt

# Installation
Copy the module file to a location of your choice. Preferably, one which will auto-
load on shell/terminal startup.

Once copied, create your commandmenu.txt file and populate it with your favourite
commands.

# Future Plans \ New Features
I have ideas on how to extend the usefulness of this little utility. I am probably 
going to add descriptions for each command to display in the right hand side of the
screen next to each menu option. I may also look at having nested menus to allow 
for categories of commands to cope with potentially large collections of commands.