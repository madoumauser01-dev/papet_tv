class VideoItem {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String category; // 'Live TV', 'Movies', 'Series', 'Sports'
  final double rating;
  final String duration;
  final String releaseYear;
  final bool isLive;
  final int views;

  VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.category,
    required this.rating,
    required this.duration,
    required this.releaseYear,
    this.isLive = false,
    this.views = 0,
  });

  static List<VideoItem> get mockVideos => [
    VideoItem(
      id: '1',
      title: 'Canal Plus HD',
      description: 'Regardez vos films et séries préférés en direct sur Canal Plus HD.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      category: 'Live TV',
      rating: 4.8,
      duration: 'En direct',
      releaseYear: '2026',
      isLive: true,
      views: 12500,
    ),
    VideoItem(
      id: '2',
      title: 'TF1 Direct',
      description: 'Suivez le flux en direct de TF1, actualités, divertissement et sports.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1595603659983-e718c3762262?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      category: 'Live TV',
      rating: 4.5,
      duration: 'En direct',
      releaseYear: '2026',
      isLive: true,
      views: 9400,
    ),
    VideoItem(
      id: '3',
      title: 'Interstellar Odyssey',
      description: 'Une aventure cosmique palpitante à travers des trous noirs et de nouvelles galaxies habitables.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      category: 'Movies',
      rating: 4.9,
      duration: '2h 49m',
      releaseYear: '2024',
      views: 89000,
    ),
    VideoItem(
      id: '4',
      title: 'Shadow Hunter',
      description: 'Un détective d\'élite traque un syndicat criminel insaisissable agissant dans l\'ombre.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      category: 'Movies',
      rating: 4.6,
      duration: '2h 15m',
      releaseYear: '2025',
      views: 54000,
    ),
    VideoItem(
      id: '5',
      title: 'Cyberpunk 2099',
      description: 'L\'essor d\'une rébellion cyborg dans les bas-fonds d\'une mégalopole dystopique en 2099.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      category: 'Series',
      rating: 4.7,
      duration: '10 Épisodes',
      releaseYear: '2026',
      views: 120000,
    ),
    VideoItem(
      id: '6',
      title: 'Formula 1: Grand Prix',
      description: 'Vivez la course ultime du Grand Prix de Monaco en direct et en haute définition.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      category: 'Sports',
      rating: 4.9,
      duration: '3h 30m',
      releaseYear: '2026',
      isLive: true,
      views: 45000,
    ),
  ];
}
