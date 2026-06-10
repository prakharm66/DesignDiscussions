import random

id_width = 4

#initialise queues adnd counters
free_ids = list(range(2**id_width))
active_ids = [] # list to store active transaction IDs
tr_cnt = {} # dictionary to store active transaction and its latency count
for i in free_ids: tr_cnt[i] = 0
rem_flag=False
add_flag=False

#approximating variables
approx_cnt=0
avg_latency=0
active_tr_cnt=0

#probabilities that there would be response or request if respective queues are not empty
req_probablity = 0.5 
rsp_probablity = 0.55 


for i in range(200):

    if active_tr_cnt > 0:
        avg_latency = round(approx_cnt/active_tr_cnt)

    #calculating approx latency:
    approx_cnt+=active_tr_cnt

    if len(free_ids)>0 and random.random() < req_probablity: # randomly decide to start a transaction
        add_flag=True
        tr_id = free_ids[random.randint(0, len(free_ids)-1)]
        free_ids.remove(tr_id)
        # print(f"Transaction {tr_id} started")
    if len(active_ids)>0 and random.random() < rsp_probablity: # randomly decide to end a transaction
        rem_flag=True
        tr_id_rem = active_ids[random.randint(0, len(active_ids)-1)]
        active_ids.remove(tr_id_rem)
        # print(f"Transaction {tr_id_rem} ended with latency {tr_cnt[tr_id_rem]} cycles")
        tr_cnt[tr_id_rem] = 0 # reset count for the transaction ID
    
    #this section ensures that transaction ID is not used in the same cycle for both start and end, which is not possible in real scenario
    if add_flag:
        active_ids.append(tr_id) # add the transaction ID to active list
        add_flag=False
        active_tr_cnt+=1

    if rem_flag:
        free_ids.append(tr_id_rem) # add the transaction ID to free list
        rem_flag=False
        approx_cnt-=avg_latency # decrement approx count by avg latency of active transactions, as one transaction is removed
        active_tr_cnt-=1

    # increment latency count for active transactions
    for tr_id in active_ids:
        tr_cnt[tr_id] += 1 


    #printing statistics of eery cycle
    avg = sum(tr_cnt[tr_id] for tr_id in active_ids) / len(active_ids) if active_ids else 0
    max_latency = max(tr_cnt[tr_id] for tr_id in active_ids) if active_ids else 0
    print(f"Active Transactions: {len(active_ids)}, Average Latency: {avg:.2f} cycles, Max Latency: {max_latency} cycles, approx_sum: {approx_cnt}, approx Latency: {avg_latency} cycles")    
    # print("Transactions Counts:",tr_cnt)


