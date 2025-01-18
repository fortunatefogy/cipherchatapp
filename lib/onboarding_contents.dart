class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Ultimate Privacy",
    image: "assets/images/onbord1.png",
    desc: "Your messages are protected with cutting-edge encryption. Only you and your recipient can read them.",
  ),
  OnboardingContents(
    title: "Your Data, Your Rules",
    image: "assets/images/onbord2.png",
    desc:
        "We don’t track, share, or store your data. You are in complete control of your conversations.",
  ),
  OnboardingContents(
    title: "Fast & Reliable",
    image: "assets/images/onbord5.png",
    desc:
        "Chat seamlessly with friends and family, enjoying blazing-fast and secure messaging.",
  ),
];
