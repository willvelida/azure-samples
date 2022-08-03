namespace RequestReplyPoc.Options
{
    public class ServiceBusSettings
    {
        public string ConnectionString { get; set; }
        public string OrderTopicName { get; set; }
        public string OrderSubscriptionName { get; set; }
        public string ReplyTopicName { get; set; }
        public string ReplySubscriptionName { get; set; }
    }
}
