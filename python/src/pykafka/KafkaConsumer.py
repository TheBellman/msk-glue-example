import logging
import socket

from kafka import KafkaConsumer as Consumer
from pykafka.Config import Config


class KafkaConsumer:
    """
    This class uses the supplied configuration and a data stream to write to kafka.
    """

    def __init__(self, config: Config):
        self.config = config
        self.errors = 0
        self.success = 0
        self.running = True
        # note that we have renamed the imported KafkaConsumer
        self.consumer = Consumer(
            config.topic,
            bootstrap_servers=config.bootstrap,
            client_id=socket.gethostname(),
            group_id='pykafka',
            security_protocol='SSL'
        )

    def execute(self):
        """
        when called, will start a poll loop that just pulls the messages and logs them.

        see <https://pypi.org/project/kafka-python/>
        """
        logging.info('Started')

        try:
            self.consumer.subscribe([self.config.topic])
            msg_count = 0
            while self.running:
                msg = next(self.consumer)
                if msg is None:
                    logging.info('waiting...')
                    continue

                if msg.error():
                    raise Exception(msg.error())
                else:
                    # msg reports the strings that we sent in as a byte array
                    logging.info(f'{msg.key().decode("utf-8")} : {msg.value().decode("utf-8")}')
                    msg_count += 1
        except KeyboardInterrupt:
            self.shutdown()
        finally:
            self.consumer.close()
        logging.info('Stopped')

    def shutdown(self):
        self.running = False
