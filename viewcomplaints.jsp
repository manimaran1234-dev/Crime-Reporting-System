// ===== DAO CLASSES =====

// DatabaseConnection.java
package com.crime.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/crime_reporting_system";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "maran@2820"; 
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(DRIVER);
            return DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
    }

    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}

// UserDAO.java
package com.crime.dao;

import com.crime.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    
    public User authenticateUser(String username, String password) throws SQLException {
        String sql = "SELECT u.*, r.role_name FROM users u " +
                    "JOIN roles r ON u.role_id = r.role_id " +
                    "WHERE u.username = ? AND u.password_hash = ? AND u.is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            stmt.setString(2, password);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    public boolean createUser(User user) throws SQLException {
        String sql = "INSERT INTO users (username, email, password_hash, full_name, phone, address, role_id) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getFullName());
            stmt.setString(5, user.getPhone());
            stmt.setString(6, user.getAddress());
            stmt.setInt(7, user.getRoleId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT u.*, r.role_name FROM users u " +
                    "JOIN roles r ON u.role_id = r.role_id WHERE u.user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    public List<User> getUsersByRole(String roleName) throws SQLException {
        String sql = "SELECT u.*, r.role_name FROM users u " +
                    "JOIN roles r ON u.role_id = r.role_id WHERE r.role_name = ? AND u.is_active = TRUE";
        
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, roleName);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        }
        return users;
    }
    
    public List<User> getAllUsers() throws SQLException {
        String sql = "SELECT u.*, r.role_name FROM users u " +
                    "JOIN roles r ON u.role_id = r.role_id ORDER BY u.created_at DESC";
        
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        }
        return users;
    }
    
    public boolean updateUserStatus(int userId, boolean isActive) throws SQLException {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setBoolean(1, isActive);
            stmt.setInt(2, userId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean isUsernameExists(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    public boolean isEmailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        user.setRoleId(rs.getInt("role_id"));
        user.setRoleName(rs.getString("role_name"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setActive(rs.getBoolean("is_active"));
        return user;
    }
}

// ComplaintDAO.java
package com.crime.dao;

import com.crime.model.Complaint;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ComplaintDAO {
    
    public int createComplaint(Complaint complaint) throws SQLException {
        String sql = "INSERT INTO complaints (citizen_id, category_id, title, description, location, " +
                    "incident_date, priority, file_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, complaint.getCitizenId());
            stmt.setInt(2, complaint.getCategoryId());
            stmt.setString(3, complaint.getTitle());
            stmt.setString(4, complaint.getDescription());
            stmt.setString(5, complaint.getLocation());
            stmt.setDate(6, complaint.getIncidentDate());
            stmt.setString(7, complaint.getPriority());
            stmt.setString(8, complaint.getFilePath());
            
            int result = stmt.executeUpdate();
            if (result > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }
    
    public List<Complaint> getComplaintsByCitizen(int citizenId) throws SQLException {
        String sql = "SELECT * FROM complaint_details WHERE citizen_id = ? ORDER BY created_at DESC";
        
        return getComplaintsFromQuery(sql, citizenId);
    }
    
    public List<Complaint> getComplaintsByOfficer(int officerId) throws SQLException {
        String sql = "SELECT * FROM complaint_details WHERE assigned_officer_id = ? ORDER BY created_at DESC";
        
        return getComplaintsFromQuery(sql, officerId);
    }
    
    public List<Complaint> getAllComplaints() throws SQLException {
        String sql = "SELECT * FROM complaint_details ORDER BY created_at DESC";
        
        List<Complaint> complaints = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                complaints.add(mapResultSetToComplaint(rs));
            }
        }
        return complaints;
    }
    
    public List<Complaint> getComplaintsByStatus(String status) throws SQLException {
        String sql = "SELECT * FROM complaint_details WHERE status = ? ORDER BY created_at DESC";
        
        return getComplaintsFromQuery(sql, status);
    }
    
    public Complaint getComplaintById(int complaintId) throws SQLException {
        String sql = "SELECT * FROM complaint_details WHERE complaint_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, complaintId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToComplaint(rs);
                }
            }
        }
        return null;
    }
    
    public boolean updateComplaintStatus(int complaintId, String status, Integer assignedOfficerId) throws SQLException {
        String sql = "UPDATE complaints SET status = ?, assigned_officer_id = ?, updated_at = CURRENT_TIMESTAMP WHERE complaint_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            if (assignedOfficerId != null) {
                stmt.setInt(2, assignedOfficerId);
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            stmt.setInt(3, complaintId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean assignComplaintToOfficer(int complaintId, int officerId) throws SQLException {
        String sql = "UPDATE complaints SET assigned_officer_id = ?, status = 'ASSIGNED', updated_at = CURRENT_TIMESTAMP WHERE complaint_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, officerId);
            stmt.setInt(2, complaintId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public Map<String, Integer> getComplaintStatistics() throws SQLException {
        String sql = "SELECT * FROM complaint_statistics";
        
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                stats.put("total", rs.getInt("total_complaints"));
                stats.put("pending", rs.getInt("pending_complaints"));
                stats.put("assigned", rs.getInt("assigned_complaints"));
                stats.put("investigating", rs.getInt("investigating_complaints"));
                stats.put("resolved", rs.getInt("resolved_complaints"));
                stats.put("closed", rs.getInt("closed_complaints"));
            }
        }
        return stats;
    }
    
    public Map<String, Integer> getCategoryStatistics() throws SQLException {
        String sql = "SELECT cat.category_name, COUNT(c.complaint_id) as count " +
                    "FROM categories cat " +
                    "LEFT JOIN complaints c ON cat.category_id = c.category_id " +
                    "GROUP BY cat.category_id, cat.category_name " +
                    "ORDER BY count DESC";
        
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                stats.put(rs.getString("category_name"), rs.getInt("count"));
            }
        }
        return stats;
    }
    
    private List<Complaint> getComplaintsFromQuery(String sql, Object parameter) throws SQLException {
        List<Complaint> complaints = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (parameter instanceof Integer) {
                stmt.setInt(1, (Integer) parameter);
            } else if (parameter instanceof String) {
                stmt.setString(1, (String) parameter);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    complaints.add(mapResultSetToComplaint(rs));
                }
            }
        }
        return complaints;
    }
    
    private Complaint mapResultSetToComplaint(ResultSet rs) throws SQLException {
        Complaint complaint = new Complaint();
        complaint.setComplaintId(rs.getInt("complaint_id"));
        complaint.setCitizenId(rs.getInt("citizen_id"));
        complaint.setAssignedOfficerId((Integer) rs.getObject("assigned_officer_id"));
        complaint.setCategoryId(rs.getInt("category_id"));
        complaint.setTitle(rs.getString("title"));
        complaint.setDescription(rs.getString("description"));
        complaint.setLocation(rs.getString("location"));
        complaint.setIncidentDate(rs.getDate("incident_date"));
        complaint.setStatus(rs.getString("status"));
        complaint.setPriority(rs.getString("priority"));
        complaint.setFilePath(rs.getString("file_path"));
        complaint.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Additional display fields
        complaint.setCitizenName(rs.getString("citizen_name"));
        complaint.setCitizenEmail(rs.getString("citizen_email"));
        complaint.setCitizenPhone(rs.getString("citizen_phone"));
        complaint.setOfficerName(rs.getString("officer_name"));
        complaint.setCategoryName(rs.getString("category_name"));
        
        return complaint;
    }
}

// CategoryDAO.java
package com.crime.dao;

import com.crime.model.Category;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {
    
    public List<Category> getAllCategories() throws SQLException {
        String sql = "SELECT * FROM categories ORDER BY category_name";
        
        List<Category> categories = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("category_id"));
                category.setCategoryName(rs.getString("category_name"));
                category.setDescription(rs.getString("description"));
                categories.add(category);
            }
        }
        return categories;
    }
    
    public Category getCategoryById(int categoryId) throws SQLException {
        String sql = "SELECT * FROM categories WHERE category_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, categoryId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Category category = new Category();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setCategoryName(rs.getString("category_name"));
                    category.setDescription(rs.getString("description"));
                    return category;
                }
            }
        }
        return null;
    }
}

// ComplaintUpdateDAO.java
package com.crime.dao;

import com.crime.model.ComplaintUpdate;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ComplaintUpdateDAO {
    
    public boolean addComplaintUpdate(ComplaintUpdate update) throws SQLException {
        String sql = "INSERT INTO complaint_updates (complaint_id, updated_by, status, notes) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, update.getComplaintId());
            stmt.setInt(2, update.getUpdatedBy());
            stmt.setString(3, update.getStatus());
            stmt.setString(4, update.getNotes());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public List<ComplaintUpdate> getUpdatesByComplaint(int complaintId) throws SQLException {
        String sql = "SELECT cu.*, u.full_name as updated_by_name " +
                    "FROM complaint_updates cu " +
                    "JOIN users u ON cu.updated_by = u.user_id " +
                    "WHERE cu.complaint_id = ? ORDER BY cu.created_at DESC";
        
        List<ComplaintUpdate> updates = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, complaintId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ComplaintUpdate update = new ComplaintUpdate();
                    update.setUpdateId(rs.getInt("update_id"));
                    update.setComplaintId(rs.getInt("complaint_id"));
                    update.setUpdatedBy(rs.getInt("updated_by"));
                    update.setStatus(rs.getString("status"));
                    update.setNotes(rs.getString("notes"));
                    update.setCreatedAt(rs.getTimestamp("created_at"));
                    update.setUpdatedByName(rs.getString("updated_by_name"));
                    updates.add(update);
                }
            }
        }
        return updates;
    }
}

// ===== UTILITY CLASSES =====

// PasswordUtil.java
package com.crime.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

public class PasswordUtil {
    
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedPassword = md.digest(password.getBytes());
            
            // Convert byte array to hexadecimal string
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedPassword) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
    
    public static boolean verifyPassword(String password, String hashedPassword) {
        String hashOfInput = hashPassword(password);
        return hashOfInput.equals(hashedPassword);
    }
    
    public static String generateRandomPassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder password = new StringBuilder();
        
        for (int i = 0; i < length; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return password.toString();
    }
}

// ValidationUtil.java
package com.crime.util;

import java.util.regex.Pattern;

public class ValidationUtil {
    
    private static final String EMAIL_REGEX = "^[A-Za-z0-9+_.-]+@(.+)$";
    private static final String PHONE_REGEX = "^[0-9]{10}$";
    private static final String USERNAME_REGEX = "^[a-zA-Z0-9_]{3,20}$";
    
    private static final Pattern EMAIL_PATTERN = Pattern.compile(EMAIL_REGEX);
    private static final Pattern PHONE_PATTERN = Pattern.compile(PHONE_REGEX);
    private static final Pattern USERNAME_PATTERN = Pattern.compile(USERNAME_REGEX);
    
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }
    
    public static boolean isValidPhone(String phone) {
        return phone != null && PHONE_PATTERN.matcher(phone).matches();
    }
    
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }
    
    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= 6 && password.length() <= 50;
    }
    
    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }
    
    public static boolean isValidName(String name) {
        return name != null && name.trim().length() >= 2 && name.trim().length() <= 100;
    }
    
    public static String sanitizeInput(String input) {
        if (input == null) return null;
        
        return input.trim()
                   .replaceAll("<", "&lt;")
                   .replaceAll(">", "&gt;")
                   .replaceAll("\"", "&quot;")
                   .replaceAll("'", "&#x27;")
                   .replaceAll("/", "&#x2F;");
    }
}

// EmailUtil.java
package com.crime.util;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtil {
    
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SENDER_EMAIL = "crimeportal@example.com";
    private static final String SENDER_PASSWORD = "your_email_password";
    
    public static boolean sendEmail(String recipientEmail, String subject, String body) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject(subject);
            message.setText(body);
            
            Transport.send(message);
            return true;
            
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public static void sendComplaintStatusUpdate(String citizenEmail, String citizenName, 
                                               String complaintTitle, String newStatus, String notes) {
        String subject = "Crime Complaint Status Update - " + complaintTitle;
        String body = String.format(
            "Dear %s,\n\n" +
            "Your complaint '%s' has been updated.\n" +
            "New Status: %s\n" +
            "Notes: %s\n\n" +
            "Thank you for using our Crime Reporting Portal.\n\n" +
            "Best regards,\n" +
            "Crime Reporting Team",
            citizenName, complaintTitle, newStatus, notes != null ? notes : "No additional notes"
        );
        
        // For demo purposes, we'll just print to console instead of actually sending email
        System.out.println("=== EMAIL NOTIFICATION ===");
        System.out.println("To: " + citizenEmail);
        System.out.println("Subject: " + subject);
        System.out.println("Body: " + body);
        System.out.println("========================");
        
        // Uncomment below line to actually send email (requires proper SMTP configuration)
        // sendEmail(citizenEmail, subject, body);
    }
    
    public static void sendComplaintAssignment(String officerEmail, String officerName, 
                                             String complaintTitle, int complaintId) {
        String subject = "New Complaint Assigned - " + complaintTitle;
        String body = String.format(
            "Dear Officer %s,\n\n" +
            "A new complaint has been assigned to you:\n" +
            "Complaint ID: %d\n" +
            "Title: %s\n\n" +
            "Please log in to the system to view full details and begin investigation.\n\n" +
            "Best regards,\n" +
            "Crime Reporting Team",
            officerName, complaintId, complaintTitle
        );
        
        // For demo purposes, we'll just print to console
        System.out.println("=== EMAIL NOTIFICATION ===");
        System.out.println("To: " + officerEmail);
        System.out.println("Subject: " + subject);
        System.out.println("Body: " + body);
        System.out.println("========================");
        
        // Uncomment below line to actually send email
        // sendEmail(officerEmail, subject, body);
    }
}
