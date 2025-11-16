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
    return PaginatedResponse(
      data: List<T>.from(json['data'].map((x) => fromJsonT(x))),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }

  @override
  List<Object?> get props => [data, total, page, limit];
}