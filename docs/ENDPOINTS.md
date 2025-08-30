# ENDPOINTS (MP16 scope)

## Media
POST /media/uploads

## Alerts
POST /alerts
POST /alerts/{id}/media

## Comments
GET /alerts/{id}/comments
POST /alerts/{id}/comments

## Follows
POST /alerts/{id}/follow

Notes:
- All POSTs require `Authorization: Bearer <token>`
- `Idempotency-Key` header recommended for media/alerts POSTs
