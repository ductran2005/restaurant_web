package market.restaurant_web.validator;

import java.util.regex.Pattern;

public class UserValidator {
    private static final int USERNAME_MIN = 3;
    private static final int USERNAME_MAX = 50;
    private static final int PASSWORD_MIN = 6;
    private static final int FULLNAME_MIN = 2;
    private static final int FULLNAME_MAX = 100;
    private static final int PHONE_MIN = 10;
    private static final int PHONE_MAX = 20;

    private static final Pattern USERNAME_PATTERN = Pattern
            .compile("^[a-zA-Z0-9_]{" + USERNAME_MIN + "," + USERNAME_MAX + "}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9+\\-]{" + PHONE_MIN + "," + PHONE_MAX + "}$");
    private static final Pattern PASSWORD_PATTERN = Pattern
            .compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{" + PASSWORD_MIN + ",}$");

    public static ValidationError validateUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return new ValidationError("username", "Username không được để trống");
        }
        if (!USERNAME_PATTERN.matcher(username).matches()) {
            return new ValidationError("username",
                    "Username phải từ " + USERNAME_MIN + "-" + USERNAME_MAX + " ký tự, chỉ chứa chữ, số, underscore");
        }
        return null;
    }

    public static ValidationError validatePassword(String password, String username) {
        if (password == null || password.isEmpty()) {
            return new ValidationError("password", "Password không được để trống");
        }
        if (password.length() < PASSWORD_MIN) {
            return new ValidationError("password", "Password phải tối thiểu " + PASSWORD_MIN + " ký tự");
        }
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            return new ValidationError("password",
                    "Password phải chứa chữ hoa, chữ thường, số");
        }
        if (username != null && password.toLowerCase().contains(username.toLowerCase())) {
            return new ValidationError("password", "Password không được chứa username");
        }
        return null;
    }

    public static ValidationError validateEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return new ValidationError("email", "Email không được để trống");
        }
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            return new ValidationError("email", "Email không hợp lệ");
        }
        return null;
    }

    public static ValidationError validateFullName(String fullName) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return new ValidationError("fullName", "Họ tên không được để trống");
        }
        if (fullName.length() < FULLNAME_MIN || fullName.length() > FULLNAME_MAX) {
            return new ValidationError("fullName",
                    "Họ tên phải từ " + FULLNAME_MIN + "-" + FULLNAME_MAX + " ký tự");
        }
        return null;
    }

    public static ValidationError validatePhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return null; // Optional
        }
        if (!PHONE_PATTERN.matcher(phone).matches()) {
            return new ValidationError("phone",
                    "Số điện thoại không hợp lệ (10-20 ký tự)");
        }
        return null;
    }

    public static ValidationError validateStatus(String status) {
        if (status == null || (!status.equals("ACTIVE") && !status.equals("INACTIVE"))) {
            return new ValidationError("status", "Status phải là ACTIVE hoặc INACTIVE");
        }
        return null;
    }

    public static class ValidationError {
        public String field;
        public String message;

        public ValidationError(String field, String message) {
            this.field = field;
            this.message = message;
        }

        @Override
        public String toString() {
            return field + ": " + message;
        }
    }
}
