package market.restaurant_web.service;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    private static final int BCRYPT_ROUNDS = 12;

    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (hashedPassword == null || hashedPassword.isEmpty()) {
            return false;
        }

        // Kiểm tra nếu password đã được hash bằng BCrypt (bắt đầu bằng $2a$ hoặc $2b$)
        if (hashedPassword.startsWith("$2a$") || hashedPassword.startsWith("$2b$")
                || hashedPassword.startsWith("$2y$")) {
            try {
                return BCrypt.checkpw(plainPassword, hashedPassword);
            } catch (Exception e) {
                return false;
            }
        }

        // Fallback: so sánh plain text (cho dữ liệu cũ chưa hash)
        return plainPassword.equals(hashedPassword);
    }
}
