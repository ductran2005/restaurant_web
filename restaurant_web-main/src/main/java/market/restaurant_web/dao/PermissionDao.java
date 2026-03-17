package market.restaurant_web.dao;

import market.restaurant_web.entity.Permission;
import org.hibernate.Session;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class PermissionDao {

    public List<Permission> findByRoleId(Session s, int roleId) {
        return s.createQuery("FROM Permission WHERE role.id = :rid", Permission.class)
                .setParameter("rid", roleId)
                .list();
    }

    public Set<String> findPermissionCodesByRoleId(Session s, int roleId) {
        return findByRoleId(s, roleId).stream()
                .map(Permission::getPermission)
                .collect(Collectors.toSet());
    }

    public List<Permission> findAll(Session s) {
        return s.createQuery("FROM Permission ORDER BY role.id, permission", Permission.class).list();
    }

    public void save(Session s, Permission p) {
        s.persist(p);
    }

    public void deleteByRoleAndPermission(Session s, int roleId, String permission) {
        s.createMutationQuery("DELETE FROM Permission WHERE role.id = :rid AND permission = :perm")
                .setParameter("rid", roleId)
                .setParameter("perm", permission)
                .executeUpdate();
    }
}
