/// Shared responsive breakpoints for web targets — used by `lib/website/`
/// to collapse/reflow its layout. `admin_shell.dart` keeps its own inline
/// `_narrowBreakpoint` const rather than being refactored onto this, to
/// keep this change scoped to the new website.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
