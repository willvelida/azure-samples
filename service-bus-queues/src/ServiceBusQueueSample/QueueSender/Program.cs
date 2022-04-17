using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Configuration;

IConfiguration configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json")
    .Build();

ServiceBusClient serviceBusClient = new ServiceBusClient(configuration["connectionString"]);
ServiceBusSender sender = serviceBusClient.CreateSender(configuration["queueName"]);

int numberOfMessages = 3;

using (ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync())
{
    for (int i = 1; i < numberOfMessages; i++)
    {
        if (!messageBatch.TryAddMessage(new ServiceBusMessage($"Message {i}")))
        {
            throw new Exception($"The message {i} is too large to fit in the queue");
        }
    }

    try
    {
        // Use the producer client to send the batch of messages to the service bus queue
        await sender.SendMessagesAsync(messageBatch);
        Console.WriteLine($"A batch of {numberOfMessages} messages have been sent to the queue");
    }
    finally
    {
        // Calling DisposeAsync on client types is required to ensure network
        // resources and other unmanaged objects are properly cleaned up
        await sender.DisposeAsync();
        await serviceBusClient.DisposeAsync();
    }
}

Console.WriteLine("Press any key to end the application");
Console.ReadKey();
