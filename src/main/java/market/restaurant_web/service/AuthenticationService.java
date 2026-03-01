package market.restaurant_web.service;

import market.restaurant_web.dao.UserDAO;
import market.restaurant_web.dao.RoleDAO;
import market.restaurant_web.entity.User;
import market.restaurant_web.entity.Role;
import java.time.LocalDateTime;

public class AuthenticationService {
    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCK_DURATION_MINUTES = 15;

    public User login(String username, String password) {
        User user = userDAO.findByUsername(username);

        if (user == null) {
            return null; // User not found
        }

        // Check if account is locked
        if (user.getLockedUntil() != null &&
                user.getLockedUntil().isAfter(LocalDateTime.now())) {
            return null; // Account locked
        }

        // Verify password
        if (!PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            recordFailedLogin(user);
            return null;
        }

        // Reset failed attempts on successful login
        user.setFailedLoginCount(0);
        user.setLockedUntil(null);
        userDAO.update(user);

        // Check account status
        if (!"ACTIVE".equals(user.getStatus())) {
            return null;
        }

        return user;
    }

    public boolean register(String username, String password, String email,
            String fullName, String roleName) {
        // Validate inputs
        if (username == null || username.trim().isEmpty() ||
                password == null || password.length() < 6 ||
                email == null || email.trim().isEmpty()) {
            return false;
        }

        // Check if username exists
        if (userDAO.findByUsername(username) != null) {
            return false;
        }

        // Check if email exists
        if (userDAO.findByEmail(email) != null) {
            return false;
        }

        // Find role
        Role role = roleDAO.findByRoleName(roleName);
        if (role == null) {
            return false;
        }

        // Create new user
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPasswordHash(PasswordUtil.hashPassword(password));
        newUser.setEmail(email);
        newUser.setFullName(fullName);
        newUser.setRole(role);
        newUser.setStatus("ACTIVE");
        newUser.setCreatedAt(LocalDateTime.now());
        newUser.setFailedLoginCount(0);

        try {
            userDAO.insert(newUser);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        User user = userDAO.getById(userId);
        if (user == null) {
            return false;
        }

        // Verify old password
        if (!PasswordUtil.verifyPassword(oldPassword, user.getPasswordHash())) {
            return false;
        }

        // Update password
        user.setPasswordHash(PasswordUtil.hashPassword(newPassword));
        userDAO.update(user);
        return true;
    }

    public boolean updateUserProfile(int userId, String fullName, String phone, String email) {
        User user = userDAO.getById(userId);
        if (user == null) {
            return false;
        }

        // Check email uniqueness if changed
        if (!user.getEmail().equals(email) && userDAO.findByEmail(email) != null) {
            return false;
        }

        user.setFullName(fullName);
        user.setPhone(phone);
        user.setEmail(email);
        userDAO.update(user);
        return true;
    }

    private void recordFailedLogin(User user) {
        user.setFailedLoginCount(user.getFailedLoginCount() + 1);
        user.setLastFailedLoginAt(LocalDateTime.now());

        if (user.getFailedLoginCount() >= MAX_FAILED_ATTEMPTS) {
            user.setLockedUntil(LocalDateTime.now().plusMinutes(LOCK_DURATION_MINUTES));
        }

        userDAO.update(user);
    }

    public User getUserByUserId(int userId) {
        return userDAO.getById(userId);
    }
}
