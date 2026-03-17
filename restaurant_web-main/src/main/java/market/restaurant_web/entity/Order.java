package market.restaurant_web.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Maps to DB table: orders
 * (order_id, table_id, created_by, order_type, opened_at, closed_at,
 * status, subtotal, discount_amount, total_amount, note)
 * Status values: OPEN, SERVED, CANCELLED, PAID
 * Order type: DINE_IN, TAKE_AWAY, DELIVERY
 */
@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "table_id", nullable = false)
    private DiningTable table;

    @ManyToOne
    @JoinColumn(name = "created_by", nullable = false)
    private User createdByUser;

    @Column(name = "order_type", nullable = false, length = 20)
    private String orderType = "DINE_IN";

    @Column(name = "opened_at", updatable = false)
    private LocalDateTime openedAt;

    @Column(name = "closed_at")
    private LocalDateTime closedAt;

    @Column(name = "status", nullable = false, length = 20)
    private String status = "OPEN";

    @Column(name = "subtotal", nullable = false, precision = 18, scale = 2)
    private BigDecimal subtotal = BigDecimal.ZERO;

    @Column(name = "discount_amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Column(name = "note", length = 500)
    private String note;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderDetail> orderDetails;

    @PrePersist
    protected void onCreate() {
        if (openedAt == null)
            openedAt = LocalDateTime.now();
        if (status == null)
            status = "OPEN";
        if (orderType == null)
            orderType = "DINE_IN";
        if (subtotal == null)
            subtotal = BigDecimal.ZERO;
        if (discountAmount == null)
            discountAmount = BigDecimal.ZERO;
        if (totalAmount == null)
            totalAmount = BigDecimal.ZERO;
    }

    // Getters & Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public DiningTable getTable() {
        return table;
    }

    public void setTable(DiningTable table) {
        this.table = table;
    }

    public User getCreatedByUser() {
        return createdByUser;
    }

    public void setCreatedByUser(User user) {
        this.createdByUser = user;
    }

    public String getOrderType() {
        return orderType;
    }

    public void setOrderType(String orderType) {
        this.orderType = orderType;
    }

    public LocalDateTime getOpenedAt() {
        return openedAt;
    }

    /** Alias for backward compat */
    public LocalDateTime getCreatedAt() {
        return openedAt;
    }

    public LocalDateTime getClosedAt() {
        return closedAt;
    }

    public void setClosedAt(LocalDateTime closedAt) {
        this.closedAt = closedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public List<OrderDetail> getOrderDetails() {
        return orderDetails;
    }

    public void setOrderDetails(List<OrderDetail> orderDetails) {
        this.orderDetails = orderDetails;
    }

    @ManyToOne
    @JoinColumn(name = "booking_id")
    private Booking booking;

    public Booking getBooking() {
        return booking;
    }

    public void setBooking(Booking booking) {
        this.booking = booking;
    }


}
