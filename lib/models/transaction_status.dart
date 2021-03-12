
enum Status{PENDING,SUCCESSFUL,FAILED}
class TransactionStatus{
  
  String message;
  String label;
  String hash;
  Status status;


  TransactionStatus(this.message, this.status, this.label, [this.hash = ""]);

  String getMessage(){
    // String fullMessage = "";
    // if (status == PENDING) fullMessage += "Pending\n";
    // if (status == SUCCESSFUL) fullMessage += "Successful\n";
    // if (status == FAILED) fullMessage += "Failed\n";
    return message;
  }

}