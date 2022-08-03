using Azure.Messaging.ServiceBus;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using RequestReplyPoc.Helpers;
using RequestReplyPoc.Options;
using System.Text.Json;
using System.Threading.Tasks;

namespace RequestReplyPoc.Functions
{
    public class ReceiveMessageFromOrderTopic
    {
        private readonly IServiceBusHelper _serviceBusHelper;
        private readonly ServiceBusSettings _settings;
        private readonly ILogger<ReceiveMessageFromOrderTopic> _logger;

        public ReceiveMessageFromOrderTopic(
            IServiceBusHelper serviceBusHelper,
            IOptions<ServiceBusSettings> options,
            ILogger<ReceiveMessageFromOrderTopic> log)
        {
            _serviceBusHelper = serviceBusHelper;
            _settings = options.Value;
            _logger = log;
        }

        [FunctionName("ReceiveMessageFromOrderTopic")]
        public async Task Run([ServiceBusTrigger("orders", "orderssub", Connection = "ServiceBusConnection", IsSessionsEnabled = true)] ServiceBusReceivedMessage mySbMsg)
        {
            _logger.LogInformation($"C# ServiceBus topic trigger function processed message: {mySbMsg}");
            _logger.LogInformation($"Session Id: {mySbMsg.SessionId}");
            _logger.LogInformation($"Message Body: {mySbMsg.Body}");
            _logger.LogInformation($"ReplyTo: {mySbMsg.ReplyTo}");

            var replyToTopic = mySbMsg.ReplyTo;

            var responseBytes = JsonSerializer.SerializeToUtf8Bytes(mySbMsg);
            var responseMessage = new ServiceBusMessage(responseBytes)
            {
                ReplyToSessionId = mySbMsg.SessionId,
                SessionId = mySbMsg.SessionId
            };

            var topicClient = _serviceBusHelper.CreateSendClient(replyToTopic);
            await topicClient.SendMessageAsync(responseMessage);
        }
    }
}
