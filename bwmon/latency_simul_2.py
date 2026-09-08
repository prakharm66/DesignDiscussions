import random
#this block would mimic the latency monitor
#assuming there would be a request and a response and latency monitor would calculate average latency in a certain time period

#memory bank
TrId_occupied={i:0 for i in range(16)}
Total_transactions=0
occupied_TrIds=0
Total_latency=0

#latency monitor
def latmon(Req,Req_TrId,Rsp,Rsp_TrId):
    global Total_transactions,occupied_TrIds,Total_latency
    if Req==1:
        TrId_occupied[Req_TrId]=1
        Total_transactions+=1
        occupied_TrIds+=1
    if Rsp==1:
        TrId_occupied[Rsp_TrId]=0
        occupied_TrIds-=1 
    Total_latency+=occupied_TrIds
    print(f"Avg = {round(Total_latency/Total_transactions if Total_transactions > 0 else 0)}, nTrans = {Total_transactions}, occpTrId = {occupied_TrIds}, total_cumulative = {Total_latency}")
    print("TrId occupancy status: ",TrId_occupied.values())

def run_sequence():
    for i in range(8):
        latmon(Req=1,Req_TrId=i,Rsp=0,Rsp_TrId=0)

    for i in range(4):
        latmon(Req=0,Req_TrId=0,Rsp=1,Rsp_TrId=i)

    for i in range(8,16):
        latmon(Req=1,Req_TrId=i,Rsp=0,Rsp_TrId=0)
        latmon(Req=0,Req_TrId=0,Rsp=1,Rsp_TrId=i-4)

    for i in range(4):
        latmon(Req=0,Req_TrId=0,Rsp=1,Rsp_TrId=15-i)

def run_random():

    Free_TrId_queue=list(range(16))
    occupied_TrId_queue=[]
    for i in range(100):
        Req=random.randint(0,1)

        if len(occupied_TrId_queue)==0:
            Rsp=0
        else:    
            Rsp=random.randint(0,1) 
        
        Req_TrId=0
        Rsp_TrId=0
        if len(Free_TrId_queue)>0:
            Req_TrId=random.choice(Free_TrId_queue)

        if len(occupied_TrId_queue)>0:    
            Rsp_TrId=random.choice(occupied_TrId_queue)

        latmon(Req=Req,Req_TrId=Req_TrId,Rsp=Rsp,Rsp_TrId=Rsp_TrId)

        if Req==1:
            occupied_TrId_queue.append(Req_TrId)
            Free_TrId_queue.remove(Req_TrId)
        if Rsp==1:
            occupied_TrId_queue.remove(Rsp_TrId)
            Free_TrId_queue.append(Rsp_TrId)

#run_sequence()    
run_random()


