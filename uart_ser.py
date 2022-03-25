# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import serial
import matplotlib.pyplot as plt
import numpy as np

#%%
 
ser = serial.Serial()
ser.baud = 9600
ser.port='COM6'
ser.open()
byte = ser.read()
print(byte)





ldr0 = []
ldr1 = []
ldr2 = []
ldr3 = []
panel = []
posn_pan = []
posn_tilt = []

import serial 
ser = serial.Serial()
ser.baud = 9600
ser.port='COM6'
ser.open()

while True:
    try:
        panel_byte = ser.read()
        panel_num = int.from_bytes(panel_byte, 'little')
        panel.append(panel_num)
        
       
        ldr0_byte = ser.read()
        ldr0_num = int.from_bytes(ldr0_byte, 'little')
        ldr0.append(ldr0_num)
        
        ldr1_byte = ser.read()
        ldr1_num = int.from_bytes(ldr1_byte, 'little')
        ldr1.append(ldr1_num)
        
        pan_byte = ser.read()
        pan_num = int.from_bytes(pan_byte, 'little')
        posn_pan.append(pan_num)
        
        
        
        ldr2_byte = ser.read()
        ldr2_num = int.from_bytes(ldr2_byte, 'little')
        ldr2.append(ldr2_num)
        
        ldr3_byte = ser.read()
        ldr3_num = int.from_bytes(ldr3_byte, 'little')
        ldr3.append(ldr3_num)
        
        tilt_byte = ser.read()
        tilt_num = int.from_bytes(tilt_byte, 'little')
        posn_tilt.append(tilt_num)
        
        
    except:
        print("Keyboard Interrupt")
        break

#%%

#len(ldr0), len(ldr1), len(ldr2), len(ldr3), len(panel), len(posn_pan), len(posn_tilt)

data = np.array([ldr0,ldr1,ldr2,ldr3,panel,posn_pan,posn_tilt])
np.savetxt("data12torchmovement.csv", data, delimiter=",") #CHANGE NAME EACH TIME




mean = np.mean([np.array(ldr0), np.array(ldr1), np.array(ldr2),np.array(ldr3)], axis=0)
std = np.std([np.array(ldr0), np.array(ldr1), np.array(ldr2),np.array(ldr3)], axis=0)


plt.figure()
plt.plot(ldr0,label="LDR0 (Left)")
plt.plot(ldr1,label="LDR1 (Right)")
plt.plot(ldr2,label="LDR2 (Top)") 
plt.plot(ldr3,label="LDR3 (Bottom)")
plt.xlabel("Step Number")
plt.ylabel("LDR ADC value")
plt.legend()
plt.show()




plt.figure()
plt.plot(mean)
plt.xlabel("Step Number")
plt.ylabel("Mean ADC value of LDRs")
plt.show()



plt.figure()
plt.plot(std)
plt.xlabel("Step Number")
plt.ylabel("Standard deviation of LDR values")
plt.show()


plt.figure()
plt.plot(panel)
plt.xlabel("Step Number")
plt.ylabel("Panel ADC Value")
plt.show()



plt.figure()
plt.plot(posn_tilt,label="Tilt Position")
plt.plot(posn_pan,label="Pan Position")
plt.xlabel("Step Number")
plt.ylabel("Position")
plt.legend()
plt.show()
