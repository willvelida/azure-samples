using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using RequestReplyPoc;
using RequestReplyPoc.Helpers;
using RequestReplyPoc.Options;
using System.IO;

[assembly: FunctionsStartup(typeof(Startup))]
namespace RequestReplyPoc
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("local.settings.json", true, true)
                .Build();

            builder.Services.AddOptions<ServiceBusSettings>()
                .Configure<IConfiguration>((settings, configuration) =>
                {
                    configuration.Bind(settings);
                });

            builder.Services.AddSingleton(sp =>
            {
                IConfiguration config = sp.GetRequiredService<IConfiguration>();
                return new ServiceBusClient(config["ServiceBusConnection"]);
            });
            builder.Services.AddTransient<IServiceBusHelper, ServiceBusHelper>();
        }
    }
}
