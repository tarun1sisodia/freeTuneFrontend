import 'package:equatable/equatable.dart';

class StreamUrlResponse extends Equatable {
  final String url;
  final String quality;
  final Duration expiresIn;

  const StreamUrlResponse({
    required this.url,
    required this.quality,
    required this.expiresIn,
  });

  factory StreamUrlResponse.fromJson(Map<String, dynamic> json) {
    // Backend wraps response in 'data' object
    final data = json['data'] ?? json;
    return StreamUrlResponse(
      url: data['streamUrl'] ?? data['url'],
      quality: data['quality'] ?? 'medium',
      expiresIn: Duration(seconds: data['expiresIn'] ?? 1800),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'quality': quality,
      'expiresIn': expiresIn.inSeconds,
    };
  }

  @override
  List<Object?> get props => [url, quality, expiresIn];
}