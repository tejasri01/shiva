<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Management</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #e9ecef;
        }
        .container {
            max-width: 1400px;
            margin: auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 20px;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        .btn-primary {
            background-color: #007bff;
            color: white;
        }
        .btn-primary:hover {
            background-color: #0056b3;
        }
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        .btn-danger:hover {
            background-color: #c82333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        th {
            background-color: #007bff;
            color: white;
            font-weight: 600;
        }
        tr:hover {
            background-color: #f8f9fa;
        }
        .action-links a {
            margin-right: 10px;
            text-decoration: none;
            color: #007bff;
            font-weight: 500;
        }
        .action-links a:hover {
            text-decoration: underline;
        }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .modal-content {
            background: white;
            padding: 20px;
            border-radius: 8px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .modal-header h3 {
            margin: 0;
            color: #2c3e50;
        }
        .close-btn {
            font-size: 24px;
            cursor: pointer;
            color: #6c757d;
        }
        .close-btn:hover {
            color: #343a40;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: #2c3e50;
        }
        .form-group label.required::after {
            content: '*';
            color: red;
            margin-left: 5px;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ced4da;
            border-radius: 5px;
            font-size: 16px;
        }
        .success-message, .error-message {
            display: none;
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 10px 20px;
            border-radius: 5px;
            z-index: 1000;
        }
        .success-message {
            background-color: #28a745;
            color: white;
        }
        .error-message {
            background-color: #dc3545;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Student Management</h2>
        <button class="btn btn-primary" onclick="openModal('add')">Add New Student</button>
        <a href="welcome.jsp" class="btn btn-danger">Back to Welcome</a>

        <!-- Error Message -->
        <c:if test="${not empty errorMessage}">
            <div id="errorMessage" class="error-message">${errorMessage}</div>
        </c:if>

        <!-- Students Table -->
        <table>
            <tr>
                <th>ID</th>
                <th>First Name</th>
                <th>Last Name</th>
                <th>Email</th>
                <th>Age</th>
                <th>Department</th>
                <th>Phone</th>
                <th>Address</th>
                <th>Enrollment Date</th>
                <th>GPA</th>
                <th>Actions</th>
            </tr>
            <c:choose>
                <c:when test="${not empty students}">
                    <c:forEach var="student" items="${students}">
                        <tr>
                            <td><c:out value="${student.id}" default="N/A"/></td>
                            <td><c:out value="${student.firstName}" default="N/A"/></td>
                            <td><c:out value="${student.lastName}" default="N/A"/></td>
                            <td><c:out value="${student.email}" default="N/A"/></td>
                            <td><c:out value="${student.age}" default="N/A"/></td>
                            <td><c:out value="${student.department}" default="N/A"/></td>
                            <td><c:out value="${student.phone}" default="N/A"/></td>
                            <td><c:out value="${student.address}" default="N/A"/></td>
                            <td><c:out value="${student.enrollmentDate}" default="N/A"/></td>
                            <td><c:out value="${student.gpa}" default="N/A"/></td>
                            <td class="action-links">
                                <a href="StudentServlet?action=edit&id=${student.id}" onclick="openEditModal(); return false;">Edit</a>
                                <a href="StudentServlet?action=delete&id=${student.id}" 
                                   onclick="return confirm('Are you sure you want to delete this student?')">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="11">No students found</td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </table>
    </div>

    <!-- Modal for Add/Edit Student -->
    <div id="studentModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="modalTitle">Add Student</h3>
                <span class="close-btn" onclick="closeModal()">&times;</span>
            </div>
            <form id="studentForm" action="StudentServlet" method="post">
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="id" id="studentId" value="${student != null ? student.id : ''}">
                
                <div class="form-group">
                    <label class="required">First Name</label>
                    <input type="text" name="firstName" id="firstName" value="${student != null ? student.firstName : ''}" required>
                </div>
                
                <div class="form-group">
                    <label class="required">Last Name</label>
                    <input type="text" name="lastName" id="lastName" value="${student != null ? student.lastName : ''}" required>
                </div>
                
                <div class="form-group">
                    <label class="required">Email</label>
                    <input type="email" name="email" id="email" value="${student != null ? student.email : ''}" required>
                </div>
                
                <div class="form-group">
                    <label class="required">Age</label>
                    <input type="number" name="age" id="age" value="${student != null ? student.age : ''}" required>
                </div>
                
                <div class="form-group">
                    <label class="required">Department</label>
                    <select name="department" id="department" required>
                        <option value="">Select Department</option>
                        <option value="Computer Science" ${student != null && student.department == 'Computer Science' ? 'selected' : ''}>Computer Science</option>
                        <option value="Mathematics" ${student != null && student.department == 'Mathematics' ? 'selected' : ''}>Mathematics</option>
                        <option value="Physics" ${student != null && student.department == 'Physics' ? 'selected' : ''}>Physics</option>
                        <option value="Chemistry" ${student != null && student.department == 'Chemistry' ? 'selected' : ''}>Chemistry</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="required">Phone</label>
                    <input type="text" name="phone" id="phone" value="${student != null ? student.phone : ''}" required>
                </div>
                
                <div class="form-group">
                    <label class="required">Address</label>
                    <input type="text" name="address" id="address" value="${student != null ? student.address : ''}" required>
                </div>
                
                <div class="form-group">
                    <label class="required">Enrollment Date</label>
                    <input type="date" name="enrollmentDate" id="enrollmentDate" value="${student != null ? student.enrollmentDate : ''}" required>
                </div>
                
                <div class="form-group">
                    <label>GPA</label>
                    <input type="number" step="any" name="gpa" id="gpa" value="${student != null ? student.gpa : ''}">
                </div>
                
                <button type="submit" class="btn btn-primary">Save</button>
                <button type="button" class="btn btn-danger" onclick="closeModal()">Cancel</button>
            </form>
        </div>
    </div>

    <!-- Success Message -->
    <div id="successMessage" class="success-message">
        <c:if test="${not empty sessionScope.message}">
            ${sessionScope.message}
            <c:remove var="message" scope="session"/>
        </c:if>
    </div>

    <script>
        function openModal(action) {
            const modal = document.getElementById('studentModal');
            const modalTitle = document.getElementById('modalTitle');
            const formAction = document.getElementById('formAction');
            const form = document.getElementById('studentForm');
            
            if (action === 'edit') {
                modalTitle.textContent = 'Edit Student';
                formAction.value = 'update';
            } else {
                modalTitle.textContent = 'Add Student';
                formAction.value = 'add';
                form.reset();
            }
            
            modal.style.display = 'flex';
        }

        function openEditModal() {
            const studentId = document.getElementById('studentId').value;
            if (studentId) {
                openModal('edit');
            } else {
                alert('Error: Student data not loaded. Please try again.');
            }
        }

        function closeModal() {
            document.getElementById('studentModal').style.display = 'none';
            document.getElementById('studentForm').reset();
        }

        window.onload = function() {
            const successMessage = document.getElementById('successMessage');
            const errorMessage = document.getElementById('errorMessage');
            const studentId = document.getElementById('studentId').value;
            
            if (successMessage.textContent.trim() !== '') {
                successMessage.style.display = 'block';
                setTimeout(() => {
                    successMessage.style.display = 'none';
                }, 3000);
            }
            
            if (errorMessage && errorMessage.textContent.trim() !== '') {
                errorMessage.style.display = 'block';
                setTimeout(() => {
                    errorMessage.style.display = 'none';
                }, 5000);
            }

            if (studentId) {
                openModal('edit');
            }
        };
    </script>
</body>
</html>