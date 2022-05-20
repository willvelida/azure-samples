using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Microsoft.Extensions.Configuration;
using System.Text;

IConfiguration configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
    .Build();

EventHubProducerClient producerClient = new EventHubProducerClient(configuration["eventhubconnection"], configuration["readingseventhub"], new DefaultAzureCredential());
// number of events to be sent to the event hub
const int numOfEvents = 3;

using (EventDataBatch eventBatch = await producerClient.CreateBatchAsync())
{
    for (int i = 0; i <= numOfEvents; i++)
    {
        if (!eventBatch.TryAdd(new EventData(Encoding.UTF8.GetBytes($"Event {i}"))))
        {
            throw new Exception($"Event {i} is too large for the batch and cannot be sent");
        }
    }

    try
    {
        await producerClient.SendAsync(eventBatch);
        Console.WriteLine($"A batch of {numOfEvents} has been sent to the batch");
    }
    finally
    {
        await producerClient.DisposeAsync();
    }
}