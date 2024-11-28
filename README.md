# login

Let me explain in broad terms how the authentication system we implemented works:

1. **User Registration**
- Client sends email, name, and password
- System verifies email doesn't exist
- Password is encrypted using BCrypt
- User is created in database
- Session is created and JWT token is generated

2. **Login**
- User sends email and password
- Credentials are verified against database
- If correct, a new session is created
- A JWT token is generated and returned containing:
    - User ID
    - Session token
    - Expiration date

3. **JWT Security**
- Each protected request must include token in header
- `JwtAuthenticationFilter` intercepts each request
- Verifies token is valid and not expired
- If token is valid, sets security context

4. **Sessions**
- Each successful login creates a new session in DB
- Sessions have expiration date
- System automatically cleans expired sessions

5. **Database**
- Main tables:
    - `users`: stores user information
    - `sessions`: maintains active sessions record
    - Other tables for token handling and password reset

Would you like to dive deeper into any specific part?
