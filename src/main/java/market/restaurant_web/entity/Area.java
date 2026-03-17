package market.restaurant_web.entity;

import jakarta.persistence.*;
import java.util.List;

/**
 * Maps to DB table: areas (area_id, area_name, description)
 */
@Entity
@Table(name = "areas")
public class Area {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "area_id")
    private Integer id;

    @Column(name = "area_name", nullable = false, unique = true, length = 100)
    private String areaName;

    @Column(name = "description", length = 255)
    private String description;

    @OneToMany(mappedBy = "area")
    private List<DiningTable> tables;

    // Getters & Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    /** Alias for backward compatibility */
    public String getName() {
        return areaName;
    }

    public void setName(String name) {
        this.areaName = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<DiningTable> getTables() {
        return tables;
    }

    public void setTables(List<DiningTable> tables) {
        this.tables = tables;
    }
}
