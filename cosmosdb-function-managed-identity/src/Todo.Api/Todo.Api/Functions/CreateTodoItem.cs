using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Todo.Api.Helpers.Interfaces;
using Todo.Api.Models;

namespace Todo.Api.Functions
{
    public class CreateTodoItem
    {
        private readonly ITodoRepository _todoRepository;
        private readonly ILogger<CreateTodoItem> _logger;

        public CreateTodoItem(ITodoRepository todoRepository, ILogger<CreateTodoItem> logger)
        {
            _todoRepository = todoRepository;
            _logger = logger;
        }

        [FunctionName("CreateTodoItem")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "todo")] HttpRequest req,
            ILogger log)
        {
            try
            {
                string message = await new StreamReader(req.Body).ReadToEndAsync();
                var todoItem = JsonConvert.DeserializeObject<TodoItem>(message);

                await _todoRepository.CreateTodoItem(todoItem);

                return new OkObjectResult(todoItem);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(CreateTodoItem)} Function: {ex.Message}");
                return new StatusCodeResult(StatusCodes.Status500InternalServerError);
            }
        }
    }
}
