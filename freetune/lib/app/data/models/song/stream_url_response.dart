class StreamUrlResponse {
  final String url;
  final String quality;
  final int expiresIn;

  StreamUrlResponse({
    required this.url,
    required this.quality,
    required this.expiresIn,
  });

  factory StreamUrlResponse.fromJson(Map<String, dynamic> json) {
    return StreamUrlResponse(
      url: json['url'] as String,
      quality: json['quality'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'quality': quality,
      'expires_in': expiresIn,
    };
  }
}
