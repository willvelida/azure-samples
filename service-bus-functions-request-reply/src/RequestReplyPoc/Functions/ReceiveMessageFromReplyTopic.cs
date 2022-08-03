using Azure.Messaging.ServiceBus;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace RequestReplyPoc.Functions
{
    public class ReceiveMessageFromReplyTopic
    {
        private readonly ILogger<ReceiveMessageFromReplyTopic> _logger;

        public ReceiveMessageFromReplyTopic(ILogger<ReceiveMessageFromReplyTopic> log)
        {
            _logger = log;
        }

        [FunctionName("ReceiveMessageFromReplyTopic")]
        public void Run([ServiceBusTrigger("reply", "replysub", Connection = "ServiceBusConnection", IsSessionsEnabled = true)] ServiceBusReceivedMessage mySbMsg)
        {
            _logger.LogInformation($"C# ServiceBus topic trigger function processed message: {mySbMsg}");
            _logger.LogInformation($"Session Id: {mySbMsg.SessionId}");
            _logger.LogInformation($"Message Body: {mySbMsg.Body}");
        }
    }
}
