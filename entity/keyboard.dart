class Keyboard 
{

  Keyboard();

  bool _isShift = false;
  bool get isShift => _isShift;


  bool _isCtrl  = false;
  bool get isCtrl => _isCtrl;

  int _keycode = 0;
  int get keycode => _keycode;

  /// Set the shift state
  /// @param bool shift 
  /// @return void
  void setShift(bool shift)
  {
    _isShift = shift;
  }

  /// Set the ctrl state
  /// @param bool ctrl
  /// @return void
  void setCtrl(bool ctrl)
  {
    _isCtrl = ctrl;
  }

  /// Set the keycode
  /// @param key the keycode to set
  /// @return void
  void setKeycode(int key)
  {
    _keycode = key;
  }

  /// Clear the keycode
  /// @return void
  void clearKeycode()
  {
    _keycode = 0;
  }


}