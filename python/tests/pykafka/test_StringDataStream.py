import pytest

from pykafka.DataStream import DataStream
from pykafka.StringDataStream import StringDataStream


@pytest.fixture()
def data_stream():
    return StringDataStream()


def test_string_data_list(data_stream):
    result = data_stream.data_list(10)
    assert len(result) == 10
    for item in result:
        assert item is not None


def test_string_data_stream(data_stream: DataStream):
    result = [next(data_stream.data_stream()) for _ in range(10)]
    assert len(result) == 10
    for item in result:
        assert item is not None
