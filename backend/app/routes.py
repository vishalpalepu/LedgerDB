from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import jwt
from .auth import decode_token
from .db import get_db
from .config import settings

router = APIRouter()

oauth_scheme = OAuth2PasswordBearer(tokenUrl="/token")

@router.get("/dashboard")
async def dashboard(db=Depends(get_db), token: str = Depends(oauth_scheme)):
    """Return aggregated analytics data for the frontend.
    The endpoint queries the pre‑computed views that expose the core analytics:
    - monthly_summary (monthly totals)
    - category_summary (spending per category)
    - budget_vs_actual (budget vs actual per category)
    - spending_trend (historical monthly spending)
    """
    # Simple token validation – will raise 401 if invalid
    decode_token(token)
    data = {}
    queries = {
        "monthly_summary": "SELECT month, year, total_spending, total_budget, remaining FROM monthly_summary",
        "category_summary": "SELECT category_name, total_spending FROM category_summary",
        "budget_vs_actual": "SELECT category_name, budget_amount, actual_spending, variance FROM budget_vs_actual",
        "spending_trend": "SELECT month, year, total_spending FROM spending_trend ORDER BY year, month",
    }
    with db.cursor() as cur:
        for key, q in queries.items():
            cur.execute(q)
            cols = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
            data[key] = [dict(zip(cols, row)) for row in rows]
    return data
