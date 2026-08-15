from uuid import uuid4

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import BaseModel, Field


# Pydantic models
class UserCreate(BaseModel):
    name: str = Field(min_length=2)


class User(UserCreate):
    id: str


# Init app
app = FastAPI()
local_users: list[User] = []


# Exceptions
@app.exception_handler(RequestValidationError)
def validation_exception_handler(
    request: Request,
    exc: RequestValidationError
):
    return JSONResponse(
        content={"detail": exc.errors()},
        status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
    )


# Endpoints
@app.get("/")
def get_hello_world() -> JSONResponse:
    return JSONResponse({"message": "Hello, World!"})


@app.get("/health")
def get_health() -> JSONResponse:
    return JSONResponse({"status": "ok"})


@app.get("/api/users")
def get_users() -> JSONResponse:
    return JSONResponse({"users": [user.model_dump() for user in local_users]})


@app.post("/api/users")
def create_user(name: UserCreate) -> JSONResponse:
    new_user = User(id=str(uuid4()), **name.model_dump())
    local_users.append(new_user)
    return JSONResponse(
        {"message": "Successfully created new user"},
        status_code=status.HTTP_201_CREATED,
    )


@app.get("/api/users/{id}")
def get_user_by_id(id: str) -> JSONResponse:
    check_user = [user for user in local_users if user.id == id]
    if check_user:
        return JSONResponse(check_user[0].model_dump())
    return JSONResponse({"message": f"Not founded user with id {id}"})


@app.delete("/api/users/{id}")
def delete_user_by_id(id: str) -> JSONResponse:
    check_user = [user for user in local_users if user.id == id]
    if check_user:
        local_users.remove(check_user[0])
        return JSONResponse({"message": "User successfully deleted"})
    return JSONResponse(
        {"message": "Not founded user"}, status_code=status.HTTP_404_NOT_FOUND
    )
