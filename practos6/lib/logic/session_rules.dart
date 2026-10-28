class SessionRules {
  const SessionRules({
    required this.idle,
    required this.warning,
    required this.max,
  });

  final Duration idle;
  final Duration warning;
  final Duration max;

  bool idleExpired(Duration sinceActivity) => sinceActivity >= idle;

  bool maxExpired(Duration sinceLogin) => sinceLogin >= max;

  bool shouldWarn(Duration sinceActivity) =>
      sinceActivity >= idle - warning && !idleExpired(sinceActivity);

  Duration warningRemaining(Duration sinceActivity) {
    final remaining = idle - sinceActivity;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
