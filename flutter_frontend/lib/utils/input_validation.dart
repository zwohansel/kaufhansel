bool isValidEMailAddress(String address) {
  if (address == null) {
    return false;
  }

  address = address.trim();

  if (address.length < 5) {
    return false;
  }

  if (!address.contains('@')) {
    return false;
  }

  if (!address.contains('.')) {
    return false;
  }

  if (address.contains(' ')) {
    return false;
  }

  return true;
}
