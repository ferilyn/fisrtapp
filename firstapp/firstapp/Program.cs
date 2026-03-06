var builder = WebApplication.CreateBuilder(args);

// 1. Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 2. Configure CORS - This allows your Flutter App (8443) to talk to this API (8083)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

var app = builder.Build();

// 3. Configure the Middleware Pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Order matters for these next lines:
app.UseStaticFiles(); // Allows loading images from wwwroot/images
app.UseRouting();

// Apply CORS BEFORE Authorization and Mapping
app.UseCors("AllowAll");

app.UseHttpsRedirection(); // Ensures traffic stays on HTTPS
app.UseAuthorization();

app.MapControllers();

app.Run();