package market.restaurant_web.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * Maps to DB table: bookings
 * Status: PENDING, CONFIRMED, CHECKED_IN, CANCELLED, NO_SHOW, COMPLETED
 */
@Entity
@Table(name = "bookings")
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "booking_id")
    private Integer id;

    @Column(name = "booking_code", nullable = false, unique = true, length = 20)
    private String bookingCode;

    @Column(name = "customer_name", nullable = false, length = 100)
    private String customerName;

    @Column(name = "customer_phone", nullable = false, length = 20)
    private String customerPhone;

    @Column(name = "booking_date", nullable = false)
    private LocalDate bookingDate;

    @Column(name = "booking_time", nullable = false)
    private LocalTime bookingTime;

    @Column(name = "party_size", nullable = false)
    private Integer partySize = 2;

    @Column(name = "note", length = 500)
    private String note;

    @Column(name = "status", nullable = false, length = 20)
    private String status = "PENDING";

    @Column(name = "cancel_reason", length = 500)
    private String cancelReason;

    /** Deposit amount (10% of pre-order total) */
    @Column(name = "deposit_amount", precision = 18, scale = 2)
    private java.math.BigDecimal depositAmount = java.math.BigDecimal.ZERO;

    /** Deposit payment status: PENDING, PAID, REFUNDED */
    @Column(name = "deposit_status", length = 20)
    private String depositStatus = "PENDING";

    /** Deposit payment reference/transaction ID */
    @Column(name = "deposit_ref", length = 100)
    private String depositRef;

    /** Timestamp when pre-order is locked (60 mins before booking time) */
    @Column(name = "preorder_locked_at")
    private LocalDateTime preorderLockedAt;

    @ManyToOne
    @JoinColumn(name = "table_id")
    private DiningTable table;

    /** Staff user who manages this booking */
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "booking", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PreOrderItem> preOrderItems;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null)
            createdAt = LocalDateTime.now();
        if (status == null)
            status = "PENDING";
        if (partySize == null)
            partySize = 2;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // === Getters & Setters ===
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public LocalDate getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(LocalDate bookingDate) {
        this.bookingDate = bookingDate;
    }

    public LocalTime getBookingTime() {
        return bookingTime;
    }

    public void setBookingTime(LocalTime bookingTime) {
        this.bookingTime = bookingTime;
    }

    public Integer getPartySize() {
        return partySize;
    }

    public void setPartySize(Integer partySize) {
        this.partySize = partySize;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public DiningTable getTable() {
        return table;
    }

    public void setTable(DiningTable table) {
        this.table = table;
    }

    /** Helper: get table name or null */
    public String getTableName() {
        return table != null ? table.getTableName() : null;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<PreOrderItem> getPreOrderItems() {
        return preOrderItems;
    }

    public void setPreOrderItems(List<PreOrderItem> preOrderItems) {
        this.preOrderItems = preOrderItems;
    }

    public java.math.BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(java.math.BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public String getDepositStatus() {
        return depositStatus;
    }

    public void setDepositStatus(String depositStatus) {
        this.depositStatus = depositStatus;
    }

    public String getDepositRef() {
        return depositRef;
    }

    public void setDepositRef(String depositRef) {
        this.depositRef = depositRef;
    }

    public LocalDateTime getPreorderLockedAt() {
        return preorderLockedAt;
    }

    public void setPreorderLockedAt(LocalDateTime preorderLockedAt) {
        this.preorderLockedAt = preorderLockedAt;
    }

    /** Helper: Check if pre-order is locked (within 60 mins of booking time) */
    public boolean isPreorderLocked() {
        if (preorderLockedAt != null) {
            return true;
        }
        LocalDateTime cutoffTime = LocalDateTime.of(bookingDate, bookingTime).minusMinutes(60);
        return LocalDateTime.now().isAfter(cutoffTime);
    }

    /** Helper: Calculate total pre-order amount */
    public java.math.BigDecimal calculatePreorderTotal() {
        if (preOrderItems == null || preOrderItems.isEmpty()) {
            return java.math.BigDecimal.ZERO;
        }
        return preOrderItems.stream()
            .map(item -> item.getProduct().getPrice().multiply(new java.math.BigDecimal(item.getQuantity())))
            .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);
    }
}
