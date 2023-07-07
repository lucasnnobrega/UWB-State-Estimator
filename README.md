# Instructions

## For testing 

### LNN implementaion
1. start vio.sh in mrse package
2. start md_start.sh inside scripts/simulation folder and wait for the object_tracker_simple get better
3. inside vio.sh simulation tmux, go to the estimator with UWB in the name, start estimator with uwb
4. start plotjugler rosrun plotjugler and import the xml file
5. start in sequence by sufix, vio.sh simulation tmux
6. watch in plotjugler

#### feat_uwb_implementation (mrse) - manual mode

1. start vio.sh in mrse package
2. inside vio.sh simulation tmux, go to the estimator with UWB in the name, start estimator with uwb
3. start plotjugler rosrun plotjugler and import the xml file
4. start in sequence by sufix, vio.sh simulation tmux
5. watch in plotjugler

#### feat_uwb_implementation (mrse) - automatic
1. start vio.sh in mrse package
2. inside vio.sh simulation tmux, go to the estimator with UWB in the name, start estimator with uwb
3. start plotjugler `rosrun plotjugler plotjugler` and import the xml file `comparing_same_time.xml`
4. start the code `python cmds.py` 
5. watch in plotjugler


### Jiri implementaion
1. start vio.sh in mrse package
3. inside vio.sh simulation tmux, go to the estimator and start it
4. start plotjugler rosrun plotjugler and import the xml file
5. start in sequence by sufix, vio.sh simulation tmux
6. watch in plotjugler

## Ideas 

- I think that jiri uses the uvdar error in his favor, to create the lines that in the intersection is the UAV

- how to implement if I dont have this kinda of information?
- increase the number of drones and implement a triangulation ? and the UWB?

- test the vio implementation

### 18-06-2023
- implement all at the same time 
- same path for all the drones 


### 30-6-2023
#### feat_uwb_implementation (mrse)
- code are running, good performance in spin test (python code)
- still some problems because of not showing in some moments (return nothing)
- verify the implementation if works like before (OK)

#### feat_uwb_implementation (mrse)
- create new branch on mrse and insert the code inside uvdar callback 


https://math.stackexchange.com/questions/256100/how-can-i-find-the-points-at-which-two-circles-intersect


# Useful commands

## Command for keyboard share
x2x -to :0 -east

## Command to commit on megabedna
ssh-add /home/mrs/.ssh/lucasnn

## comand to list other nodes
rosnode list 

rosnode kill ...

## find the correct workspace that teamviewer is
i3-msg workspace $(number 0 .. 9)


## take a screen shot on the virtual machine and convert to png
xwd -display :0 -root > output.xwd && convert output.xwd output.png

## open image with vscode ssh remote
code $folder_name

## command to open images in terminal 
xdg-open $file_name

## kill object tracker program if the code is not running
pkill -f uvdar_uwb_state_estimator_workspace