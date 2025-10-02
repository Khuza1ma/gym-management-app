class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Card number can only contain digits';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    String cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      return 'Phone number can only contain digits';
    }

    return null;
  }

  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Please select both dates';
    }

    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      return 'End date must be after start date';
    }

    return null;
  }
}
