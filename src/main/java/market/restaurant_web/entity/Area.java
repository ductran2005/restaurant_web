package market.restaurant_web.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "areas")
public class Area {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "area_id")
    private Integer areaId;

    @Column(name = "area_name", nullable = false, unique = true, length = 100)
    private String areaName;

    @Column(name = "description", length = 255)
    private String description;

    // === Constructors ===
    public Area() {
    }

    public Area(String areaName, String description) {
        this.areaName = areaName;
        this.description = description;
    }

    // === Getters & Setters ===
    public Integer getAreaId() {
        return areaId;
    }

    public void setAreaId(Integer areaId) {
        this.areaId = areaId;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
