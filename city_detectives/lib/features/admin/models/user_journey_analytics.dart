/// Étape du parcours utilisateur (Story 7.4 – FR71).
class JourneyStep {
  const JourneyStep({required this.label, required this.userCount});

  final String label;
  final int userCount;

  factory JourneyStep.fromJson(Map<String, dynamic> json) {
    return JourneyStep(
      label: json['label'] as String? ?? '',
      userCount: (json['userCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Parcours utilisateur (funnel) pour le dashboard admin (Story 7.4 – FR71).
class UserJourneyAnalytics {
  const UserJourneyAnalytics({required this.funnelSteps});

  final List<JourneyStep> funnelSteps;

  factory UserJourneyAnalytics.fromJson(Map<String, dynamic> json) {
    final list = json['funnelSteps'] as List<dynamic>? ?? [];
    return UserJourneyAnalytics(
      funnelSteps: list
          .map((e) => JourneyStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
