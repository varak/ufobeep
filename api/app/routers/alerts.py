from fastapi import APIRouter

router = APIRouter(
    prefix="/alerts",
    tags=["alerts"] 
)
