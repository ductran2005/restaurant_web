package market.restaurant_web.entity;

public enum TableStatus {
    EMPTY,
    RESERVED,
    OCCUPIED,
    WAITING_PAYMENT,
    DIRTY,
    DISABLED,

    // Legacy aliases for backward compatibility
    AVAILABLE,
    IN_USE
}
