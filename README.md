# Instructions

## For testing 

### LNN implementaion
1 - start vio.sh in mrse package
2 - start md_start.sh inside scripts/simulation folder and wait for the object_tracker_simple get better
3 - inside vio.sh simulation tmux, go to the estimator with UWB in the name, start estimator with uwb
4 - start plotjugler rosrun plotjugler and import the xml file
5 - start in sequence by sufix, vio.sh simulation tmux
6 - watch in plotjugler


### Jiri implementaion
1 - start vio.sh in mrse package
3 - inside vio.sh simulation tmux, go to the estimator and start it
4 - start plotjugler rosrun plotjugler and import the xml file
5 - start in sequence by sufix, vio.sh simulation tmux
6 - watch in plotjugler

## Ideas 

- I think that jiri uses the uvdar error in his favor, to create the lines that in the intersection is the UAV

- how to implement if I dont have this kinda of information?
- increase the number of drones and implement a triangulation ? and the UWB?

- test the vio implementation