import 'package:deus_mobile/config.dart';
import 'package:deus_mobile/service/ethereum_service.dart';

enum Status { PENDING, SUCCESSFUL, FAILED }

class TransactionStatus {
  String message;
  String label;
  String hash;
  Status status;

  TransactionStatus(this.message, this.status, this.label, [this.hash = ""]);

  String getMessage() {
    // String fullMessage = "";
    // if (status == PENDING) fullMessage += "Pending\n";
    // if (status == SUCCESSFUL) fullMessage += "Successful\n";
    // if (status == FAILED) fullMessage += "Failed\n";
    return message;
  }

  String transactionUrl({int chainId}) {
    if(chainId != null) {
      if (chainId == 100)
        return "https://blockscout.com/xdai/mainnet/tx/" + hash;
      if(chainId == 1)
        return "https://mainnet.etherscan.io/tx/" + hash;
    //  heco
      if(chainId == 128){
        return "https://hecoinfo.com/tx/" + hash;
      }
      // bsc
      if(chainId == 97)
        return "https://bscscan.com/tx/" + hash;

    }else {
        String prefix = '';
        final int currentChainId = AppConfig.selectedConfig.params.chainId;
        if (currentChainId != 1) prefix =
            EthereumService.NETWORK_NAMES[currentChainId].toLowerCase() + '.';
        return "https://${prefix}etherscan.io/tx/" + hash;
      }
  }
}
