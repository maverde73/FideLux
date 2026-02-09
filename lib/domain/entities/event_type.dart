/// Types of events supported by the FideLux append-only chain.
enum EventType {
  /// The first event in the chain (sequence 0).
  genesis,

  /// A financial transaction (expense or income).
  transaction,

  /// A correction to a previous transaction.
  correction,

  /// A receipt scan processed by OCR.
  receiptScan,

  /// A reconciliation event (matching bank statement to manual entry).
  reconciliation,

  /// Upload of a bank statement (PDF/CSV).
  statementUpload,

  /// Confirmation of a matched statement item.
  statementMatched,

  /// A new transaction found in a statement that wasn't manually entered.
  statementNew,

  /// A mismatch found between statement and manual entry.
  statementMismatch,

  /// A recurring transaction that is expected but not yet confirmed.
  recurringExpected,

  /// Confirmation of a recurring transaction.
  recurringConfirmed,

  /// An emergency SOS signal.
  sos,

  /// A privacy lock event (hides sensitive details).
  privacyLock,

  /// A system alert (e.g., suspicious activity).
  alert,

  /// A request for clarification from the Keeper.
  clarificationRequest,

  /// A response to a clarification request from the Sharer.
  clarificationResponse,

  /// A bank synchronization event.
  bankSynced,

  /// A configuration change (e.g., budget update).
  configChange,
}
