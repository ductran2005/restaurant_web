package market.restaurant_web.util;

import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {
    private static final int BCRYPT_ROUNDS = 12;

    private PasswordUtil() {
    }

    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    public static boolean verify(String plainPassword, String hashedPassword) {
        if (hashedPassword == null || hashedPassword.isEmpty())
            return false;
        if (hashedPassword.startsWith("$2")) {
            try {
                return BCrypt.checkpw(plainPassword, hashedPassword);
            } catch (IllegalArgumentException e) {
                return false;
            }
        }
        // Legacy plain-text fallback
        return plainPassword.equals(hashedPassword);
    }
}
