# @version ^0.4.0 

@deploy
def __init__():
    return

works: HashMap[uint256, Work]
empty_buffer: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000000000000
empty_address: constant(address) = 0x0000000000000000000000000000000000000000
work_ids: uint256[1000]
default_Work: Work

struct Work:
    initiator: address
    type: uint8
    script: String[64]
    node_count: uint256
    nodes: address[5]
    total_incentive: uint256
    commitments: bytes32[5]
    randoms: bytes32[5]
    works: bytes32[5]
    submitted: uint256
    joined: uint256

@external
@payable
def assign_work(type:uint8, script: String[64], nodes: uint256, incentive: uint256, id: uint256):
    # assert msg.value>=incentive, "you sent money less than the incentive" // will be added on the mainnet
    assert id!=0, "id cannot be 0"
    assert self.works[id].node_count==0, "work id already exists"
    assert (nodes>=1 and nodes<=5), "invalid node count specified"
    self.works[id].initiator=msg.sender
    self.works[id].type=type
    self.works[id].script=script
    self.works[id].node_count=nodes
    self.works[id].total_incentive=incentive
    index: int256=-1
    for i: uint256 in range(1000):
        if self.work_ids[i]==0:
            index = convert(i, int256)
            break
    assert index!=-1, "too many works already assigned"
    self.work_ids[index]=id

@external
def submit_commitment(work_id: uint256, commitment: bytes32):
    assert self.works[work_id].node_count!=0, "work does not exist"
    index: int256=-1
    for i: uint256 in range(20):
        if i<self.works[work_id].node_count:
            if self.works[work_id].nodes[i] == msg.sender:
                index = convert(i, int256)
                break
    assert index!=-1, "you are not a part of the work"
    self.works[work_id].commitments[index]=commitment

@external
def get_work_index_from_work_id(work_id: uint256)->(address, address):
    index: uint256=5
    loops: uint256=0
    for i: uint256 in range(20):
        if i<self.works[work_id].node_count:
            loops+=1
            return self.works[work_id].nodes[i], msg.sender
    return empty_address, empty_address

@internal
def check_all_commitments(work_id: uint256):
    index: int256=-1
    for i: uint256 in range(1000):
        if self.work_ids[i]==0:
            index = convert(i, int256)
            break
    self.work_ids[index]=0
    self.works[work_id]=self.default_Work
    frequencies: int256[5] = [0, 0, 0, 0, 0]
    max_frequency: int256 = 0
    most_frequent_work: bytes32 = empty_buffer
    for i: uint256 in range(5):
        if i < self.works[work_id].node_count:
            current_work: bytes32 = self.works[work_id].works[i]
            for j: uint256 in range(5):
                if current_work == self.works[work_id].works[j]:
                    frequencies[i] += 1
            if frequencies[i] > max_frequency:
                max_frequency = frequencies[i]
                most_frequent_work = current_work
    matching_addresses: address[5] =  [empty_address, empty_address, empty_address, empty_address, empty_address]
    matching_count: int256 = 0
    for i: uint256 in range(5):
        if i < self.works[work_id].node_count:
            if self.works[work_id].works[i] == most_frequent_work:
                matching_addresses[matching_count] = self.works[work_id].nodes[i]
                matching_count += 1
    num_matching: uint256 = convert(matching_count, uint256)
    # will be added on the mainnet
    # incentive_per_address: uint256 = ((self.works[work_id].total_incentive // num_matching) * 9) // 10
    # for i: uint256 in range(5):
    #     if matching_addresses[i] != empty_address:
    #         # send(matching_addresses[i], incentive_per_address)
    #         pass

@external
def join_work(work_id: uint256):
    assert self.works[work_id].node_count!=0, "work does not exist"
    assert self.works[work_id].joined<=self.works[work_id].node_count, "enough nodes have already joined"
    self.works[work_id].nodes[self.works[work_id].joined]=msg.sender
    self.works[work_id].joined+=1

@external
def submit_commitment_proof(work_id: uint256, random: bytes32, work: bytes32):
    assert self.works[work_id].node_count!=0, "work does not exist"
    index: int256=-1
    for i: uint256 in range(20):
        if i<self.works[work_id].node_count:
            if self.works[work_id].nodes[i] == msg.sender:
                index = convert(i, int256)
                break
    assert index!=-1, "you are not a part of the work"
    assert self.works[work_id].commitments[index]==sha256(concat(random, work)), "incorrect commitment"
    self.works[work_id].randoms[index]=random
    self.works[work_id].works[index]=work
    self.works[work_id].submitted+=1
    if self.works[work_id].submitted==self.works[work_id].node_count:
        self.check_all_commitments(work_id)

@external
def all_work_ids()->uint256[1000]:
    return self.work_ids

@external
def get_work(id: uint256)->Work:
    return self.works[id]