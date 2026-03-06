var builder = WebApplication.CreateBuilder(args);

// 1. Add CORS policy
builder.Services.AddCors(options => {
    options.AddDefaultPolicy(policy => {
        policy.AllowAnyOrigin() // Temporarily allow any origin to test connection
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// 2. Add Controllers
builder.Services.AddControllers();

// 3. Add Swagger (Standard setup)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// 4. Enable Swagger UI
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(); 
app.MapControllers();
app.UseStaticFiles(); // This allows the 'wwwroot' folder to be accessible

app.Run();