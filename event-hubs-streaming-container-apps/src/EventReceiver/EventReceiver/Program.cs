using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using EventReceiver;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System.Text;

IConfiguration configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
    .Build();

CosmosClientOptions cosmosClientOptions = new CosmosClientOptions
{
    MaxRetryAttemptsOnRateLimitedRequests = 3,
    MaxRetryWaitTimeOnRateLimitedRequests = TimeSpan.FromSeconds(3)
};
CosmosClient cosmosClient = new CosmosClient(configuration["cosmosdbendpoint"], new DefaultAzureCredential(), cosmosClientOptions);
Container container = cosmosClient.GetContainer(configuration["databasename"], configuration["containername"]);

BlobContainerClient blobContainerClient = new BlobContainerClient(new Uri(configuration["blobendpointuri"]), new DefaultAzureCredential());
EventProcessorClient processorClient = new EventProcessorClient(blobContainerClient, configuration["consumergroupname"], configuration["eventhubconnection"], configuration["readingseventhub"], new DefaultAzureCredential());

async Task ProcessEventHandler(ProcessEventArgs processEventArgs)
{
    Console.WriteLine("\tReceived event: {0}", Encoding.UTF8.GetString(processEventArgs.Data.EventBody.ToArray()));
    await processEventArgs.UpdateCheckpointAsync(processEventArgs.CancellationToken);

    ItemRequestOptions itemRequestOptions = new ItemRequestOptions
    {
        EnableContentResponseOnWrite = false
    };

    var deviceReading = JsonConvert.DeserializeObject<DeviceReading>(Encoding.UTF8.GetString(processEventArgs.Data.EventBody.ToArray()));

    await container.CreateItemAsync<DeviceReading>(deviceReading, new PartitionKey(deviceReading.DeviceId), itemRequestOptions);
}

Task ProcessErrorHandler(ProcessErrorEventArgs processErrorEventArgs)
{
    Console.WriteLine($"\tPartition '{processErrorEventArgs.PartitionId}': an unhandled exception was encountered");
    Console.WriteLine(processErrorEventArgs.Exception.Message);
    return Task.CompletedTask;
}