from typing import Generator

from pykafka.DataStream import DataStream
from faker import Faker


class StringDataStream(DataStream):
    """
    implementation of DataStream that returns the data as strings.

    Refer <https://faker.readthedocs.io/en/master/> for more information on faker
    """

    def __init__(self):
        self.fake = Faker()

    def data_list(self, count: int) -> list[str]:
        return [next(self.data_stream()) for _ in range(count)]

    def data_stream(self) -> Generator[str, None, None]:
        while True:
            yield self.fake.name()
