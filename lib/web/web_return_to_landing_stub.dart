void paychekReturnToLandingIfAuthCancelled() {}

void paychekReturnToLandingAfterLogout() {}

void paychekReturnToLandingAfterLogin() {}

void paychekCloseAuthOverlay() {}

void paychekCompleteAuthOverlaySuccess() {}

void paychekStripAuthQueryFromUrl() {}

/// `/?app=1` (ou open=…) → entrer dans le journal Flutter.
bool paychekWebAppEntryRequested() => false;

String? paychekWebAppOpenTarget() => null;

void paychekStripWebAppEntryQueryFromUrl() {}
