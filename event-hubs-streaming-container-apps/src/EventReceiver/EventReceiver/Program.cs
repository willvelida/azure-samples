using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Storage.Blobs;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;

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

// TODO: Implement this with MI
BlobContainerClient blobContainerClient = new BlobContainerClient("", "");

EventProcessorClient processorClient = new EventProcessorClient(blobContainerClient, configuration["consumergroupname"], configuration["eventhubconnection"], configuration["readingseventhub"], new DefaultAzureCredential());
