using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Configuration;
using System.Text;

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();
var queueName = configuration["QueueName"];

// Create the ServiceBus Clinet
// Fun fact: Using "await using" implements IAsyncDisposable :)
await using var client = new ServiceBusClient(configuration["ServiceBusConnectionString"]);
ServiceBusSender sender = client.CreateSender(queueName);

// Send and receive message
ServiceBusMessage message = new ServiceBusMessage(Encoding.UTF8.GetBytes("Hello world!"))
{
    SessionId = Guid.NewGuid().ToString()
};

await sender.SendMessageAsync(message);

// Create a session receiver that we can use to receive the message.
// This will get the next available session from the service.
ServiceBusSessionReceiver receiver = await client.AcceptNextSessionAsync(queueName);
ServiceBusReceivedMessage receivedMessage = await receiver.ReceiveMessageAsync();
Console.WriteLine(receivedMessage.Body);
Console.WriteLine(receivedMessage.SessionId);

// Receiving from a specific session
ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync();
messageBatch.TryAddMessage(new ServiceBusMessage(Encoding.UTF8.GetBytes("FirstMessage")) { SessionId = "Session1" });
messageBatch.TryAddMessage(new ServiceBusMessage(Encoding.UTF8.GetBytes("SecondMessage")) { SessionId = "Session2" });

// Send messages to Service Bus
await sender.SendMessagesAsync(messageBatch);

// Receive only Session2's message
receiver = await client.AcceptSessionAsync(queueName, "Session2");
receivedMessage = await receiver.ReceiveMessageAsync();
Console.WriteLine(receivedMessage.Body);
Console.WriteLine(receivedMessage.SessionId);