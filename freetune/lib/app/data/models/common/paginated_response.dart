import 'package:equatable/equatable.dart';

class PaginatedResponse<T> extends Equatable {
  final List<T> data;
  final int total;
  final int page;
  final int limit;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return PaginatedResponse(
      data: List<T>.from((json['data'] as List).map((x) => fromJsonT(x as Map<String, dynamic>))),
      total: (pagination['total'] as num?)?.toInt() ?? 0,
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      limit: (pagination['limit'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  List<Object?> get props => [data, total, page, limit];
}