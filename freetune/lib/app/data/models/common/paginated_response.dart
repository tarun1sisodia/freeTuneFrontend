class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List<dynamic>;
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse<T>(
      data: dataList
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? 20,
      total: pagination['total'] as int? ?? dataList.length,
      hasMore: pagination['has_more'] as bool? ?? false,
    );
  }
}
