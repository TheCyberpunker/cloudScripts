# script by Danilo Erazo (sprintec).
# https://thecyberpunker.com/pentesting/pentesting-cloud-azure/

import asyncio
from azure.eventhub.aio import EventHubProducerClient
from azure.eventhub import EventData

async def run():
    # Create a producer client to send messages to the event hub.
    # Specify a connection string to your event hubs namespace and
    # the event hub name.
    producer = EventHubProducerClient.from_connection_string(conn_str="Endpoint=sb://NAMESPACE_AQUI.servicebus.windows.net/;SharedAccessKeyName=SHAREDACCESKEYNAME_AQUI;SharedAccessKey=SHAREDACCESSKEY_AQUI;EntityPath=receipt-holder-update-test", eventhub_name="ELMISMO_ENTITIPATH")
    print("Autenticacion exitosa")
    async with producer:
        # Create a batch.
        event_data_batch = await producer.create_batch()
        # Add events to the batch.
        e1='Fluid First event'
        e2='Fluid Second event'
        e3='Fluid Third event'
        print("Eventos a enviar: ")
        print(e1)
        print(e2)
        print(e3)
        event_data_batch.add(EventData(e1))
        event_data_batch.add(EventData(e2))
        event_data_batch.add(EventData(e3))

        # Send the batch of events to the event hub.
        await producer.send_batch(event_data_batch)
        print("Se enviaron los eventos de prueba exitosamente")

loop = asyncio.get_event_loop()
loop.run_until_complete(run())

