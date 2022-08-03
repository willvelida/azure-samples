using Azure.Messaging.ServiceBus;

namespace RequestReplyPoc.Helpers
{
    public interface IServiceBusHelper
    {
        ServiceBusSender CreateSendClient(string topicName);
        ServiceBusReceiver CreateReceiveClient(string topicName, string subscriptionName);
    }
}
