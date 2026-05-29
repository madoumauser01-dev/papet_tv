class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String subscriptionPlan; // 'Premium Ultra', 'Standard', 'Free'
  final bool isSubscribed;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    this.subscriptionPlan = 'Premium Ultra',
    this.isSubscribed = true,
  });

  static UserModel get mockUser => UserModel(
    uid: 'user_123',
    email: 'contact@papettv.com',
    displayName: 'Jean Papet',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
    subscriptionPlan: 'Premium Ultra 4K',
    isSubscribed: true,
  );
}
