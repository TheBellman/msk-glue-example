import pytest
from pykafka.CustomerSchema import CustomerSchema


@pytest.fixture()
def customer_schema():
    return CustomerSchema()


def test_schema(customer_schema: CustomerSchema):
    key, value = customer_schema.schema()
    assert key is not None
    assert value is not None

