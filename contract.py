import requests
import json
import time
import web3
import secrets_parser

w3 = web3.Web3(web3.Web3.HTTPProvider("https://testnet.hashio.io/api"))

abi=json.loads(open("abi/abi.json").read())
private_key=secrets_parser.parse("variables.txt")["PRIVATE_KEY"]

account = w3.eth.account.from_key(private_key)

def get_contract_address():
    with open("contract_hash") as fd:
        return fd.read()

def call_func(name, args=[]):
    contract_address=get_contract_address()
    contract = w3.eth.contract(address=contract_address, abi=abi)
    statement=f"call_function = contract.functions.{name}({','.join([json.dumps(x) for x in args])}).build_transaction("+"""
        {
            'from': account.address,
            'nonce': w3.eth.get_transaction_count(account.address),
        }
    )
"""
    new_locals,new_globals={}|globals()|locals(),{}|globals()|locals()
    while True:
        try:
            exec(statement,new_globals,new_locals)
            break
        except requests.exceptions.HTTPError:
            time.sleep(1)
            continue
    call_function=new_locals["call_function"]
    tx_create = w3.eth.account.sign_transaction(call_function, private_key)
    while True:
        try:
            tx_hash = w3.eth.send_raw_transaction(tx_create.rawTransaction)
            break
        except Exception as e:
            if web3.exceptions.TimeExhausted==type(e):
                return
            elif requests.exceptions.HTTPError==e:
                time.sleep(1)
                continue
            else:
                raise e
    while True:
        try:
            w3.eth.wait_for_transaction_receipt(tx_hash)
            break
        except Exception as e:
            if web3.exceptions.TimeExhausted==type(e):
                return
            elif requests.exceptions.HTTPError==e:
                time.sleep(1)
                continue
            else:
                raise e
    return tx_hash

def local_call(name, args=[]):
    contract_address=get_contract_address()
    contract = w3.eth.contract(address=contract_address, abi=abi)
    statement=f"call_function = contract.functions.{name}({','.join([json.dumps(x) for x in args])}).call()"
    new_locals,new_globals={}|globals()|locals(),{}|globals()|locals()
    while True:
        try:
            exec(statement,new_globals,new_locals)
            break
        except requests.exceptions.HTTPError:
            time.sleep(1)
            continue
    call_function=new_locals["call_function"]
    return call_function