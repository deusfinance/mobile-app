import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

import 'ethereum_service.dart';

///DEUS-Specific service for swapping tokens.
///
///Majorly based on the React.js Webapp Swap Service.
//TODO (@CodingDavid8): Refactor service & improve code styling.
class DeusSwapService {
  static const GRAPHBK_PATH = "assets/deus_data/graphbk.json";
  static const TOKEN_MAX_DIGITS = {
    "wbtc": 8,
    "usdt": 6,
    "usdc": 6,
    "coinbase": 18,
    "dea": 18,
    "deus": 18,
    "dai": 18,
    "eth": 18,
  };

  final EthereumService ethService;

  // will probably be a web3 PrivateKey
  // this.account = account;
  final String privateKey;

  DeployedContract automaticMarketMakerContract;
  DeployedContract staticSalePrice;
  DeployedContract deusSwapContract;
  DeployedContract uniswapRouter;

  DeusSwapService({@required this.ethService, @required this.privateKey}) {
    // TODO (@CodingDavid8): properly handle async stuff
    // all functions have to await initialization, maybe put await check in checkWallet.
    _init();
  }

  _init() async {
    this.automaticMarketMakerContract = await ethService.loadContract("amm");
    this.staticSalePrice = await ethService.loadContract("sps");
    this.deusSwapContract = await ethService.loadContract("deus_swap_contract");
    this.uniswapRouter = await ethService.loadContract("uniswap_router");
  }

  Future<Credentials> get credentials =>
      ethService.credentialsForKey(privateKey);

  Future<EthereumAddress> get address async =>
      (await ethService.credentialsForKey(privateKey)).extractAddress();

  bool checkWallet() {
    return ethService != null && this.privateKey != null;
  }

  BigInt _getWei(BigInt amount, [String token = "eth"]) {
    var max =
        TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
    // let value = typeof number === "string" ? parseFloat(number).toFixed(18) : number.toFixed(18)
    var ans = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount)
        .getInWei
        .toString();
    ans = ans.substring(0, ans.length - (18 - max));
    return BigInt.parse(ans.toString());
  }

  String _fromWei(BigInt value, String token) {
    var max =
        TOKEN_MAX_DIGITS.containsKey(token) ? TOKEN_MAX_DIGITS[token] : 18;
    String ans = value.toString();

    while (ans.length < max) {
      ans = "0" + ans;
    }
    ans = ans.substring(0, ans.length - max) +
        "." +
        ans.substring(ans.length - max);
    if (ans[0] == ".") {
      ans = "0" + ans;
    }
    return ans;
  }

  Future<List<String>> _getPath(from, to) async {
    String allPaths = await rootBundle.loadString(GRAPHBK_PATH);
    final decodedPaths = jsonDecode(allPaths);
    final path = (decodedPaths[from][to] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    return path;
  }

  Future<String> getTokenBalance(tokenName) async {
    if (!this.checkWallet()) return "0";

    if (tokenName == "eth") {
      return (await ethService.getEtherBalance(await credentials))
          .getInEther
          .toString();
    }
    final tokenContract = await ethService.loadContract("token");

    EthereumAddress address = await (await credentials).extractAddress();
    final result =
        await ethService.query(tokenContract, "balanceOf", [address]);

    return this._fromWei(result.single, tokenName);
  }

  Future<String> approve(String token) async { // , BigInt amount
    if (!this.checkWallet()) return "0";

    // final tokenContract = await ethereumService.loadContract("token");
    final tokenContract = await ethService.loadTokenContract(token);
    var amount = BigInt.from(pow(10, 25));
//    var maxAmount = BigInt.from(pow(10, 20));
//    amount = (amount > maxAmount) ? amount : maxAmount;

    final swapContractAddress =
        await ethService.getContractAddress("deus_swap_contract");
    final wei = _getWei(amount, token);
    final result = await ethService.submit(await credentials, tokenContract,
        "approve", [swapContractAddress, wei]);
    return result;
  }

  Future<String> getAllowances(String tokenName) async {
    if (!this.checkWallet()) return "0";
    if (tokenName == "eth") return "9999";

    final tokenContract = await ethService.loadTokenContract(tokenName);
    final swapContractAddress =
        await ethService.getContractAddress("deus_swap_contract");

    final result = await ethService.query(
        tokenContract, "allowance", [await address, swapContractAddress]);
    BigInt allowance = result.single;
    return _fromWei(allowance, tokenName);
  }

  // TODO make bigint
  Future<String> swapTokens(fromToken, toToken, tokenAmount) async {
    if (!this.checkWallet()) return null;
    var path = await _getPath(fromToken, toToken);

    if (fromToken == "coinbase") {
      if (toToken == "deus") {
        return _deusSwapTokensForTokens(tokenAmount, fromToken, 8, [], []);
      } else if (toToken == "eth") {
        return _deusSwapTokensForEth(tokenAmount, fromToken, 2, []);
      } else {
        if (path[2] == await ethService.getTokenAddrHex("weth")) {
          var path1 = path.sublist(2);
          return _deusSwapTokensForTokens(
              tokenAmount, fromToken, 4, _pathListToAddresses(path1), []);
        } else {
          var path1 = path.sublist(1);
          return _deusSwapTokensForTokens(
              tokenAmount, fromToken, 3, _pathListToAddresses(path1), []);
        }
      }
    } else if (toToken == "coinbase") {
      if (fromToken == "deus") {
        return _deusSwapTokensForTokens(tokenAmount, fromToken, 7, [], []);
      } else if (fromToken == 'eth') {
        return _deusSwapEthForTokens(tokenAmount, fromToken, 2, []);
      } else {
        if (path[path.length - 3] == await ethService.getTokenAddrHex("weth")) {
          final path1 = path.sublist(0, path.length - 2);
          return _deusSwapTokensForTokens(
              tokenAmount, fromToken, 5, _pathListToAddresses(path1), []);
        } else {
          final path1 = path.sublist(0, path.length - 1);
          return _deusSwapTokensForTokens(
              tokenAmount, fromToken, 6, _pathListToAddresses(path1), []);
        }
      }
      ///////////
    } else {
      if (fromToken == 'eth') {
        if (path[1] == await ethService.getTokenAddrHex("deus")) {
          path = path.sublist(1);
          return _deusSwapEthForTokens(
              tokenAmount, fromToken, 0, _pathListToAddresses(path));
        } else {
          return _deusSwapEthForTokens(
              tokenAmount, fromToken, 1, _pathListToAddresses(path));
        }
      } else if (toToken == 'eth') {
        if (path[path.length - 2] == await ethService.getTokenAddrHex("deus")) {
          path = path.sublist(0, path.length - 1);
          return _deusSwapTokensForEth(
              tokenAmount, fromToken, 0, _pathListToAddresses(path));
        } else {
          return _deusSwapTokensForEth(
              tokenAmount, fromToken, 1, _pathListToAddresses(path));
        }
      } else {
        var indexOfDeus =
            path.indexOf(await ethService.getTokenAddrHex("deus"));
        if (indexOfDeus != -1) {
          if (indexOfDeus < path.length - 1) {
            final path1 = path.sublist(0, indexOfDeus + 1);
            final path2 = path.sublist(indexOfDeus + 1);
            return _deusSwapTokensForTokens(tokenAmount, fromToken, 1,
                _pathListToAddresses(path1), _pathListToAddresses(path2));
          } else if (indexOfDeus > 0) {
            final path1 = path.sublist(0, indexOfDeus);
            final path2 = path.sublist(indexOfDeus);
            return _deusSwapTokensForTokens(tokenAmount, fromToken, 0,
                _pathListToAddresses(path1), _pathListToAddresses(path2));
          }
        } else {
          return _deusSwapTokensForTokens(
              tokenAmount, fromToken, 2, _pathListToAddresses(path), []);
        }
      }
    }
  }

  List<EthereumAddress> _pathListToAddresses(List<String> paths) {
    return paths.map((path) => EthereumAddress.fromHex(path)).toList();
  }

  Future<String> _deusSwapTokensForTokens(
      BigInt tokenAmount,
      String fromToken,
      int swapType,
      List<EthereumAddress> path1,
      List<EthereumAddress> path2) async {
    final wei = this._getWei(tokenAmount, fromToken);
    return ethService.submit(await credentials, deusSwapContract,
        "swapTokensForTokens", [wei, BigInt.from(swapType), path1, path2]);
  }

  Future<String> _deusSwapTokensForEth(BigInt tokenAmount, String fromToken,
      int swapType, List<EthereumAddress> path) async {
    final wei = this._getWei(tokenAmount, fromToken);

    return ethService.submit(await credentials, deusSwapContract,
        "swapTokensForEth", [wei, BigInt.from(swapType), path]);
  }

  Future<String> _deusSwapEthForTokens(BigInt tokenAmount, String fromToken,
      int swapType, List<EthereumAddress> path) async {
    return ethService.submit(await credentials, deusSwapContract,
        "swapEthForTokens", [path, BigInt.from(swapType)],
        value: EtherAmount.inWei(this._getWei(tokenAmount, fromToken)));
  }

  Future<String> getWithdrawableAmount() async {
    if (!checkWallet()) return "0";
    final amount = await ethService
        .query(automaticMarketMakerContract, "payments", [await address]);
    return _fromWei(amount.first, "ether");
  }

  Future<String> withdrawPayment() async {
    return ethService.submit(await credentials, automaticMarketMakerContract,
        "withdrawPayments", [await address]);
  }

  Future<String> getAmountsOut(
      String fromToken, String toToken, BigInt amountIn) async {
    if (!checkWallet()) return "0";

    var path = await _getPath(fromToken, toToken);

    if (ethService.getTokenAddr(fromToken) == ethService.getTokenAddr("deus") &&
        ethService.getTokenAddr(toToken) == ethService.getTokenAddr("eth")) {
      final result = await _ammSaleReturn(amountIn, fromToken);

      return _fromWei(result, toToken);
    } else if (ethService.getTokenAddr(fromToken) ==
            ethService.getTokenAddr("eth") &&
        ethService.getTokenAddr(toToken) == ethService.getTokenAddr("deus")) {
      final result = await _ammPurchaseReturn(amountIn, fromToken);

      return _fromWei(result, toToken);
    }

    if (path[0] == await ethService.getTokenAddrHex("coinbase")) {
      if (path.length < 3) {
        final result = await _staticPriceSaleReturn(amountIn, fromToken);
        return this._fromWei(result, toToken);
      }

      path = path.sublist(1);

      if (path[1] == await ethService.getTokenAddrHex("weth")) {
        var tokenAmount = await _staticPriceSaleReturn(amountIn, fromToken);
        var etherAmount = await _ammSaleReturn(tokenAmount);
        path = path.sublist(1);
        if (path.length < 2) {
          return this._fromWei(etherAmount, toToken);
        } else {
          var amountsOut = await _uniSwapAmountOut(amountIn, path);
          return this._fromWei(amountsOut, toToken);
        }
      } else {
        final etherAmount = await _staticPriceSaleReturn(amountIn, fromToken);

        final amountsOut = await _uniSwapAmountOut(etherAmount, path);

        return this._fromWei(amountsOut, toToken);
      }
    } else if (path[path.length - 1] ==
        await ethService.getTokenAddrHex("coinbase")) {
      if (path.length < 3) {
        final tokenAmount =
            await _staticPricePurchaseReturn(amountIn, fromToken);
        return this._fromWei(tokenAmount, toToken);
      }
      path = path.sublist(0, path.length - 1);
      if (path[path.length - 2] == await ethService.getTokenAddrHex("weth")) {
        if (path.length > 2) {
          path = path.sublist(0, path.length - 1);
          final amountOut = await _uniSwapAmountOut(
            amountIn,
            path,
            fromToken,
          );
          final tokenAmount = await _ammPurchaseReturn(amountOut);
          final amountOutStatic = await _staticPricePurchaseReturn(tokenAmount);
          return _fromWei(amountOutStatic, toToken);
        } else {
          final tokenAmount = await _ammPurchaseReturn(amountIn, fromToken);
          final amountOut = await _staticPricePurchaseReturn(tokenAmount);
          return this._fromWei(amountOut, toToken);
        }
      } else {
        final amountsOut = await _uniSwapAmountOut(amountIn, path, fromToken);
        final tokenAmount = await _staticPricePurchaseReturn(amountsOut);
        return this._fromWei(tokenAmount, toToken);
      }
    } else {
      final deusAddress = await ethService.getTokenAddrHex("deus");
      final indexOfDeus = path.indexOf(deusAddress);

      if (indexOfDeus == -1) {
        final amountsOut = await _uniSwapAmountOut(amountIn, path, fromToken);
        return _fromWei(amountsOut, toToken);
      } else {
        if (indexOfDeus == path.length - 1) {
          if (path[path.length - 2] ==
              await ethService.getTokenAddrHex("weth")) {
            path = path.sublist(0, path.length - 1);
            final amountsOut =
                await _uniSwapAmountOut(amountIn, path, fromToken);
            final tokenAmount = await _ammPurchaseReturn(amountsOut);
            return this._fromWei(tokenAmount, toToken);
          } else {
            final amountsOut =
                await _uniSwapAmountOut(amountIn, path, fromToken);
            return this._fromWei(amountsOut, toToken);
          }
        } else if (indexOfDeus == 0) {
          if (path[1] == await ethService.getTokenAddrHex("weth")) {
            path = path.sublist(1);
            final tokenAmount = await _ammSaleReturn(amountIn, fromToken);
            final amountOut = await _uniSwapAmountOut(tokenAmount, path);
            return _fromWei(amountOut, toToken);
          } else {
            final amountsOut =
                await _uniSwapAmountOut(amountIn, path, fromToken);
            return this._fromWei(amountsOut, toToken);
          }
        } else {
          if (path[indexOfDeus - 1] ==
              await ethService.getTokenAddrHex("weth")) {
            final path1 = path.sublist(0, indexOfDeus);
            final path2 = path.sublist(indexOfDeus);
            if (path1.length > 1) {
              final amountsOut =
                  await _uniSwapAmountOut(amountIn, path1, fromToken);

              final tokenAmount = await _ammPurchaseReturn(amountsOut);
              if (path2.length > 1) {
                final amountOut = await _uniSwapAmountOut(
                  tokenAmount,
                  path2,
                );
                return this._fromWei(amountOut, toToken);
              } else {
                return this._fromWei(tokenAmount, toToken);
              }
            } else {
              final tokenAmount = await _ammPurchaseReturn(amountIn, fromToken);
              if (path2.length > 1) {
                final amountOut = await _uniSwapAmountOut(
                  tokenAmount,
                  path2,
                );
                return this._fromWei(amountOut, toToken);
              } else {
                return this._fromWei(tokenAmount, toToken);
              }
            }
          } else if (path[indexOfDeus + 1] ==
              await ethService.getTokenAddrHex("weth")) {
            final path1 = path.sublist(0, indexOfDeus + 1);
            final path2 = path.sublist(indexOfDeus + 1);
            if (path1.length > 1) {
              final amountsOut2 =
                  await _uniSwapAmountOut(amountIn, path1, fromToken);
              final tokenAmount = await _ammSaleReturn(amountsOut2);
              if (path2.length > 1) {
                final amountOut = await _uniSwapAmountOut(
                  tokenAmount,
                  path2,
                );
                return this._fromWei(amountOut, toToken);
              } else {
                return this._fromWei(tokenAmount, toToken);
              }
            } else {
              final tokenAmount = await _ammSaleReturn(amountIn, fromToken);
              if (path2.length > 1) {
                final amountOut = await _uniSwapAmountOut(
                  tokenAmount,
                  path2,
                );
                return this._fromWei(amountOut, toToken);
              } else {
                return this._fromWei(tokenAmount, toToken);
              }
            }
          } else {
            final amountsOut =
                await _uniSwapAmountOut(amountIn, path, fromToken);
            return this._fromWei(amountsOut, toToken);
          }
        }
      }
    }
  }

  Future<BigInt> _uniSwapAmountOut(BigInt amountIn, List<String> path,
      [String fromToken]) async {
    List<EthereumAddress> addressPath = _pathListToAddresses(path);
    final computeAmountInt =
        fromToken != null ? this._getWei(amountIn, fromToken) : amountIn;
    final result = await ethService
        .query(uniswapRouter, "getAmountsOut", [computeAmountInt, addressPath]);
    return result[result.length - 1] as BigInt;
  }

  Future<BigInt> _ammPurchaseReturn(BigInt amountIn, [String fromToken]) async {
    final computeAmountInt =
        fromToken != null ? this._getWei(amountIn, fromToken) : amountIn;
    final result = await ethService.query(automaticMarketMakerContract,
        "calculatePurchaseReturn", [computeAmountInt]);
    return result[0] as BigInt;
  }

  Future<BigInt> _ammSaleReturn(BigInt amountIn, [String fromToken]) async {
    final computeAmountInt =
        fromToken != null ? this._getWei(amountIn, fromToken) : amountIn;
    final result = await ethService.query(automaticMarketMakerContract,
        "calculateSaleReturn", [computeAmountInt]);
    return result[0] as BigInt;
  }

  Future<BigInt> _staticPricePurchaseReturn(BigInt amountIn,
      [String fromToken]) async {
    final computeAmountInt =
        fromToken != null ? this._getWei(amountIn, fromToken) : amountIn;
    final result = await ethService
        .query(staticSalePrice, "calculatePurchaseReturn", [computeAmountInt]);
    return result[0] as BigInt;
  }

  Future<BigInt> _staticPriceSaleReturn(BigInt amountIn,
      [String fromToken]) async {
    final computeAmountInt =
        fromToken != null ? this._getWei(amountIn, fromToken) : amountIn;
    final result = await ethService
        .query(staticSalePrice, "calculateSaleReturn", [computeAmountInt]);
    return result[0] as BigInt;
  }

  getAmountsIn(fromToken, toToken, amountOut) async {
    throw UnimplementedError("Source implementation missing");
  }

  approveStocks(BigInt amount, listener) async {
    if (!checkWallet()) return 0;

    final tokenContract = await ethService.loadTokenContract("dai");
    var maxAmount = BigInt.from(pow(10, 20));
    amount = (amount > maxAmount) ? amount : maxAmount;

    final wei = _getWei(amount, "ether");
    final result = await ethService.submit(
        await credentials,
        tokenContract,
        "approve",
        [await ethService.getContractAddress("stocks_contract"), wei]);
    return result;
  }

  getAllowancesStocks() async {
    if (!checkWallet()) return 0;

    final tokenContract = await ethService.loadTokenContract("dai");

    final result = await ethService.query(tokenContract, "allowance", [
      await address,
      await ethService.getContractAddress("stocks_contract")
    ]);

    return _fromWei(result.single, "dai");
  }

  buyStock(stockAddr, amount, blockNo, v, r, s, price, fee, listener) async {
    if (!checkWallet()) return 0;

    final stockContract = await ethService.loadContract("stocks_contract");

    final result = await ethService.submit(await credentials, stockContract,
        "buyStock", [stockAddr, amount, blockNo, v, r, s, price, fee]);
    return result;
  }

  sellStock(stockAddr, amount, blockNo, v, r, s, price, fee, listener) async {
    if (!checkWallet()) return 0;

    final stockContract = await ethService.loadContract("stocks_contract");

    final result = await ethService.submit(await credentials, stockContract,
        "sellStock", [stockAddr, amount, blockNo, v, r, s, price, fee]);
    return result;
  }
}
