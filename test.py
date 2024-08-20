import contract

contract.call_func("assign_work", [0, "", 1, 100, 1])
contract.call_func("join_work", [1])
print(contract.local_call("get_work", [1]))