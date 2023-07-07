import os
import time 

def loop(tempo):
    for j in range(tempo):
        print(f"sleep for {tempo}: ", j, end="\r")
        time.sleep(1)

def notifiy_send(title, text):
    #if " " in title:
    #    title.replace(" ","_")
    command = f"notify-send --icon=gtk-info {title} '{text}'"
    print("to notify ->", command)
    os.system(command)


def start():

    print("Digite o numero do uav a ser estudado: ")
    numero = input("numero: ")

    if numero not in "29,30,38,7".split(","):
        print("numero errado, digite novamente")
        exit()

    UAV_NAME = "uav" + numero

    print("10 seg pra comecar")
    loop(10)

    return UAV_NAME

def spin(UAV_NAME):
    for i in range(-315, +315, 5):
        
        rad = i/100
        #command = f'rosservice call /{UAV_NAME}/control_manager/goto_relative \"goal: \[0.0, 0.0, 0.0, {rad}\]\"'
        print("\n")
        print("##########################")
        print(f"{i} {UAV_NAME}")
        print("##########################")
        command = f'rosservice call /{UAV_NAME}/control_manager/goto_relative "goal: [0.0, 0.0, 0.0, {rad}]"'
        
        notifiy_send("PY_spin", command)
        print(command)

        os.system(command)

        loop(2)

        print("\n", end="")
        print("##########################")

    notifiy_send("PY_spin", "Ended !!!")

def route(UAV_NAME): 

    waypoints = [[20,  0, 3],
                 [20, 20, 3],
                 [40, 20, 3],
                 [40, 40, 3],
                 [ 0,  0, 3]]


    for i, point in enumerate(waypoints):
        #command = f'rosservice call /{UAV_NAME}/control_manager/goto_relative \"goal: \[0.0, 0.0, 0.0, {rad}\]\"'
        x = point[0]
        y = point[1]
        z = point[2]
        print("\n")
        print("##########################")
        print(f"{i} {UAV_NAME} {x} {y} {z}")
        print("##########################")
        command = f'rosservice call /{UAV_NAME}/control_manager/goto "goal: [{x}, {y}, {z}, 0]"'
        
        
        notifiy_send("PY_route", command) #.replace(";"," "))#.replace("/","_").replace(" ", "_"))
        print(command)
        
        os.system(command)

        loop(20)

        print("\n", end="")
        print("##########################")

def start_swarm():

    start_tracking_4 = ["export UAV_NAME=uav29; rosservice call /$UAV_NAME/swarm_controller/tracking true",
                      "export UAV_NAME=uav30; rosservice call /$UAV_NAME/swarm_controller/tracking true",
                      "export UAV_NAME=uav38; rosservice call /$UAV_NAME/swarm_controller/tracking true"]
        
    start_swarm_3 = ["export UAV_NAME=uav29; rosservice call /$UAV_NAME/swarm_controller/swarming true",
                      "export UAV_NAME=uav30; rosservice call /$UAV_NAME/swarm_controller/swarming true",
                      "export UAV_NAME=uav38; rosservice call /$UAV_NAME/swarm_controller/swarming true"]
        
    init_manual_2 = ["export UAV_NAME=uav29; rosservice call /$UAV_NAME/data_collector/init_manual true",
                      "export UAV_NAME=uav30; rosservice call /$UAV_NAME/data_collector/init_manual true",
                      "export UAV_NAME=uav38; rosservice call /$UAV_NAME/data_collector/init_manual true"]
        
    safety_area_1 = ["export UAV_NAME=uav29; rosservice call /$UAV_NAME/control_manager/use_safety_area false",
                      "export UAV_NAME=uav30; rosservice call /$UAV_NAME/control_manager/use_safety_area false",
                      "export UAV_NAME=uav38; rosservice call /$UAV_NAME/control_manager/use_safety_area false"]
        


    super_commands = [safety_area_1,init_manual_2,start_swarm_3,start_tracking_4]

    for i, point in enumerate(super_commands):

        for command in point:
            #command = f'rosservice call /{UAV_NAME}/control_manager/goto_relative \"goal: \[0.0, 0.0, 0.0, {rad}\]\"'
            
            print("\n")
            print("##########################")
            print(f"{i}")
            print("##########################")
            
            notifiy_send("PY_swarm", command) #.replace(";"," "))#.replace("/","_").replace(" ", "_"))
            
            print("will be send this command: ", command)

            os.system(command)

            #loop(1)

            print("\n", end="")
            print("##########################")
        
        loop(5)




commands = "start swarm,waypoints,spin,test_notify_send".split(",")

for i in range(3):

    print("\n\n\n")
    print("#"*50)
    print("Type your command, q for exit:\n")
    print("#"*50)
    for j, command in enumerate(commands):
        print(j, command)

    print("\n\n\n")

    user_input = input("type your command: ")

    if user_input == "q":
        exit()
    
    user_input = int(user_input)

    if user_input == 0:
        start_swarm()
    if user_input == 1:
        UAV_NAME = start()
        route(UAV_NAME)
    if user_input == 2:
        UAV_NAME = start()
        spin(UAV_NAME)
    if user_input == 3:
        loop(10)
        notifiy_send("test", "test")

