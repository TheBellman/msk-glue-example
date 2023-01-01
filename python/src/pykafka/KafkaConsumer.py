import logging

from confluent_kafka.cimpl import Consumer, KafkaError, KafkaException
from pykafka.Config import Config

MIN_COMMIT_COUNT = 10


class KafkaConsumer:
    """
    This class uses the supplied configuration and a data stream to write to kafka.
    """

    def __init__(self, config: Config):
        self.config = config
        self.errors = 0
        self.success = 0
        self.running = True
        self.consumer = Consumer(
            {
                'bootstrap.servers': config.bootstrap,
                'group.id': 'pykafka',
                'auto.offset.reset': 'earliest',
                'on_commit': self.commit_completed
            }
        )

    def execute(self):
        """
        when called, will start a poll loop that just pulls the messages and logs them.

        see <https://docs.confluent.io/kafka-clients/python/current/overview.html#basic-poll-loop>
        """
        logging.info('Started')

        try:
            self.consumer.subscribe([self.config.topic])
            msg_count = 0
            while self.running:
                msg = self.consumer.poll(timeout=1.0)
                if msg is None:
                    logging.info('waiting...')
                    continue

                if msg.error():
                    if msg.error().code() == KafkaError._PARTITION_EOF:
                        logging.error(f'{msg.topic()} {msg.partition()} reached end at offset {msg.offset()}')
                    elif msg.error():
                        raise KafkaException(msg.error())
                else:
                    # msg reports the strings that we sent in as a byte array
                    logging.info(f'{msg.key().decode("utf-8")} : {msg.value().decode("utf-8")}')
                    msg_count += 1
                    if msg_count % MIN_COMMIT_COUNT == 0:
                        self.consumer.commit(asynchronous=True)
        except KeyboardInterrupt:
            self.shutdown()
        finally:
            self.consumer.close()
        logging.info('Stopped')

    def shutdown(self):
        self.running = False

    @staticmethod
    def commit_completed(err, partitions):
        if err:
            logging.error(str(err))
        else:
            logging.info(f'Committed partition offsets: {str(partitions)}')
