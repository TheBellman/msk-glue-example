from importlib.resources import files
from typing import Tuple


class CustomerSchema:
    """
    A class that takes care of finding and providing the avro schema for the producer
    """
    def __init__(self):
        self.value_schema = files('pykafka.avro').joinpath('customer.avsc').read_text()
        self.key_schema = """
        {"type": "string}
        """

    def schema(self) -> Tuple[str, str]:
        return self.key_schema, self.value_schema

