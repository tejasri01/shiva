import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/StudentServlet")
public class StudentServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/clg?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "Anilp@2024";

    @Override
    public void init() throws ServletException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("MySQL JDBC Driver not found", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null || action.equals("list")) {
            listStudents(request, response);
        } else if (action.equals("edit")) {
            getStudent(request, response);
        } else if (action.equals("delete")) {
            deleteStudent(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action.equals("add")) {
            addStudent(request, response);
        } else if (action.equals("update")) {
            updateStudent(request, response);
        }
    }

    private void listStudents(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Student> students = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM students")) {
            
            while (rs.next()) {
                Student student = new Student();
                student.setId(rs.getInt("id"));
                student.setFirstName(rs.getString("first_name"));
                student.setLastName(rs.getString("last_name"));
                student.setEmail(rs.getString("email"));
                student.setAge(rs.getInt("age"));
                student.setDepartment(rs.getString("department"));
                student.setPhone(rs.getString("phone"));
                student.setAddress(rs.getString("address"));
                student.setEnrollmentDate(rs.getDate("enrollment_date"));
                student.setGpa(rs.getDouble("gpa"));
                students.add(student);
            }
            
            request.setAttribute("students", students);
            request.getRequestDispatcher("/students.jsp").forward(request, response);
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/students.jsp").forward(request, response);
        }
    }

    private void addStudent(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(
                 "INSERT INTO students (first_name, last_name, email, age, department, phone, address, enrollment_date, gpa) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
            
            stmt.setString(1, request.getParameter("firstName"));
            stmt.setString(2, request.getParameter("lastName"));
            stmt.setString(3, request.getParameter("email"));
            stmt.setInt(4, Integer.parseInt(request.getParameter("age")));
            stmt.setString(5, request.getParameter("department"));
            stmt.setString(6, request.getParameter("phone"));
            stmt.setString(7, request.getParameter("address"));
            String enrollmentDate = request.getParameter("enrollmentDate");
            stmt.setDate(8, enrollmentDate.isEmpty() ? null : Date.valueOf(enrollmentDate));
            String gpa = request.getParameter("gpa");
            stmt.setDouble(9, gpa.isEmpty() ? 0.0 : Double.parseDouble(gpa));
            stmt.executeUpdate();
            
            request.getSession().setAttribute("message", "Student added successfully!");
            response.sendRedirect("StudentServlet?action=list");
            
        } catch (SQLException | IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Error adding student: " + e.getMessage());
            listStudents(request, response);
        }
    }

    private void getStudent(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid student ID");
            listStudents(request, response);
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement("SELECT * FROM students WHERE id = ?")) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Student student = new Student();
                student.setId(rs.getInt("id"));
                student.setFirstName(rs.getString("first_name"));
                student.setLastName(rs.getString("last_name"));
                student.setEmail(rs.getString("email"));
                student.setAge(rs.getInt("age"));
                student.setDepartment(rs.getString("department"));
                student.setPhone(rs.getString("phone"));
                student.setAddress(rs.getString("address"));
                student.setEnrollmentDate(rs.getDate("enrollment_date"));
                student.setGpa(rs.getDouble("gpa"));
                request.setAttribute("student", student);
            } else {
                request.setAttribute("errorMessage", "Student not found");
            }
            
            listStudents(request, response);
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            listStudents(request, response);
        }
    }

    private void updateStudent(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(
                 "UPDATE students SET first_name = ?, last_name = ?, email = ?, age = ?, department = ?, phone = ?, address = ?, enrollment_date = ?, gpa = ? WHERE id = ?")) {
            
            stmt.setString(1, request.getParameter("firstName"));
            stmt.setString(2, request.getParameter("lastName"));
            stmt.setString(3, request.getParameter("email"));
            stmt.setInt(4, Integer.parseInt(request.getParameter("age")));
            stmt.setString(5, request.getParameter("department"));
            stmt.setString(6, request.getParameter("phone"));
            stmt.setString(7, request.getParameter("address"));
            String enrollmentDate = request.getParameter("enrollmentDate");
            stmt.setDate(8, enrollmentDate.isEmpty() ? null : Date.valueOf(enrollmentDate));
            String gpa = request.getParameter("gpa");
            stmt.setDouble(9, gpa.isEmpty() ? 0.0 : Double.parseDouble(gpa));
            stmt.setInt(10, Integer.parseInt(request.getParameter("id")));
            stmt.executeUpdate();
            
            request.getSession().setAttribute("message", "Student updated successfully!");
            response.sendRedirect("StudentServlet?action=list");
            
        } catch (SQLException | IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Error updating student: " + e.getMessage());
            listStudents(request, response);
        }
    }

    private void deleteStudent(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid student ID");
            listStudents(request, response);
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM students WHERE id = ?")) {
            
            stmt.setInt(1, id);
            stmt.executeUpdate();
            
            request.getSession().setAttribute("message", "Student deleted successfully!");
            response.sendRedirect("StudentServlet?action=list");
            
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error deleting student: " + e.getMessage());
            listStudents(request, response);
        }
    }

    public static class Student {
        private int id;
        private String firstName;
        private String lastName;
        private String email;
        private int age;
        private String department;
        private String phone;
        private String address;
        private Date enrollmentDate;
        private double gpa;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public int getAge() { return age; }
        public void setAge(int age) { this.age = age; }
        public String getDepartment() { return department; }
        public void setDepartment(String department) { this.department = department; }
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
        public Date getEnrollmentDate() { return enrollmentDate; }
        public void setEnrollmentDate(Date enrollmentDate) { this.enrollmentDate = enrollmentDate; }
        public double getGpa() { return gpa; }
        public void setGpa(double gpa) { this.gpa = gpa; }
    }
}