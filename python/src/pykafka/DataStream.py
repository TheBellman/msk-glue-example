from abc import ABC, abstractmethod
from typing import Any, Generator


class DataStream(ABC):
    """
    base class to represent a data source
    """

    @abstractmethod
    def data_list(self, count: int) -> list[Any]:
        """
        return the data as a simple list containing count items
        :param count: the number of items to build
        :return: the list containing count items
        """
        pass

    @abstractmethod
    def data_stream(self) -> Generator[Any, None, None]:
        """
        return the data via a generator
        :return: a generator that produces data
        """
        pass
