# @version ^0.4.0 

@deploy
def __init__():
    return

struct Work:
    type: bool
    script: String[64]
    node_count: int8
    nodes: int64[5]
    incentive: uint256

@external
def assign_work(type:bool, script: String[64], nodes: int8, incentive: uint256):
    return