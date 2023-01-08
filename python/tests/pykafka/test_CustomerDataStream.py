import pytest

from pykafka.DataStream import DataStream
from pykafka.CustomerDataStream import CustomerDataStream


@pytest.fixture()
def data_stream():
    return CustomerDataStream()


def test_customer_data_list(data_stream: DataStream):
    result = data_stream.data_list(10)
    assert len(result) == 10
    for item in result:
        assert item is not None


def test_customer_data_stream(data_stream: DataStream):
    result = [next(data_stream.data_stream()) for _ in range(10)]
    assert len(result) == 10
    for item in result:
        assert item is not None
