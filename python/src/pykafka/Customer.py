from dataclasses import dataclass
from typing import Any, Union


@dataclass
class Customer:
    """
    data object representing our Customer record
    """
    id: str
    name: str


def customer_to_dict(customer: Customer) -> dict[str, Any]:
    return dict(
        id=customer.id,
        name=customer.name
    )


def customer_from_dict(values: dict[str, Any]) -> Union[Customer, None]:
    if values is None:
        return None
    return Customer(
        id=values.get('id', ''),
        name=values.get('name', '')
    )
