using Microsoft.AspNetCore.Mvc;
using firstapp.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace firstapp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VisitorController : ControllerBase
    {
        private readonly string _connectionString;
        private readonly IWebHostEnvironment _env; // Field to access the web root directory

        // Constructor handles Dependency Injection for both Configuration and Environment
        public VisitorController(IConfiguration configuration, IWebHostEnvironment env)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
            _env = env; // Initializes the environment service
        }

        [HttpPost]
        public IActionResult Post([FromBody] VisitorModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.ImageBaseString))
                return BadRequest("Invalid data or missing image.");

            try
            {
                // 1. Cleans 'data:image/jpeg;base64,' headers if present
                string base64Data = model.ImageBaseString.Contains(",")
                    ? model.ImageBaseString.Split(',')[1]
                    : model.ImageBaseString;

                // 2. Physical File Saving using WebRootPath
                string fileName = $"{Guid.NewGuid()}.jpg";

                // _env.WebRootPath automatically points to the 'wwwroot' folder
                string folderPath = Path.Combine(_env.WebRootPath, "images");

                // Ensure the folder exists
                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                string fullPath = Path.Combine(folderPath, fileName);
                byte[] imageBytes = Convert.FromBase64String(base64Data);
                System.IO.File.WriteAllBytes(fullPath, imageBytes);

                // 3. Database Insertion
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    string query = @"INSERT INTO Visitor 
                           (FullName, Company, Contact, Email, Purpose, WhoVisited, Reason, ContactPerson, ImageBaseString, Completed, Date_SignIn, Date_SignOut, Date_Modified) 
                           VALUES 
                           (@FullName, @Company, @Contact, @Email, @Purpose, @WhoVisited, @Reason, @ContactPerson, @ImageBaseString, @Completed, @Date_SignIn, @Date_SignOut, @Date_Modified)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FullName", model.FullName ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Company", model.Company ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Contact", model.Contact ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Email", model.Email ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Purpose", model.Purpose);
                        cmd.Parameters.AddWithValue("@WhoVisited", model.WhoVisited ?? "General");
                        cmd.Parameters.AddWithValue("@Reason", model.Reason ?? "Visit");
                        cmd.Parameters.AddWithValue("@ContactPerson", model.ContactPerson ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Completed", model.Completed);

                        // CRITICAL: We save ONLY the filename in the DB
                        cmd.Parameters.AddWithValue("@ImageBaseString", fileName);

                        cmd.Parameters.AddWithValue("@Date_SignIn", model.Date_SignIn == default ? DateTime.Now : model.Date_SignIn);
                        cmd.Parameters.AddWithValue("@Date_SignOut", new DateTime(1900, 1, 1));
                        cmd.Parameters.AddWithValue("@Date_Modified", DateTime.Now);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                return Ok(new { message = "Registration successful!", file = fileName });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Database Error: {ex.Message}");
            }
        }

        [HttpGet]
        public IActionResult Get()
        {
            var visitors = new List<VisitorModel>();
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    string sql = "SELECT * FROM Visitor ORDER BY Id DESC";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            visitors.Add(new VisitorModel
                            {
                                FullName = reader["FullName"]?.ToString(),
                                Company = reader["Company"]?.ToString(),
                                // This provides the filename for Flutter to build the URL
                                ImageBaseString = reader["ImageBaseString"]?.ToString(),
                                Date_SignIn = reader["Date_SignIn"] != DBNull.Value
                                    ? Convert.ToDateTime(reader["Date_SignIn"])
                                    : DateTime.MinValue
                            });
                        }
                    }
                }
                return Ok(visitors);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Database Error: {ex.Message}");
            }
        }
    }
}