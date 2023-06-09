import os 
import sys

# Getting the current working directory
cwd = os.getcwd()

# Printing the current working directory
print("Th Current working directory is: {0}".format(cwd))

# Changing the current working directory
os.chdir(f'{cwd}/ros_packages')

# Print the current working directory
print("The Current working directory now is: {0}".format(os.getcwd()))


path_to_read = "../.gitman"
print(f"Arquivos na pasta: {path_to_read}")
list_of_files = os.listdir(path_to_read)
print(list_of_files)


path_to_write = "./ros_packages"

#bash_file = open("generate_links.sh", "a")

for file in list_of_files:
    print()
    print(file)
    print(f"ln -n {path_to_read}/{file}")
    while True:
        user_input = input("[y/n]:")
        if user_input == "y":
            os.system(f"ln -s {path_to_read}/{file}")
            break
        elif user_input == "n":
            print("Will not be created the link")
            break
        else:
            print("Try again")

    print()