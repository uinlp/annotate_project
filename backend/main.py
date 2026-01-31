from fastapi import FastAPI
from src.api.v1 import router as v1_router
from mangum import Mangum


app = FastAPI()

app.include_router(router=v1_router, prefix="/v1")

@app.get("/")
async def read_root():
    return {"Hello": "World"}


handler = Mangum(app)