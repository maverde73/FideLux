/// Metadata associated with a chain event.
///
/// Tracks the source of the event, the trust level, and any AI engine involved.
class EventMetadata {
  const EventMetadata({
    required this.source,
    required this.trustLevel,
    this.aiEngine,
  });

  /// The source of the event.
  final EventSource source;

  /// Trust level (1-6) as defined in FIDELUX.md §5.5.
  final int trustLevel;

  /// The AI engine used, if any (e.g., "mlkit", "gemini").
  final String? aiEngine;

  /// Creates a copy of this metadata from a JSON map.
  factory EventMetadata.fromJson(Map<String, dynamic> json) {
    return EventMetadata(
      source: EventSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => EventSource.manual,
      ),
      trustLevel: json['trustLevel'] as int,
      aiEngine: json['aiEngine'] as String?,
    );
  }

  /// Converts this metadata to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'source': source.name,
      'trustLevel': trustLevel,
      if (aiEngine != null) 'aiEngine': aiEngine,
    };
  }
}

/// The origin source of an event.
enum EventSource {
  manual,
  ocr,
  bankSync,
  system,
  ai,
  email,
}
