using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Configuration;

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();

var connectionString = configuration["ServiceBusConnectionString"];
var queueName = configuration["QueueName"];
var topicName = configuration["TopicName"];
var subscriptionName = configuration["SubscriptionName"];

await using var client = new ServiceBusClient(connectionString);
ServiceBusSender queueSender = client.CreateSender(topicName);
ServiceBusReceiver queueReceiver = client.CreateReceiver(queueName);
ServiceBusReceiver topicReceiver = client.CreateReceiver(topicName, subscriptionName);

ServiceBusMessage message = new ServiceBusMessage("Hello world!");

await queueSender.SendMessageAsync(message);

ServiceBusReceivedMessage queueMessage = await queueReceiver.ReceiveMessageAsync();
Console.WriteLine("Message content from queue: " + queueMessage.Body);
ServiceBusReceivedMessage topicMessage = await topicReceiver.ReceiveMessageAsync();
Console.WriteLine("Message content from topic: " + topicMessage.Body);