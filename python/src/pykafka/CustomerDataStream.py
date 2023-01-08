import uuid
from typing import Generator
from pykafka.Customer import Customer
from pykafka.DataStream import DataStream
from faker import Faker


class CustomerDataStream(DataStream):
    """
    implementation of data stream that produces a stream of Customer
    """
    def __init__(self):
        self.fake = Faker()

    def data_list(self, count: int) -> list[Customer]:
        return [next(self.data_stream()) for _ in range(count)]

    def data_stream(self) -> Generator[Customer, None, None]:
        while True:
            yield Customer(str(uuid.uuid4()), self.fake.name())

