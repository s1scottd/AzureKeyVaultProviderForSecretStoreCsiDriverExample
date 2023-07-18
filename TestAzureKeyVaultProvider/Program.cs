var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddKeyPerFile(directoryPath: "/mnt/secrets-store", optional: true);

// write the secrets to the console
List<string?> secretNames = Directory.GetFiles("/mnt/secrets-store", "*.*")
    .Select(Path.GetFileNameWithoutExtension)
    .OrderBy(p => p)
    .ToList();
foreach (var secretName in secretNames)
{
    if (string.IsNullOrWhiteSpace(secretName)) continue; // handles the case when the file was in the form .*
    Console.WriteLine($"{secretName}: {builder.Configuration[secretName]}");
}

var app = builder.Build();

app.Run();
