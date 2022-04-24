using System;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using DeviceReaderSample.Models;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace DeviceReaderSample.Functions
{
    public class PersistReadings
    {
        private readonly ILogger<PersistReadings> _logger;
        private readonly IConfiguration _configuration;
        private readonly CosmosClient _cosmosClient;
        private readonly Container _container;

        public PersistReadings(ILogger<PersistReadings> logger, IConfiguration configuration, CosmosClient cosmosClient)
        {
            _logger = logger;
            _configuration = configuration;
            _cosmosClient = cosmosClient;
            _container = _cosmosClient.GetContainer(_configuration["DatabaseName"], _configuration["ContainerName"]);
        }

        [FunctionName(nameof(PersistReadings))]
        public async Task Run([EventHubTrigger("readings", Connection = "EventHubConnection")] EventData[] events, ILogger log)
        {
            foreach (EventData eventData in events)
            {
                try
                {
                    string messageBody = Encoding.UTF8.GetString(eventData.EventBody.ToArray());

                    var telementryEvent = JsonConvert.DeserializeObject<DeviceReading>(messageBody);

                    // Persist to cosmos db
                    await _container.CreateItemAsync(telementryEvent);
                    _logger.LogInformation($"{telementryEvent.DeviceId} has been persisted");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Something went wrong. Exception thrown: {ex.Message}");
                }
            }
        }
    }
}
