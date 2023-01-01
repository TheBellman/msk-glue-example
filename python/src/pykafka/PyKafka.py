import click
from pykafka.Config import Config
from pykafka.KafkaConsumer import KafkaConsumer
from pykafka.KafkaProducer import KafkaProducer
from pykafka.StringDataStream import StringDataStream

pass_config = click.make_pass_decorator(Config, ensure=True)


@click.group()
@click.option('--bootstrap-server', default='localhost:9092', help='Where to find kafka, assumed to be host:port'
                                                                   ' (defaults to locahost:9092)')
@click.option('--topic', default='pykafka', help='The target topic to use (defaults to pykafka)')
@pass_config
def cli(config: Config, bootstrap_server: str, topic: str):
    """
    Simple demonstration of using Kafka producers/consumers.
    """
    config.bootstrap = bootstrap_server
    config.topic = topic


@cli.command()
@click.option('--count', default=100, help='Number of messages to produce (default 100)')
@pass_config
def produce(config: Config, count: int):
    config.count = count
    producer = KafkaProducer(config, StringDataStream())
    producer.execute()


@cli.command()
@pass_config
def consume(config: Config):
    consumer = KafkaConsumer(config)
    consumer.execute()


if __name__ == '__main__':
    cli()
