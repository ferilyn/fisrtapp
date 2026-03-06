namespace firstapp.Models
{
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
}
