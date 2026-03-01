package market.restaurant_web.utils;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Chạy 1 lần duy nhất để tạo BCrypt hash cho password.
 * Copy hash vào SQL UPDATE.
 *
 * Cách dùng: Chuột phải → Run File trong NetBeans
 */
public class PasswordGenerator {
    public static void main(String[] args) {
        String password = "123456";
        String hash = BCrypt.hashpw(password, BCrypt.gensalt(10));

        System.out.println("=== Password Generator ===");
        System.out.println("Password : " + password);
        System.out.println("BCrypt   : " + hash);
        System.out.println();
        System.out.println("SQL để cập nhật tất cả user:");
        System.out.println("UPDATE users SET password_hash = '" + hash + "';");
        System.out.println();
        System.out.println("SQL cập nhật riêng admin:");
        System.out.println("UPDATE users SET password_hash = '" + hash + "' WHERE username = 'admin';");
    }
}
