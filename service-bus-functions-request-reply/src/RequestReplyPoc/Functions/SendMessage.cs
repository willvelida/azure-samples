using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using RequestReplyPoc.Helpers;
using RequestReplyPoc.Options;
using System;
using System.Threading.Tasks;

namespace RequestReplyPoc.Functions
{
    public class SendMessage
    {
        private readonly IServiceBusHelper _serviceBusHelper;
        private readonly ServiceBusSettings _settings;

        public SendMessage(IServiceBusHelper serviceBusHelper, IOptions<ServiceBusSettings> options)
        {
            _serviceBusHelper = serviceBusHelper;
            _settings = options.Value;
        }

        [FunctionName(nameof(SendMessage))]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "sendmessage")] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            Order order = new Order
            {
                OrderId = Guid.NewGuid().ToString()
            };

            ServiceBusMessage messageToSend = new ServiceBusMessage
            {
                SessionId = Guid.NewGuid().ToString(),
                Body = BinaryData.FromString(JsonConvert.SerializeObject(order)),
                ReplyTo = "reply",
            };

            var topicSender = _serviceBusHelper.CreateSendClient(_settings.OrderTopicName);

            await topicSender.SendMessageAsync(messageToSend);

            return new OkObjectResult(order);
        }
    }
}
