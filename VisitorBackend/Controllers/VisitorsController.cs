using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient; 

namespace VisitorBackend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VisitorController : ControllerBase
    {
        // IMPORTANT: Ensure SQL Column 'ImageBaseString' is NVARCHAR(MAX)
        private readonly string _connectionString = "Server=DESKTOP-EFDPM68\\SQLEXPRESS;Database=VMS;Trusted_Connection=True;TrustServerCertificate=True;";

        [HttpPost]
public IActionResult Post([FromBody] VisitorModel model)
{
    if (model == null || string.IsNullOrEmpty(model.ImageBaseString)) 
        return BadRequest("No image data provided.");

    try {
        // 1. Generate a unique filename (e.g., 33095114...jpg)
        string fileName = $"{Guid.NewGuid()}.jpg";
        
        // 2. Point to the folder you just created
        string folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images");
        
        // Create the directory if it doesn't exist (safety check)
        if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);
        
        string fullPath = Path.Combine(folderPath, fileName);

        // 3. Save the actual file to your computer
        byte[] imageBytes = Convert.FromBase64String(model.ImageBaseString);
        System.IO.File.WriteAllBytes(fullPath, imageBytes);

        // 4. Save the FILENAME to SQL (not the huge string anymore)
        using (SqlConnection conn = new SqlConnection(_connectionString)) {
            string query = @"INSERT INTO Visitor (FullName, Company, Contact, Email, Purpose, WhoVisited, Reason, ContactPerson, ImageBaseString, Completed, Date_SignIn, Date_SignOut, Date_Modified) 
                            VALUES (@FullName, @Company, @Contact, @Email, @Purpose, @WhoVisited, @Reason, @ContactPerson, @ImageBaseString, @Completed, @Date_SignIn, @Date_SignOut, GETDATE())";
            
            using (SqlCommand cmd = new SqlCommand(query, conn)) {
                cmd.Parameters.AddWithValue("@FullName", model.FullName ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Company", model.Company ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Contact", model.Contact ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Email", model.Email ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Purpose", model.Purpose);
                cmd.Parameters.AddWithValue("@WhoVisited", model.WhoVisited ?? "General");
                cmd.Parameters.AddWithValue("@Reason", model.Reason ?? "Visit");
                cmd.Parameters.AddWithValue("@ContactPerson", model.ContactPerson ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Completed", model.Completed);
                
                // We save the FILENAME string here!
                cmd.Parameters.AddWithValue("@ImageBaseString", fileName); 
                
                cmd.Parameters.AddWithValue("@Date_SignIn", model.Date_SignIn == default ? DateTime.Now : model.Date_SignIn);
                cmd.Parameters.AddWithValue("@Date_SignOut", new DateTime(1900, 1, 1));

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
        return Ok(new { message = "Registration successful!", file = fileName });
    } catch (Exception ex) { 
        return StatusCode(500, $"Database Error: {ex.Message}"); 
    }

}
  // ... rest of your code ...
    
    public class VisitorModel {
        public string? FullName { get; set; }
        public string? Company { get; set; }
        public string? Contact { get; set; }
        public string? Email { get; set; }
        public int Purpose { get; set; }
        public string? WhoVisited { get; set; } 
        public string? Reason { get; set; }
        public int Completed { get; set; } 
        public string? ContactPerson { get; set; }
        public string? ImageBaseString { get; set; }
        public DateTime Date_SignIn { get; set; }
    } 
} // Closes the VisitorController class
} // Closes the VisitorBackend.Controllers namespace