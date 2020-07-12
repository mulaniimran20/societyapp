class LoginUserDetails {
  String _userFullName;
  String _userContactNumber;
  String _userFlatNumber;
  String _userEmailId;
  String _userPhotoUrl;
  String _userEmergencyContactNumber;
  String _userSocietyName;
  String _userSocietyAddress;
  String _userSocietyLogoUrl;
  String _userSocietyWingName;
  int _userWingId;
  String _userChairmanName;
  String _userChairmanAddress;
  String _userChairmanContactNumber;
  String _userChairmanEmailId;
  String _userChairmanEmergencyContactNumber;
  int _userSocietyId;

  int get userSocietyId => _userSocietyId;

  set userSocietyId(int value) {
    _userSocietyId = value;
  }

  String get userFullName => _userFullName;

  LoginUserDetails(
      this._userFullName,
      this._userContactNumber,
      this._userFlatNumber,
      this._userEmailId,
      this._userPhotoUrl,
      this._userEmergencyContactNumber,
      this._userSocietyName,
      this._userSocietyAddress,
      this._userSocietyLogoUrl,
      this._userSocietyWingName,
      this._userWingId,
      this._userChairmanName,
      this._userChairmanAddress,
      this._userChairmanContactNumber,
      this._userChairmanEmailId,
      this._userChairmanEmergencyContactNumber,
      this._userSocietyId);

  set userFullName(String value) {
    _userFullName = value;
  }

  String get userContactNumber => _userContactNumber;

  String get userChairmanEmergencyContactNumber =>
      _userChairmanEmergencyContactNumber;

  set userChairmanEmergencyContactNumber(String value) {
    _userChairmanEmergencyContactNumber = value;
  }

  String get userChairmanEmailId => _userChairmanEmailId;

  set userChairmanEmailId(String value) {
    _userChairmanEmailId = value;
  }

  String get userChairmanContactNumber => _userChairmanContactNumber;

  set userChairmanContactNumber(String value) {
    _userChairmanContactNumber = value;
  }

  String get userChairmanAddress => _userChairmanAddress;

  set userChairmanAddress(String value) {
    _userChairmanAddress = value;
  }

  String get userChairmanName => _userChairmanName;

  set userChairmanName(String value) {
    _userChairmanName = value;
  }

  int get userWingId => _userWingId;

  set userWingId(int value) {
    _userWingId = value;
  }

  String get userSocietyWingName => _userSocietyWingName;

  set userSocietyWingName(String value) {
    _userSocietyWingName = value;
  }

  String get userSocietyLogoUrl => _userSocietyLogoUrl;

  set userSocietyLogoUrl(String value) {
    _userSocietyLogoUrl = value;
  }

  String get userSocietyAddress => _userSocietyAddress;

  set userSocietyAddress(String value) {
    _userSocietyAddress = value;
  }

  String get userSocietyName => _userSocietyName;

  set userSocietyName(String value) {
    _userSocietyName = value;
  }

  String get userEmergencyContactNumber => _userEmergencyContactNumber;

  set userEmergencyContactNumber(String value) {
    _userEmergencyContactNumber = value;
  }

  String get userPhotoUrl => _userPhotoUrl;

  set userPhotoUrl(String value) {
    _userPhotoUrl = value;
  }

  String get userEmailId => _userEmailId;

  set userEmailId(String value) {
    _userEmailId = value;
  }

  String get userFlatNumber => _userFlatNumber;

  set userFlatNumber(String value) {
    _userFlatNumber = value;
  }

  set userContactNumber(String value) {
    _userContactNumber = value;
  }
}
