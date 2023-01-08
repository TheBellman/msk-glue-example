import logging
import socket
import uuid
from pykafka.Config import Config
from pykafka.DataStream import DataStream
from kafka import KafkaProducer as Producer
from kafka.errors import KafkaTimeoutError


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
            bootstrap_servers=config.bootstrap,
            client_id=socket.gethostname(),
            security_protocol='SSL'

        )

    def execute(self):
        """
        When called, will use the configuration and data stream to write to Kafka
        """
        logging.info('Started')

        for _ in range(self.config.count):
            try:
                self.producer.send(
                    self.config.topic,
                    key=str(uuid.uuid4()),
                    value=next(self.datastream.data_stream())
                )
                self.success += 1
            except KafkaTimeoutError:
                self.errors += 1

        self.producer.flush(timeout=5)
        self.producer.close()
        self.datastream.data_stream().close()

        logging.info(f'Stopped - {self.errors} errors, {self.success} sent')
