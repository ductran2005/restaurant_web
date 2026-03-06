package market.restaurant_web.util;

public final class ValidationUtil {
    private ValidationUtil() {
    }

    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static String sanitize(String input) {
        if (input == null)
            return null;
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    public static String trim(String s) {
        return s == null ? null : s.trim();
    }

    public static boolean isValidEmail(String email) {
        if (isBlank(email))
            return false;
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    }

    public static boolean isValidPhone(String phone) {
        if (isBlank(phone))
            return false;
        return phone.matches("^[0-9]{10,11}$");
    }

    public static int parseInt(String s, int defaultVal) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return defaultVal;
        }
    }

    /**
     * Validates an international phone number according to E.164 rules.
     *
     * Requirements:
     * <ul>
     *   <li>Must start with '+' followed by country code and subscriber number.</li>
     *   <li>Country code cannot start with 0.</li>
     *   <li>Total digits after '+' must be between 8 and 15 inclusive.</li>
     *   <li>Only numeric digits allowed after '+'.</li>
     * </ul>
     *
     * @param phone the phone number string to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidInternationalPhone(String phone) {
        if (isBlank(phone)) {
            return false;
        }
        // regex breakdown:
        // ^\+         : leading plus
        // [1-9]        : first digit (country code) cannot be 0
        // [0-9]{7,14}  : remaining digits, total length 8-15 digits after '+'.
        String pattern = "^\\+[1-9][0-9]{7,14}$";
        return phone.matches(pattern);
    }

    public static void main(String[] args) {
        String[] valid = {"+84901234567", "+12025550123", "+447911123456", "+819012345678"};
        String[] invalid = {"0901234567", "+084901234567", "+84-901-234-567", "+84abc123456"};
        System.out.println("Valid samples:");
        for (String p : valid) {
            System.out.printf("  %s -> %b\n", p, isValidInternationalPhone(p));
        }
        System.out.println("Invalid samples:");
        for (String p : invalid) {
            System.out.printf("  %s -> %b\n", p, isValidInternationalPhone(p));
        }
    }
}
