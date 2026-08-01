import '../models/content_model.dart';

class MockData {
  MockData._();

  static final List<ContentModel> allContent = [
    ContentModel(
      id: '1',
      title: 'Doom: The Beginning',
      description:
          'A young warrior discovers ancient dark magic that threatens to consume the entire realm. He must embark on a dangerous journey to seal the breach before the time runs out.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      duration: '2h 10m',
      releaseYear: '2025',
      rating: '18+',
      genres: ['Action', 'Sci-Fi', 'Fantasy'],
      cast: ['Karl Urban', 'Rosamund Pike', 'Dwayne Johnson'],
      isMovie: true,
      category: 'Featured',
    ),
    ContentModel(
      id: '2',
      title: 'Tears of Steel',
      description:
          'Set in an alternate dystopian future where giant robotic structures roam the empty cities, a group of scientists attempts to restart a time machine to prevent the collapse.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      duration: '12m 14s',
      releaseYear: '2024',
      rating: 'PG-13',
      genres: ['Sci-Fi', 'Dystopian', 'Drama'],
      cast: ['Derek de Lint', 'Rogier Schippers', 'Jody Bhe'],
      isMovie: true,
      category: 'Trending Now',
    ),
    ContentModel(
      id: '3',
      title: 'Sintel: The Quest',
      description:
          'A lonely girl named Sintel rescues a baby dragon and names him Scales. When the dragon is kidnapped by an adult beast, Sintel embarks on a lifelong search.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1478720143022-9099477e622b?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      duration: '14m 48s',
      releaseYear: '2023',
      rating: 'PG',
      genres: ['Adventure', 'Animation', 'Fantasy'],
      cast: ['Halina Reijn', 'Thom Hoffman'],
      isMovie: true,
      category: 'Trending Now',
    ),
    ContentModel(
      id: '4',
      title: 'Bigger Fun: The Reunion',
      description:
          'A comedy drama about old college friends reuniting in a remote cabin for a weekend, only to realize how much they have drifted apart and what secrets they have kept.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1514306191717-452ec28c7814?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      duration: '15m 0s',
      releaseYear: '2024',
      rating: '13+',
      genres: ['Comedy', 'Drama'],
      cast: ['Ryan Reynolds', 'Sandra Bullock', 'Jason Bateman'],
      isMovie: true,
      category: 'Continue Watching',
    ),
    ContentModel(
      id: '5',
      title: 'For Bigger Blazes',
      description:
          'An action-packed thriller following high-speed firefighters in a futuristic city who solve criminal conspiracies alongside putting out blazing corporate infernos.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      duration: '1h 45m',
      releaseYear: '2024',
      rating: '16+',
      genres: ['Action', 'Thriller'],
      cast: ['Chris Hemsworth', 'David Harbour'],
      isMovie: true,
      category: 'Continue Watching',
    ),
    ContentModel(
      id: '6',
      title: 'Cosmic Journey',
      description:
          'An educational TV series diving deep into the secrets of the cosmos, from the birth of stars to black holes and the hypothetical end of the universe.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      duration: '10 Episodes',
      releaseYear: '2025',
      rating: 'All',
      genres: ['Documentary', 'Science'],
      cast: ['Neil deGrasse Tyson', 'Brian Cox'],
      isMovie: false,
      category: 'TV Shows',
    ),
    ContentModel(
      id: '7',
      title: 'Whispers of the Deep',
      description:
          'A deep-sea research submarine loses connection with the surface after discovering an underwater city that shouldn\'t exist.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      duration: '2 Seasons',
      releaseYear: '2025',
      rating: '16+',
      genres: ['Mystery', 'Thriller', 'Sci-Fi'],
      cast: ['Jessica Chastain', 'Cillian Murphy'],
      isMovie: false,
      category: 'TV Shows',
    ),
    ContentModel(
      id: '8',
      title: 'The Great Joyride',
      description:
          'Two siblings steal a state-of-the-art hovercar to go on a joyride across the megacity, only to find the car contains high-level corporate data.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=600&auto=format&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      duration: '1h 32m',
      releaseYear: '2025',
      rating: 'PG-13',
      genres: ['Action', 'Comedy', 'Adventure'],
      cast: ['Tom Holland', 'Zendaya'],
      isMovie: true,
      category: 'Movies',
    ),
  ];

  static const List<Map<String, dynamic>> mockTiers = [
    {
      'id': 'free',
      'name': 'Doom Free',
      'price': '\$0/month',
      'description': 'Ad-supported streaming, SD quality, 1 screen max.',
    },
    {
      'id': 'premium',
      'name': 'Doom Premium',
      'price': '\$9.99/month',
      'description': 'Ad-free, Full HD, download support, 2 screens max.',
    },
    {
      'id': 'vip',
      'name': 'Doom VIP',
      'price': '\$14.99/month',
      'description':
          'Ad-free, 4K Ultra HD + HDR, offline caching, 4 screens max + family sharing.',
    },
  ];
}
