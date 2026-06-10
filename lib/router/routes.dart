/// Named routes for the whole app. Using an enum keeps navigation calls
/// type-safe (`context.goNamed(AppRoute.home.name)`).
enum AppRoute {
  onboarding('/onboarding'),
  login('/login'),
  signup('/signup'),
  home('/home'),
  search('/search'),
  dishDetail('/dish/:dishId'),
  restaurant('/restaurant/:restaurantId'),
  map('/map'),
  saved('/saved'),
  profile('/profile'),
  dashboard('/dashboard');

  const AppRoute(this.path);
  final String path;
}
