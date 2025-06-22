import re

file = open("precaches.nut", "r")
output = open("output.txt", "w")
readfile = file.read()

splitfile = readfile.split("\n")
for line in splitfile:
    if line[:19] != "PrecacheScriptSound":
        continue
    line = line.replace("MVM", "M_MVM")
    if ("Heavy." not in line) and ("Demoman." not in line) and ("Scout." not in line) and ("Pyro." not in line) and ("Soldier." not in line):
        continue
    output.write(line + "\n")