import 'package:flutter/material.dart';

class NonMusicContent extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const NonMusicContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < data.length; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          data[i]['image'] ?? '',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[800],
                            child: const Icon(Icons.person,
                                size: 50, color: Colors.white54),
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(data[i]['name'] ?? 'Unknown',
                            style: const TextStyle(
                                fontSize: 15,
                                fontFamily: "SpotifyCircularBold",
                                color: Colors.white),
                            textAlign: TextAlign.left,
                            softWrap: false,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }
}
