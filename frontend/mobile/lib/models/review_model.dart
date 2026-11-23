class ReviewItem {
  final int step;
  final String title;
  final String detail;
  bool isCompleted;

  ReviewItem({
    required this.step,
    required this.title,
    required this.detail,
    this.isCompleted = false,
  });
}
