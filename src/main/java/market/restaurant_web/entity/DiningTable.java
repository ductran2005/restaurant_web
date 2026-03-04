package market.restaurant_web.entity;

import jakarta.persistence.*;
import java.util.List;

/**
 * Maps to DB table: tables (table_id, area_id, table_name, capacity, status)
 * Status values: AVAILABLE, IN_USE
 */
@Entity
@Table(name = "tables")
public class DiningTable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "table_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "area_id", nullable = false)
    private Area area;

    @Column(name = "table_name", nullable = false, unique = true, length = 50)
    private String tableName;

    @Column(name = "capacity", nullable = false)
    private Integer capacity;

    @Column(name = "status", nullable = false, length = 20)
    private String status = "AVAILABLE";

    @OneToMany(mappedBy = "table")
    private List<Order> orders;

    // Getters & Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Area getArea() {
        return area;
    }

    public void setArea(Area area) {
        this.area = area;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    /** Alias for backward compat - controllers used getCode()/setCode() */
    public String getCode() {
        return tableName;
    }

    public void setCode(String code) {
        this.tableName = code;
    }

    public Integer getCapacity() {
        return capacity;
    }

    public void setCapacity(Integer capacity) {
        this.capacity = capacity;
    }

    /** Alias for backward compat - controllers used getSeats()/setSeats() */
    public Integer getSeats() {
        return capacity;
    }

    public void setSeats(Integer seats) {
        this.capacity = seats;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<Order> getOrders() {
        return orders;
    }
}
