using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Todo.Api.Helpers.Interfaces;
using Todo.Api.Models;

namespace Todo.Api.Helpers
{
    public class TodoRepository : ITodoRepository
    {
        private readonly IConfiguration _config;
        private readonly CosmosClient _cosmosClient;
        private readonly Container _container;
        private readonly ILogger<TodoRepository> _logger;

        public TodoRepository(CosmosClient cosmosClient, IConfiguration config, ILogger<TodoRepository> logger)
        {
            _cosmosClient = cosmosClient;
            _config = config;
            _container = _cosmosClient.GetContainer(_config["DatabaseName"], _config["ContainerName"]);
            _logger = logger;
        }
        public async Task CreateTodoItem(TodoItem todoItem)
        {
            try
            {
                ItemRequestOptions itemRequestOptions = new ItemRequestOptions
                {
                    EnableContentResponseOnWrite = false
                };

                await _container.CreateItemAsync(todoItem, new PartitionKey(todoItem.Id), itemRequestOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(CreateTodoItem)}: {ex.Message}");
                throw;
            }
        }
    }
}
