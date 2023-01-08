from pykafka.Customer import Customer, customer_to_dict, customer_from_dict

import pytest


@pytest.fixture
def customer():
    return Customer('1234', 'Isaac Newton')


def test_customer(customer):
    assert customer.id == '1234'
    assert customer.name == 'Isaac Newton'
    assert str(customer) == "Customer(id='1234', name='Isaac Newton')"


def test_to_dict(customer):
    result = customer_to_dict(customer)
    assert result.get('id', '') == '1234'
    assert result.get('name', '') == 'Isaac Newton'


def test_from_dict_empty():
    result = customer_from_dict({})
    assert result is not None
    assert result.id == ''
    assert result.name == ''


def test_from_dict(customer):
    result = customer_from_dict({'id': '1234', 'name': 'Isaac Newton'})
    assert result.id == customer.id
    assert result.name == customer.name
