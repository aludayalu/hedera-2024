# @version ^0.4.0 

@deploy
def __init__():
    return

struct Work:
    type: bool
    script: String[64]
    node_count: int8
    nodes: int64[5]
    total_incentive: uint256
    commitments: bytes32[5]
    randoms: bytes32[5]
    works: bytes32[5]

@external
def assign_work(type:bool, script: String[64], nodes: int8, incentive: uint256):
    return