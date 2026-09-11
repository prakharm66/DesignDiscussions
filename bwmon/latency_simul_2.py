import random
import numpy as np
import matplotlib.pyplot as plt
#this block would mimic the latency monitor
#assuming there would be a request and a response and latency monitor would calculate average latency in a certain time period

#memory bank
TrId_occupied={i:0 for i in range(16)}
Total_transactions=0
occupied_TrIds=0
Total_latency=0

#latency monitor
#input: Req,Req_TrId,Rsp,Rsp_TrId,threshold
#output: overflow_flag
#internal: Total_transactions,average_latency,cumulative_latency,occupied_TrIds

def latmon(Req,Req_TrId,Rsp,Rsp_TrId,threshold=8):
    global Total_transactions,occupied_TrIds,Total_latency

    flag=0
    if Req==1:
        TrId_occupied[Req_TrId]=1
       # Total_transactions+=1
        occupied_TrIds+=1
    if Rsp==1:
        TrId_occupied[Rsp_TrId]=0
        occupied_TrIds-=1 
        Total_transactions+=1
    Total_latency+=occupied_TrIds
    Avg_latency = round(Total_latency/Total_transactions if Total_transactions > 0 else 0,2)
    if Avg_latency>=threshold:
        #print("Flag is asserted, latency increased")
        flag=1

    #print(f"Avg = {Avg_latency}, nTrans = {Total_transactions}, occpTrId = {occupied_TrIds}, total_cumulative = {Total_latency}")
    #print("TrId occupancy status: ",TrId_occupied.values())
    return (Avg_latency,flag)

def run_sequence():
    for i in range(8):
        a=latmon(Req=1,Req_TrId=i,Rsp=0,Rsp_TrId=0)

    for i in range(4):
        a=latmon(Req=0,Req_TrId=0,Rsp=1,Rsp_TrId=i)

    for i in range(8,16):
        a=latmon(Req=1,Req_TrId=i,Rsp=0,Rsp_TrId=0)
        a=latmon(Req=0,Req_TrId=0,Rsp=1,Rsp_TrId=i-4)

    for i in range(4):
        a=latmon(Req=0,Req_TrId=0,Rsp=1,Rsp_TrId=15-i)

def run_random(iterations):

    Free_TrId_queue=list(range(16))
    #print("Free_TrId_queue: ",Free_TrId_queue)
    occupied_TrId_queue=[]
    y_axes=[]
    dots=[]

    for i in range(iterations):

        if len(Free_TrId_queue)==0:
            Req=0
        else:
            Req=random.randint(0,1)

        if len(occupied_TrId_queue)==0:
            Rsp=0
        else:
            Rsp=random.randint(0,1) 
        
        Req_TrId=-1
        Rsp_TrId=-1
        if len(Free_TrId_queue)>0:
            Req_TrId=random.choice(Free_TrId_queue)

        if len(occupied_TrId_queue)>0:    
            Rsp_TrId=random.choice(occupied_TrId_queue)

        (avg,flag)=latmon(Req=Req,Req_TrId=Req_TrId,Rsp=Rsp,Rsp_TrId=Rsp_TrId)
        if flag==1:
            dots.append([i,avg])
        y_axes.append(avg)
        if Req==1 and Req_TrId>0:
            #print("Req_Trid: ",Req_TrId)
            occupied_TrId_queue.append(Req_TrId)
            Free_TrId_queue.remove(Req_TrId)
        if Rsp==1 and Rsp_TrId>0:
            occupied_TrId_queue.remove(Rsp_TrId)
            Free_TrId_queue.append(Rsp_TrId)
    x_axes = np.arange(iterations)
    dots_array=np.array(dots)
    plt.plot(x_axes,y_axes)
    #print(dots_array)
    if dots_array.size>0:
        plt.scatter(dots_array[:,0],dots_array[:,1],color='red')
    plt.show()
            

#run_sequence()    
run_random(10000)


