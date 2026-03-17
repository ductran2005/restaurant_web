package market.restaurant_web.entity;

import jakarta.persistence.*;
import java.util.List;

/**
 * Maps to DB table: categories (category_id, category_name, status)
 * Status values: ACTIVE, INACTIVE
 */
@Entity
@Table(name = "categories")
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private Integer id;

    @Column(name = "category_name", nullable = false, unique = true, length = 100)
    private String categoryName;

    @Column(name = "status", nullable = false, length = 20)
    private String status = "ACTIVE";

    @OneToMany(mappedBy = "category")
    private List<Product> products;

    // Getters & Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    /** Alias for backward compat */
    public String getName() {
        return categoryName;
    }

    public void setName(String name) {
        this.categoryName = name;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    /** Helper: check if active */
    public boolean isActive() {
        return "ACTIVE".equals(status);
    }

    public List<Product> getProducts() {
        return products;
    }

    public void setProducts(List<Product> products) {
        this.products = products;
    }
}
