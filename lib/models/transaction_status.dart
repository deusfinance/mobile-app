
class TransactionStatus{
  static const PENDING = 0;
  static const SUCCESSFUL = 1;
  static const FAILED = 2;

  String message;
  int status;


  TransactionStatus(this.message, this.status);

  String getMessage(){
    String fullMessage = "";
    if (status == PENDING) fullMessage += "Pending\n";
    if (status == SUCCESSFUL) fullMessage += "Successful\n";
    if (status == FAILED) fullMessage += "Failed\n";
    return fullMessage + message;
  }

}