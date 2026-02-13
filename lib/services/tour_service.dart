enum TourStep {
  home,
  lotesListAdd,
  lotesListOpen,
  loteDetailActions,
  baiasListAdd,
  baiasListOpen,
  baiaDetailActions,
  done,
}

class TourService {
  static bool _active = false;
  static TourStep _step = TourStep.home;

  static bool get isActive => _active;
  static TourStep get step => _step;

  static bool isStep(TourStep step) {
    return _active && _step == step;
  }

  static void start() {
    _active = true;
    _step = TourStep.home;
  }

  static void next(TourStep step) {
    _active = true;
    _step = step;
  }

  static void stop() {
    _active = false;
    _step = TourStep.done;
  }
}
