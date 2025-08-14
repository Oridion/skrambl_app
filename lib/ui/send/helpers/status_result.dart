enum SendStatusResultType { submitted, failed, canceled }

class SendStatusResult {
  final SendStatusResultType type;
  final String? localId;
  final String? message;

  const SendStatusResult(this.type, {this.localId, this.message});

  const SendStatusResult.failed({this.localId, this.message}) : type = SendStatusResultType.failed;

  const SendStatusResult.submitted({this.localId, this.message}) : type = SendStatusResultType.submitted;

  const SendStatusResult.canceled({this.localId, this.message}) : type = SendStatusResultType.canceled;
}
