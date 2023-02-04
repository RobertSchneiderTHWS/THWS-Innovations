import 'dart:convert';
import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/browser.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../constants/rounded_alert.dart';
import '../constants/text_constants.dart';
import 'package:fhws_innovations/constants/text_constants.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SmartContract {
  var ethClient = Web3Client(rinkebyInfuraLink, Client());

  Future<DeployedContract> loadContract() async {
    // Load Contract from the Abi
    String abi = await rootBundle.loadString(abiJson);

    // Transform contract into an object
    final contract = DeployedContract(ContractAbi.fromJson(abi, contractName),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  // Enter function name of smart contract method - optional are the arguments
  Future<List<dynamic>> querySmartContractFunction(
      String functionName, List<dynamic> args, Web3Client ethClient) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<String> submitTransaction(
      String functionName, List<dynamic> args, BuildContext context) async {
    final eth = window.ethereum;
    if (eth == null) {
      return "MetaMask is not available";
    } else {
      final credentials = await eth.requestAccount();
      final client = Web3Client.custom(eth.asRpcService());
      DeployedContract contract = await loadContract();
      final ethFunction = contract.function(functionName);
      final result = await client.sendTransaction(
          credentials,
          Transaction.callContract(
              contract: contract, function: ethFunction, parameters: args),
          chainId: null,
          fetchChainIdFromNetworkId: true);
      await getStatusOfTransaction(result, context);
      return result;
    }
  }

  Future<bool> getStatusOfTransaction(String transactionHash, BuildContext context) async {
    bool transactionGetsProcessed = false;
    final response = await http.get(Uri.parse(
        etherscanRequest + transactionHash + '&apikey=' + etherscanToken));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> etherScanFetch = jsonDecode(response.body);
      if (('${etherScanFetch['result']['isError']}' == "0") &&
          ('${etherScanFetch['status']}' == "1")) {
        // Transaction gets processed fine.
        transactionGetsProcessed = true;
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const RoundedAlert("Achtung",
                "Die Transaktion schlug leider fehl!");
          },
        );

        // Throw Exception if there was an error in the transaction
        throw Exception('Transaction failed!');
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const RoundedAlert("Servertimeout",
              "Die Transaktion schlug leider fehl!");
        },
      );
      throw Exception('Transaction failed!');
    }
    return transactionGetsProcessed;
  }
}
