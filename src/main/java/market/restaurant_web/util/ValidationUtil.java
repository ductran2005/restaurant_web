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
}
