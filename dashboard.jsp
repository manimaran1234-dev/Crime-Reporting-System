<!-- login.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Crime Reporting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="auth-page">
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h1>Crime Reporting Portal</h1>
                <p>Please login to continue</p>
            </div>
            
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    ${error}
                </div>
            </c:if>
            
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    ${success}
                </div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/login" method="post" class="auth-form">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required 
                           value="${param.username}" placeholder="Enter your username">
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required 
                           placeholder="Enter your password">
                </div>
                
                <button type="submit" class="btn btn-primary btn-full">Login</button>
            </form>
            
            <div class="auth-footer">
                <p>Don't have an account? <a href="${pageContext.request.contextPath}/register">Register here</a></p>
            </div>
        </div>
    </div>
</body>
</html>

<!-- register.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Crime Reporting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="auth-page">
    <div class="auth-container">
        <div class="auth-card large">
            <div class="auth-header">
                <h1>Create Account</h1>
                <p>Join our Crime Reporting Portal</p>
            </div>
            
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    ${error}
                </div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/register" method="post" class="auth-form">
                <div class="form-row">
                    <div class="form-group">
                        <label for="username">Username *</label>
                        <input type="text" id="username" name="username" required 
                               value="${param.username}" placeholder="3-20 characters">
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email *</label>
                        <input type="email" id="email" name="email" required 
                               value="${param.email}" placeholder="your@email.com">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Password *</label>
                        <input type="password" id="password" name="password" required 
                               placeholder="Minimum 6 characters">
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirm Password *</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required 
                               placeholder="Re-enter password">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="fullName">Full Name *</label>
                    <input type="text" id="fullName" name="fullName" required 
                           value="${param.fullName}" placeholder="Your full name">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="phone">Phone Number *</label>
                        <input type="tel" id="phone" name="phone" required 
                               value="${param.phone}" placeholder="10 digits">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="address">Address *</label>
                    <textarea id="address" name="address" required rows="3" 
                              placeholder="Your complete address">${param.address}</textarea>
                </div>
                
                <button type="submit" class="btn btn-primary btn-full">Register</button>
            </form>
            
            <div class="auth-footer">
                <p>Already have an account? <a href="${pageContext.request.contextPath}/login">Login here</a></p>
            </div>
        </div>
    </div>
    
    <script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>

<!-- citizen-dashboard.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Citizen Dashboard - Crime Reporting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="header.jsp" />
    
    <div class="dashboard-container">
        <div class="dashboard-header">
            <h1>Welcome, ${user.fullName}</h1>
            <p>Citizen Dashboard</p>
        </div>
        
        <c:if test="${not empty param.success}">
            <div class="alert alert-success">
                ${param.success}
            </div>
        </c:if>
        
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">
                ${param.error}
            </div>
        </c:if>
        
        <div class="dashboard-actions">
            <a href="${pageContext.request.contextPath}/complaint?action=file" class="btn btn-primary">
                <i class="icon-plus"></i> File New Complaint
            </a>
        </div>
        
        <div class="dashboard-content">
            <div class="card">
                <div class="card-header">
                    <h3>My Complaints</h3>
                    <span class="badge">${complaints.size()} Total</span>
                </div>
                
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty complaints}">
                            <div class="empty-state">
                                <p>You haven't filed any complaints yet.</p>
                                <a href="${pageContext.request.contextPath}/complaint?action=file" class="btn btn-primary">File Your First Complaint</a>
                            </div
