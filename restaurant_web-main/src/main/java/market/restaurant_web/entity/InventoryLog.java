package market.restaurant_web.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Maps to DB table: inventory_logs
 * (log_id, inventory_id, changed_by, type, qty_change, reason, created_at)
 * type: IN, OUT, ADJUST
 */
@Entity
@Table(name = "inventory_logs")
public class InventoryLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "inventory_id", nullable = false)
    private Inventory inventory;

    @ManyToOne
    @JoinColumn(name = "changed_by", nullable = false)
    private User changedBy;

    @Column(name = "type", nullable = false, length = 20)
    private String type;

    @Column(name = "qty_change", nullable = false)
    private Integer qtyChange;

    @Column(name = "reason", length = 255)
    private String reason;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null)
            createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Inventory getInventory() {
        return inventory;
    }

    public void setInventory(Inventory inventory) {
        this.inventory = inventory;
    }

    public User getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(User changedBy) {
        this.changedBy = changedBy;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Integer getQtyChange() {
        return qtyChange;
    }

    public void setQtyChange(Integer qtyChange) {
        this.qtyChange = qtyChange;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
