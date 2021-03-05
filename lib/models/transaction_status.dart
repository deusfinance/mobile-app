
class TransactionStatus{
  static const PENDING = 0;
  static const SUCCESSFUL = 1;
  static const FAILED = 2;

  final String message;
  final String label;
  final int status;
  final String hash;


  const TransactionStatus(this.message, this.status, this.label, [this.hash = ""]);

  String getMessage(){
    String fullMessage = "";
    if (status == PENDING) fullMessage += "Pending\n";
    if (status == SUCCESSFUL) fullMessage += "Successful\n";
    if (status == FAILED) fullMessage += "Failed\n";
    return fullMessage + message;
  }

}