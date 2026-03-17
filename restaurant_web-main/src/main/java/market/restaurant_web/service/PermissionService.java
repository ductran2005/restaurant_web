package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.PermissionDao;
import market.restaurant_web.dao.RoleDAO;
import market.restaurant_web.entity.Permission;
import market.restaurant_web.entity.Role;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;
import java.util.Set;

public class PermissionService {
    private final PermissionDao permissionDao = new PermissionDao();
    private final RoleDAO roleDao = new RoleDAO();

    public Set<String> getPermissionsByRoleId(int roleId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return permissionDao.findPermissionCodesByRoleId(s, roleId);
        }
    }

    public List<Permission> findAll() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return permissionDao.findAll(s);
        }
    }

    public void togglePermission(int roleId, String permissionCode, boolean grant) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (grant) {
                // Check if already exists
                Set<String> existing = permissionDao.findPermissionCodesByRoleId(s, roleId);
                if (!existing.contains(permissionCode)) {
                    Permission p = new Permission();
                    Role role = roleDao.findById(s, roleId);
                    p.setRole(role);
                    p.setPermission(permissionCode);
                    permissionDao.save(s, p);
                }
            } else {
                permissionDao.deleteByRoleAndPermission(s, roleId, permissionCode);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }
}
