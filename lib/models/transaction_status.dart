
class TransactionStatus{
  static const PENDING = 0;
  static const SUCCESSFUL = 1;
  static const FAILED = 2;

  String message;
  int status;


  TransactionStatus(this.message, this.status);

  String getMessage(){
    return "Successful\nApproved deus cakjv advkjdnjna askjnsk";
  }

}