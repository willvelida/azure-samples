using Azure.Messaging.ServiceBus;
using System;

namespace RequestReplyPoc.Helpers
{
    public class ServiceBusHelper : IServiceBusHelper
    {
        private readonly ServiceBusClient _serviceBusClient;

        public ServiceBusHelper(ServiceBusClient serviceBusClient)
        {
            _serviceBusClient=serviceBusClient;
        }

        public ServiceBusReceiver CreateReceiveClient(string topicName, string subscriptionName)
        {
            if (string.IsNullOrWhiteSpace(topicName))
                throw new ArgumentNullException(topicName);

            if (string.IsNullOrWhiteSpace(subscriptionName))
                throw new ArgumentNullException(subscriptionName);

            return _serviceBusClient.CreateReceiver(topicName, subscriptionName);
        }

        public ServiceBusSender CreateSendClient(string topicName)
        {
            if (string.IsNullOrWhiteSpace(topicName))
                throw new ArgumentNullException(topicName);

            return _serviceBusClient.CreateSender(topicName);
        }
    }
}
