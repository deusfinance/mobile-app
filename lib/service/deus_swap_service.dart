import 'dart:convert';
import 'dart:math';
import 'dart:core';

import 'package:deus/models/gas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

class SwapService {
  static const GRAPH_PATH = "assets/deus_data/rinkbey_graph.json";

  final EthereumService ethService;
  final String privateKey;

  DeployedContract automaticMarketMakerContract;
  DeployedContract staticSalePrice;
  DeployedContract uniswapRouter;
  DeployedContract multiSwapContract;

  SwapService({@required this.ethService, @required this.privateKey}) {
    // TODO (@CodingDavid8): properly handle async stuff
    // all functions have to await initialization, maybe put await check in checkWallet.
    _init();
  }

  _init() async {
    this.automaticMarketMakerContract = await ethService.loadContract("amm");
    this.staticSalePrice = await ethService.loadContract("sps");
    this.uniswapRouter = await ethService.loadContract("uniswap_router");
    this.multiSwapContract =
        await ethService.loadContract("multi_swap_contract");
  }

  Future<Credentials> get credentials =>
      ethService.credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await ethService.credentialsForKey(privateKey)).extractAddress();

  bool checkWallet() {
    return ethService != null && this.privateKey != null;
  }

  Future<List<String>> getPath(from, to) async {
    String allPaths = await rootBundle.loadString(GRAPH_PATH);
    final decodedPaths = jsonDecode(allPaths);
    final path = (decodedPaths[from][to] as List<dynamic>)
        .map((e) => e.toString().toLowerCase())
        .toList();
    return path;
  }

  Future<String> getTokenBalance(tokenName) async {
    if (!this.checkWallet()) return "0";

    if (tokenName == "eth") {
      var res = await ethService.getEtherBalance(await credentials);
      return EthereumService.fromWei(res.getInWei, tokenName);
    }
    final tokenContract = await ethService.loadTokenContract(tokenName);
    final result =
        await ethService.query(tokenContract, "balanceOf", [await address]);
    return EthereumService.fromWei(result.single, tokenName);
  }

  Future<String> approve(String token) async {
    if (!this.checkWallet()) return "0";

    final tokenContract = await ethService.loadTokenContract(token);
    var amount = "10000000";
    final result =
        await ethService.submit(await credentials, tokenContract, "approve", [
      await ethService.getAddr("multi_swap_contract"),
      EthereumService.getWei(amount, token)
    ]);
    return result;
  }

  Future<String> getAllowances(String tokenName) async {
    if (!this.checkWallet()) return "0";
    if (tokenName == "eth") return "999999";

    final tokenContract = await ethService.loadTokenContract(tokenName);

    final result = await ethService.query(tokenContract, "allowance",
        [await address, await ethService.getAddr("multi_swap_contract")]);
    return EthereumService.fromWei(result.single, tokenName);
  }

  Future<String> sendSwapTransaction(Transaction transaction) async {
    return await ethService.sendTransaction(await credentials, transaction);
  }

  Future<Transaction> makeSwapTransaction(
      fromToken, toToken, String _amountIn, String _minAmountOut,) async {
    if (!this.checkWallet()) return null;
    var path = await getPath(fromToken, toToken);

    BigInt amountIn = EthereumService.getWei(_amountIn, fromToken);
    BigInt minAmountOut = EthereumService.getWei(_minAmountOut, toToken);

    if (fromToken == 'eth' && toToken == 'deus') {
      return await ethService.makeTransaction(await credentials,
          automaticMarketMakerContract, "buy", [minAmountOut],
          value: EtherAmount.inWei(amountIn));
    }
    if (fromToken == 'deus' && toToken == 'eth') {
      return await ethService.makeTransaction(await credentials,
          multiSwapContract, "uniDeusEth", [amountIn, [], minAmountOut],
          );
    }

    final deusAddress = await ethService.getTokenAddrHex("deus", "token");
    int deusIndex = path.indexOf(deusAddress);
    if (deusIndex == -1) {
      if (path[0] == await ethService.getTokenAddrHex("weth", "token")) {
        var deadLine = (DateTime.now().millisecond / 1000).floor() + 60 * 5000;
        List<EthereumAddress> addressPath = _pathListToAddresses(path);
        return await ethService.makeTransaction(
            await credentials,
            uniswapRouter,
            "swapExactETHForTokens",
            [minAmountOut, addressPath, await address, BigInt.from(deadLine)],
            value: EtherAmount.inWei(amountIn),
            );
      }
      if (path.last == await ethService.getTokenAddrHex("weth", "token")) {
        List<EthereumAddress> addressPath = _pathListToAddresses(path);
        return await ethService.makeTransaction(
            await credentials,
            multiSwapContract,
            "tokensToEthOnUni",
            [amountIn, addressPath, minAmountOut]);
      }
      List<EthereumAddress> addressPath = _pathListToAddresses(path);
      return await ethService.makeTransaction(
          await credentials,
          multiSwapContract,
          "tokensToTokensOnUni",
          [amountIn, addressPath, minAmountOut]);
    }

    if (deusIndex == path.length - 1) {
      if (path[path.length - 2] ==
          await ethService.getTokenAddrHex("weth", "token")) {
        var path1 = path.sublist(0, deusIndex);
        var path2 = [];
        List<EthereumAddress> addressPath = _pathListToAddresses(path1);
        return await ethService.makeTransaction(
            await credentials,
            multiSwapContract,
            "uniEthDeusUni",
            [amountIn, addressPath, path2, minAmountOut]);
      }
      List<EthereumAddress> addressPath = _pathListToAddresses(path);
      return await ethService.makeTransaction(
          await credentials,
          multiSwapContract,
          "tokensToTokensOnUni",
          [amountIn, addressPath, minAmountOut]);
    }

    if (deusIndex == 0) {
      if (path[1] == await ethService.getTokenAddrHex("weth", "token")) {
        var path1 = path.sublist(1);
        List<EthereumAddress> addressPath = _pathListToAddresses(path1);
        return await ethService.makeTransaction(
            await credentials,
            multiSwapContract,
            "deusEthUni",
            [amountIn, addressPath, minAmountOut]);
      }
      List<EthereumAddress> addressPath = _pathListToAddresses(path);
      return await ethService.makeTransaction(
          await credentials,
          multiSwapContract,
          "tokensToTokensOnUni",
          [amountIn, addressPath, minAmountOut]);
    }
    if (path[deusIndex - 1] ==
        await ethService.getTokenAddrHex("weth", "token")) {
      var path1 = path.sublist(0, deusIndex);
      var path2 = path.sublist(deusIndex);
      List<EthereumAddress> addressPath1 = _pathListToAddresses(path1);
      List<EthereumAddress> addressPath2 = _pathListToAddresses(path2);
      if (path1.length > 1) {
        return await ethService.makeTransaction(
            await credentials,
            multiSwapContract,
            "uniEthDeusUni",
            [amountIn, addressPath1, addressPath2, minAmountOut]);
      }
      var path3 = path.sublist(deusIndex);
      List<EthereumAddress> addressPath = _pathListToAddresses(path3);
      return await ethService.makeTransaction(await credentials,
          multiSwapContract, "ethDeusUni", [addressPath, minAmountOut],
          value: EtherAmount.inWei(amountIn));
    }

    if (path[deusIndex + 1] ==
        await ethService.getTokenAddrHex("weth", "token")) {
      var path1 = path.sublist(0, deusIndex + 1);
      var path2 = path.sublist(deusIndex + 1);
      List<EthereumAddress> addressPath1 = _pathListToAddresses(path1);
      List<EthereumAddress> addressPath2 = _pathListToAddresses(path2);
      if (path1.length >= 2 && path2.length <= 1) {
        return await ethService.makeTransaction(
            await credentials,
            multiSwapContract,
            "uniDeusEth",
            [amountIn, addressPath1, minAmountOut]);
      }
      if (path1.length >= 2 && path2.length >= 2) {
        return await ethService.makeTransaction(
            await credentials,
            multiSwapContract,
            "uniDeusEthUni",
            [amountIn, addressPath1, addressPath2, minAmountOut]);
      }
    }

    return null;
  }

  Future<String> swapTokens(
      fromToken, toToken, String _amountIn, String _minAmountOut, Gas gas) async {
    if (!this.checkWallet()) return "0";
    var path = await getPath(fromToken, toToken);

    BigInt amountIn = EthereumService.getWei(_amountIn, fromToken);
    BigInt minAmountOut = EthereumService.getWei(_minAmountOut, toToken);

    if (fromToken == 'eth' && toToken == 'deus') {
      return await ethService.submit(await credentials,
          automaticMarketMakerContract, "buy", [minAmountOut],
          value: EtherAmount.inWei(amountIn),gas: gas);
    }
    if (fromToken == 'deus' && toToken == 'eth') {
      return await ethService.submit(await credentials, multiSwapContract,
          "uniDeusEth", [amountIn, [], minAmountOut],gas: gas);
    }

    final deusAddress = await ethService.getTokenAddrHex("deus", "token");
    int deusIndex = path.indexOf(deusAddress);
    if (deusIndex == -1) {
      if (path[0] == await ethService.getTokenAddrHex("weth", "token")) {
        var deadLine = (DateTime.now().millisecond / 1000).floor() + 60 * 5000;
        List<EthereumAddress> addressPath = _pathListToAddresses(path);
        return await ethService.submit(
            await credentials,
            uniswapRouter,
            "swapExactETHForTokens",
            [minAmountOut, addressPath, await address, BigInt.from(deadLine)],
            value: EtherAmount.inWei(amountIn),gas: gas);
      }
      if (path.last == await ethService.getTokenAddrHex("weth", "token")) {
        List<EthereumAddress> addressPath = _pathListToAddresses(path);
        return await ethService.submit(await credentials, multiSwapContract,
            "tokensToEthOnUni", [amountIn, addressPath, minAmountOut],gas: gas);
      }
      List<EthereumAddress> addressPath = _pathListToAddresses(path);
      return await ethService.submit(await credentials, multiSwapContract,
          "tokensToTokensOnUni", [amountIn, addressPath, minAmountOut],gas: gas);
    }

    if (deusIndex == path.length - 1) {
      if (path[path.length - 2] ==
          await ethService.getTokenAddrHex("weth", "token")) {
        var path1 = path.sublist(0, deusIndex);
        var path2 = [];
        List<EthereumAddress> addressPath = _pathListToAddresses(path1);
        return await ethService.submit(await credentials, multiSwapContract,
            "uniEthDeusUni", [amountIn, addressPath, path2, minAmountOut],gas: gas);
      }
      List<EthereumAddress> addressPath = _pathListToAddresses(path);
      return await ethService.submit(await credentials, multiSwapContract,
          "tokensToTokensOnUni", [amountIn, addressPath, minAmountOut],gas: gas);
    }

    if (deusIndex == 0) {
      if (path[1] == await ethService.getTokenAddrHex("weth", "token")) {
        var path1 = path.sublist(1);
        List<EthereumAddress> addressPath = _pathListToAddresses(path1);
        return await ethService.submit(await credentials, multiSwapContract,
            "deusEthUni", [amountIn, addressPath, minAmountOut],gas: gas);
      }
      List<EthereumAddress> addressPath = _pathListToAddresses(path);
      return await ethService.submit(await credentials, multiSwapContract,
          "tokensToTokensOnUni", [amountIn, addressPath, minAmountOut],gas: gas);
    }
    if (path[deusIndex - 1] ==
        await ethService.getTokenAddrHex("weth", "token")) {
      var path1 = path.sublist(0, deusIndex);
      var path2 = path.sublist(deusIndex);
      List<EthereumAddress> addressPath1 = _pathListToAddresses(path1);
      List<EthereumAddress> addressPath2 = _pathListToAddresses(path2);
      if (path1.length > 1) {
        return await ethService.submit(
            await credentials,
            multiSwapContract,
            "uniEthDeusUni",
            [amountIn, addressPath1, addressPath2, minAmountOut],gas: gas);
      }
      var path3 = path.sublist(deusIndex);
      List<EthereumAddress> addressPath = _pathListToAddresses(path3);
      return await ethService.submit(await credentials, multiSwapContract,
          "ethDeusUni", [addressPath, minAmountOut],
          value: EtherAmount.inWei(amountIn),gas: gas);
    }

    if (path[deusIndex + 1] ==
        await ethService.getTokenAddrHex("weth", "token")) {
      var path1 = path.sublist(0, deusIndex + 1);
      var path2 = path.sublist(deusIndex + 1);
      List<EthereumAddress> addressPath1 = _pathListToAddresses(path1);
      List<EthereumAddress> addressPath2 = _pathListToAddresses(path2);
      if (path1.length >= 2 && path2.length <= 1) {
        return await ethService.submit(await credentials, multiSwapContract,
            "uniDeusEth", [amountIn, addressPath1, minAmountOut],gas: gas);
      }
      if (path1.length >= 2 && path2.length >= 2) {
        return await ethService.submit(
            await credentials,
            multiSwapContract,
            "uniDeusEthUni",
            [amountIn, addressPath1, addressPath2, minAmountOut],gas: gas);
      }
    }

    return "0";
  }

  List<EthereumAddress> _pathListToAddresses(List<String> paths) {
    return paths.map((path) => EthereumAddress.fromHex(path)).toList();
  }

  Future<String> getWithdrawableAmount() async {
    if (!checkWallet()) return "0";
    final amount = await ethService
        .query(automaticMarketMakerContract, "payments", [await address]);
    return EthereumService.fromWei(amount.first, "ether");
  }

  Future<String> withdrawPayment() async {
    return await ethService.submit(await credentials,
        automaticMarketMakerContract, "withdrawPayments", [await address]);
  }

  Future<String> getAmountsOut(
      String fromToken, String toToken, String _amountIn) async {
    if (!checkWallet()) return "0";

    BigInt amountIn = EthereumService.getWei(_amountIn, fromToken);
    var path = await getPath(fromToken, toToken);

    if (fromToken == "deus" && toToken == "eth") {
      final result = await _ammSaleReturn(amountIn);
      return EthereumService.fromWei(result, toToken);
    } else if (fromToken == "eth" && toToken == "deus") {
      final result = await _ammPurchaseReturn(amountIn);
      return EthereumService.fromWei(result, toToken);
    }
    final deusAddress = await ethService.getTokenAddrHex("deus", "token");
    final indexOfDeus = path.indexOf(deusAddress);

    if (indexOfDeus == -1) {
      final amountsOut = await _uniSwapAmountOut(amountIn, path);
      return EthereumService.fromWei(amountsOut, toToken);
    }
    if (indexOfDeus == path.length - 1) {
      if (path[path.length - 2] ==
          await ethService.getTokenAddrHex("weth", "token")) {
        path = path.sublist(0, path.length - 1);
        final amountsOut = await _uniSwapAmountOut(amountIn, path);
        final tokenAmount = await _ammPurchaseReturn(amountsOut);
        return EthereumService.fromWei(tokenAmount, toToken);
      } else {
        final amountsOut = await _uniSwapAmountOut(amountIn, path);
        return EthereumService.fromWei(amountsOut, toToken);
      }
    }
    if (indexOfDeus == 0) {
      if (path[1] == await ethService.getTokenAddrHex("weth", "token")) {
        path = path.sublist(1);
        final tokenAmount = await _ammSaleReturn(amountIn);
        final amountOut = await _uniSwapAmountOut(tokenAmount, path);
        return EthereumService.fromWei(amountOut, toToken);
      } else {
        final amountsOut = await _uniSwapAmountOut(amountIn, path);
        return EthereumService.fromWei(amountsOut, toToken);
      }
    }
    if (path[indexOfDeus - 1] ==
        await ethService.getTokenAddrHex("weth", "token")) {
      final path1 = path.sublist(0, indexOfDeus);
      final path2 = path.sublist(indexOfDeus);
      if (path1.length > 1) {
        final amountsOut = await _uniSwapAmountOut(amountIn, path1);

        final tokenAmount = await _ammPurchaseReturn(amountsOut);
        if (path2.length > 1) {
          final amountOut = await _uniSwapAmountOut(
            tokenAmount,
            path2,
          );
          return EthereumService.fromWei(amountOut, toToken);
        } else {
          return EthereumService.fromWei(tokenAmount, toToken);
        }
      } else {
        final tokenAmount = await _ammPurchaseReturn(amountIn);
        if (path2.length > 1) {
          final amountOut = await _uniSwapAmountOut(
            tokenAmount,
            path2,
          );
          return EthereumService.fromWei(amountOut, toToken);
        } else {
          return EthereumService.fromWei(tokenAmount, toToken);
        }
      }
    }

    if (path[indexOfDeus + 1] ==
        await ethService.getTokenAddrHex("weth", "token")) {
      final path1 = path.sublist(0, indexOfDeus + 1);
      final path2 = path.sublist(indexOfDeus + 1);
      if (path1.length > 1) {
        final amountsOut2 = await _uniSwapAmountOut(amountIn, path1);
        final tokenAmount = await _ammSaleReturn(amountsOut2);
        if (path2.length > 1) {
          final amountOut = await _uniSwapAmountOut(
            tokenAmount,
            path2,
          );
          return EthereumService.fromWei(amountOut, toToken);
        } else {
          return EthereumService.fromWei(tokenAmount, toToken);
        }
      } else {
        final tokenAmount = await _ammSaleReturn(amountIn);
        if (path2.length > 1) {
          final amountOut = await _uniSwapAmountOut(
            tokenAmount,
            path2,
          );
          return EthereumService.fromWei(amountOut, toToken);
        } else {
          return EthereumService.fromWei(tokenAmount, toToken);
        }
      }
    } else {
      final amountsOut = await _uniSwapAmountOut(amountIn, path);
      return EthereumService.fromWei(amountsOut, toToken);
    }
  }

  Future<BigInt> _uniSwapAmountOut(BigInt amountIn, List<String> path) async {
    List<EthereumAddress> addressPath = _pathListToAddresses(path);
    final result = await ethService
        .query(uniswapRouter, "getAmountsOut", [amountIn, addressPath]);
    return result[0][result[0].length - 1] as BigInt;
  }

  Future<BigInt> _ammPurchaseReturn(BigInt amountIn) async {
    final result = await ethService.query(
        automaticMarketMakerContract, "calculatePurchaseReturn", [amountIn]);
    return result[0] as BigInt;
  }

  Future<BigInt> _ammSaleReturn(BigInt amountIn) async {
    final result = await ethService
        .query(automaticMarketMakerContract, "calculateSaleReturn", [amountIn]);
    return result[0] as BigInt;
  }

  getAmountsIn(fromToken, toToken, amountOut) async {
    return -1;
  }
}
