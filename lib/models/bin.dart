class Bin {
  final int id;
  final String title;
  final int imageCount;
  

  Bin({
    required this.id,
    required this.title,
    required this.imageCount,
  });

  Bin.fromMap(Map<String, dynamic> map)
      : 
        id = map['id'],
        title = map['title'],
        imageCount = map['image_count'];
        
}
