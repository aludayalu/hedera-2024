from web3 import Web3
import subprocess
import os
import secrets_parser

private_key=secrets_parser.parse("variables.txt")["PRIVATE_KEY"]

web3 = Web3(Web3.HTTPProvider("https://testnet.hashio.io/api"))

account = web3.eth.account.from_key(private_key)

process=subprocess.run(["vyper", "hello.vy"], stdout=subprocess.PIPE)
data=process.stdout.decode().strip(" \n\r")

tx = {
    "from": account.address,
    "data": eval(data),
    "nonce": web3.eth.get_transaction_count(account.address),
    "gasPrice": web3.eth.gas_price
}

gas_estimate = web3.eth.estimate_gas(tx)
tx["gas"] = gas_estimate

signed_tx = web3.eth.account.sign_transaction(tx, account.key)
tx_hash = web3.eth.send_raw_transaction(signed_tx.rawTransaction)
receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
print(receipt)