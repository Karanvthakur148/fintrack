class WaitForSplash {
  const WaitForSplash();

  Future<void> call() async {
    await Future<void>.delayed(const Duration(milliseconds: 2800));
  }
}
