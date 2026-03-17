package market.restaurant_web.entity;

import jakarta.persistence.*;
import java.util.List;

/**
 * Maps to DB table: roles (role_id, role_name, description)
 */
@Entity
@Table(name = "roles")
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "role_id")
    private Integer id;

    @Column(name = "role_name", unique = true, nullable = false, length = 50)
    private String roleName;

    @Column(name = "description", length = 255)
    private String description;

    @OneToMany(mappedBy = "role")
    private List<User> users;

    // Getters & Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    /** Alias for compatibility with controllers that call getName() */
    public String getName() {
        return roleName;
    }

    public void setName(String name) {
        this.roleName = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<User> getUsers() {
        return users;
    }
}
