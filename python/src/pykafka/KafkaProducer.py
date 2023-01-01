import logging
import socket
import uuid
from pykafka.Config import Config
from pykafka.DataStream import DataStream
from confluent_kafka import Producer


class KafkaProducer:
    """
    This class uses the supplied configuration and a data stream to write to kafka.
    """
    def __init__(self, config: Config, datastream: DataStream):
        self.config = config
        self.datastream = datastream
        self.errors = 0
        self.success = 0
        self.producer = Producer(
            {
                'bootstrap.servers': config.bootstrap,
                'client.id': socket.gethostname(),
                'security.protocol': 'SSL'
            }
        )

    def execute(self):
        """
        When called, will use the configuration and data stream to write to Kafka
        """
        logging.info('Started')

        for _ in range(self.config.count):
            self.producer.produce(
                self.config.topic,
                key=str(uuid.uuid4()),
                value=next(self.datastream.data_stream()),
                callback=self.error_logger)

        # Block until the messages are sent.
        remaining = self.producer.poll(10)
        if remaining > 0:
            logging.warning(f'{remaining} messages were still in the queue waiting to go')
        self.producer.flush()
        self.datastream.data_stream().close()

        logging.info(f'Stopped - {self.errors} errors, {self.success} sent')

    def error_logger(self, err, _):
        if err is not None:
            self.errors += 1
            logging.error(f'Failed to send message: {str(err)}')
        else:
            self.success += 1
