using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Configuration;

IConfiguration configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json")
    .Build();

ServiceBusClient serviceBusClient = new ServiceBusClient(configuration["connectionString"]);
ServiceBusProcessor serviceBusProcessor = serviceBusClient.CreateProcessor(configuration["topicName"], configuration["subscriptionName"], new ServiceBusProcessorOptions());

try
{
    serviceBusProcessor.ProcessMessageAsync += MessageHandler;
    serviceBusProcessor.ProcessErrorAsync += ErrorHandler;

    await serviceBusProcessor.StartProcessingAsync();

    Console.WriteLine("Wait for a minute and then press any key to end the processor");
    Console.ReadKey();

    Console.WriteLine("\nStopping the receiver...");
    await serviceBusProcessor.StopProcessingAsync();
    Console.WriteLine("Stopped receiving messages");
}
finally
{
    await serviceBusProcessor.DisposeAsync();
    await serviceBusClient.DisposeAsync();
}

async Task MessageHandler(ProcessMessageEventArgs args)
{
    string body = args.Message.Body.ToString();
    Console.WriteLine($"Received: {body} from the subscription {configuration["subscriptionName"]}");
    await args.CompleteMessageAsync(args.Message);
}

Task ErrorHandler(ProcessErrorEventArgs args)
{
    Console.WriteLine(args.Exception.ToString());
    return Task.CompletedTask;
}