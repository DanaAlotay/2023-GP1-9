class Event {
  final String name;
  final String description;
  final String classification;

  final String id;

  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String reservation;
  final String imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.reservation,
    required this.imageUrl,
    required this.classification,
  });
}
