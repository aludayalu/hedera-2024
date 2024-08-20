import contract
import os
import hashlib

work = os.urandom(32)
random = os.urandom(32)
concatenated_bytes = random + work

concatenated_hash = hashlib.sha256(concatenated_bytes).digest()

workid=6

contract.call_func("assign_work", [0, "", 1, 100, workid])
contract.call_func("join_work", [workid])
contract.call_func("submit_commitment", [workid, concatenated_hash])
# print(contract.local_call("get_work_index_from_work_id", [1]))
# # try:
# #     contract.local_call("submit_commitment", [1, concatenated_hash])
# # except Exception as e:
# #     print(e)
# #     print(e.data)
print(contract.local_call("get_work", [workid]))
try:
    contract.call_func("submit_commitment_proof", [workid, random, work])
except Exception as e:
    print(e.data)
    raise e

print(contract.local_call("get_work", [workid]))