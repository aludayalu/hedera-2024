# @version ^0.4.0 

@deploy
def __init__():
    return

works: HashMap[uint256, Work]

struct Work:
    initiator: address
    type: bool
    script: String[64]
    node_count: int256
    nodes: address[5]
    total_incentive: uint256
    commitments: bytes32[5]
    randoms: bytes32[5]
    works: bytes32[5]

@external
@payable
def assign_work(type:bool, script: String[64], nodes: int256, incentive: uint256, id: uint256):
    assert self.works[id].node_count==0, "work id already exists"
    assert not (nodes>=1 and nodes<=5), "invalid node count specified"
    self.works[id].initiator=msg.sender
    self.works[id].type=type
    self.works[id].script=script
    self.works[id].node_count=nodes
    self.works[id].total_incentive=incentive

@external
def submit_commitment(work_id: uint256, commitment: bytes32):
    assert self.works[work_id].node_count!=0, "work does not exist"
    index: int256=-1
    for i: int256 in range(20):
        if i<self.works[work_id].node_count:
            if self.works[work_id].nodes[i] == msg.sender:
                index = i
                break
    assert index!=-1, "you are not a part of the work"
    self.works[work_id].commitments[index]=commitment

@external
def submit_commitment_proof(work_id: uint256, random: bytes32, work: bytes32):
    assert self.works[work_id].node_count!=0, "work does not exist"
    index: int256=-1
    for i: int256 in range(20):
        if i<self.works[work_id].node_count:
            if self.works[work_id].nodes[i] == msg.sender:
                index = i
                break
    assert index!=-1, "you are not a part of the work"
    self.works[work_id].randoms[index]=random
    self.works[work_id].works[index]=work