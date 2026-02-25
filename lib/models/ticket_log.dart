/// Log entry per il ticket (caselog)
class TicketLog {
  final String date;
  final String userLogin;
  final String message;
  final String messageHtml;

  TicketLog({
    required this.date,
    required this.userLogin,
    required this.message,
    this.messageHtml = '',
  });

  factory TicketLog.fromJson(Map<String, dynamic> json) {
    return TicketLog(
      date: json['date']?.toString() ?? '',
      userLogin: json['user_login']?.toString() ?? '',
      message: _stripHtml(json['message']?.toString() ?? ''),
      messageHtml: json['message']?.toString() ?? '',
    );
  }

  /// Rimuove i tag HTML dal messaggio
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}
