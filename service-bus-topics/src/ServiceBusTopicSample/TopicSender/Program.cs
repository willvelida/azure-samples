using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Configuration;

IConfiguration configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json")
    .Build();

int numberOfMessages = 3;
ServiceBusClient serviceBusClient = new ServiceBusClient(configuration["connectionString"]);
ServiceBusSender sender = serviceBusClient.CreateSender(configuration["topicName"]);

using (ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync())
{
    for (int i = 1; i <= numberOfMessages; i++)
    {
        if (!messageBatch.TryAddMessage(new ServiceBusMessage($"Message {i}")))
        {
            throw new Exception($"The message {i} is too large to fit in the topic");
        }
    }

    try
    {
        await sender.SendMessagesAsync(messageBatch);
        Console.WriteLine($"A batch of {numberOfMessages} messages have been pushed to the topic");
    }
    finally
    {
        await sender.DisposeAsync();
        await serviceBusClient.DisposeAsync();
    }
}

Console.WriteLine("Press any key to end the application");
Console.ReadKey();