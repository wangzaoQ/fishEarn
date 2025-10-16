class QueueUser {
  String rank;
  String account;
  int amount;
  bool isCurrentUser;

  QueueUser({
    required this.rank,
    required this.account,
    required this.amount,
    this.isCurrentUser = false,
  });
  @override
  String toString() {
    return 'QueueUser(rank: $rank, account: $account, amount: $amount, isCurrentUser: $isCurrentUser)';
  }
}