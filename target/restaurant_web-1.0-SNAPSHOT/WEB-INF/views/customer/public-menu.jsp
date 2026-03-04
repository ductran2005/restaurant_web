<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layout" %>

                <layout:customer pageTitle="Thực đơn" activeMenu="menu">
                    <div class="menu-head">
                        <h1 class="menu-title"><i class="fa-solid fa-utensils"></i> Thực đơn</h1>
                        <p class="menu-subtitle">Khám phá các món ngon tại nhà hàng Hương Việt</p>
                    </div>

                    <!-- Search -->
                    <div class="search-container">
                        <form method="get" action="${pageContext.request.contextPath}/menu">
                            <div class="search-box">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" name="search" value="${search}" placeholder="Tìm kiếm món ăn...">
                            </div>
                            <c:if test="${not empty selectedCategoryId}">
                                <input type="hidden" name="categoryId" value="${selectedCategoryId}">
                            </c:if>
                        </form>
                    </div>

                    <!-- Category Tabs -->
                    <div class="tabs-container" style="justify-content: center;">
                        <div class="tabs-wrap">
                            <a href="${pageContext.request.contextPath}/menu"
                                class="tab ${empty selectedCategoryId ? 'active' : ''}">Tất cả</a>
                            <c:forEach var="cat" items="${categories}">
                                <a href="${pageContext.request.contextPath}/menu?categoryId=${cat.categoryId}"
                                    class="tab ${selectedCategoryId == cat.categoryId ? 'active' : ''}">
                                    <c:out value="${cat.categoryName}" />
                                </a>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Menu Grid -->
                    <c:choose>
                        <c:when test="${empty products}">
                            <div class="empty-state">
                                <i class="fa-solid fa-utensils empty-state-icon"></i>
                                <h3 class="empty-state-title">Không có sản phẩm nào</h3>
                                <p>Vui lòng thử lại với từ khóa khác.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="menu-grid">
                                <c:forEach var="item" items="${products}">
                                    <div class="menu-card">
                                        <%-- imageUrl: không có cột này trong DB products --%>
                                            <div class="menu-card-img flex items-center justify-center">
                                                <i class="fa-solid fa-image text-muted" style="font-size: 3rem;"></i>
                                            </div>

                                            <!-- Card Body -->
                                            <div class="menu-card-body">
                                                <div class="menu-card-header">
                                                    <h4 class="menu-card-title">
                                                        <c:out value="${item.productName}" />
                                                    </h4>
                                                    <c:if test="${item.status == 'UNAVAILABLE'}">
                                                        <span class="badge-soldout"><i class="fa-solid fa-box-open"></i>
                                                            Hết</span>
                                                    </c:if>
                                                </div>

                                                <div class="menu-card-cat">
                                                    <c:out value="${item.category.categoryName}" />
                                                </div>

                                                <c:if test="${not empty item.description}">
                                                    <div class="menu-card-desc">
                                                        <c:out value="${item.description}" />
                                                    </div>
                                                </c:if>

                                                <!-- Card Footer -->
                                                <div class="menu-card-footer">
                                                    <div class="menu-price">
                                                        <fmt:formatNumber value="${item.price}" pattern="#,###" /> đ
                                                    </div>

                                                    <c:choose>
                                                        <c:when test="${item.status == 'UNAVAILABLE'}">
                                                            <div class="text-soldout"><i class="fa-solid fa-ban"></i>
                                                                Tạm
                                                                hết</div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn-add" type="button">
                                                                <i class="fa-solid fa-plus"
                                                                    style="font-size: 11px;"></i>
                                                                Thêm
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>

                </layout:customer>