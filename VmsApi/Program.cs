var builder = WebApplication.CreateBuilder(args);

// 1. Add CORS Policy so Chrome doesn't block your Flutter Web app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter",
        policy => policy.WithOrigins("*") // Allows all origins for local development
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

// 2. Add Controller services (Required for your VisitorController.cs)
builder.Services.AddControllers();

// Add OpenAPI/Swagger (Keep this for testing)
builder.Services.AddOpenApi();

var app = builder.Build();

// 3. Use the CORS policy before other middleware
app.UseCors("AllowFlutter");

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// Map your VisitorController routes
app.MapControllers();

// Keep the default weather forecast for testing if you want
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}