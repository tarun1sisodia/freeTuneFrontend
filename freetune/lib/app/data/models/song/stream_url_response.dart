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
    return StreamUrlResponse(
      url: json['url'],
      quality: json['quality'],
      expiresIn: Duration(seconds: json['expiresIn']),
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