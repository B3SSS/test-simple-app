import pytest
from fastapi.testclient import TestClient

from main import app


@pytest.fixture
def client():
    with TestClient(app) as tc:
        yield tc


class TestCommon:
    def test_get_hello_world(self, client):
        response = client.get("/")
        assert response.status_code == 200
        assert response.json() == {"message": "Hello, World!"}

    def test_health(self, client):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}


class TestUsers:
    def test_get_users(self, client):
        response = client.get("/api/users")
        assert response.status_code == 200

    @pytest.mark.parametrize(
        "request_body, status_code, response_json",
        [
            (
                {"name": "Boby"},
                201,
                {"message": "Successfully created new user"}
            ),
            (
                {"name": "G"},
                422,
                {
                    "detail": [
                        {
                            "type": "string_too_short",
                            "loc": ["body", "name"],
                            "msg": "String should have at least 2 characters",
                            "input": "G", "ctx": {"min_length": 2}
                        }
                    ]
                }
            )
        ]
    )
    def test_create_user(
        self,
        request_body,
        status_code,
        response_json,
        client
    ):
        response = client.post("/api/users", json=request_body)
        assert response.status_code == status_code
        assert response.json() == response_json
