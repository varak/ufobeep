import os, random, string, requests, pytest

API_BASE = os.getenv("API_BASE"); ACCESS_JWT = os.getenv("ACCESS_JWT")
pytestmark = pytest.mark.skipif(not (API_BASE and ACCESS_JWT), reason="Set API_BASE & ACCESS_JWT")

def _h(extra=None):
    h = {"Authorization": f"Bearer {ACCESS_JWT}"}
    if extra: h.update(extra)
    return h

def _idem(): return "mp16-" + "".join(random.choices(string.ascii_letters+string.digits, k=16))

def test_media_alerts_comments_flow():
    files={"file":("a.jpg", b"\xff\xd8\xff\xd9","image/jpeg")}
    r1=requests.post(f"{API_BASE}/media/uploads", files=files, headers=_h({"Idempotency-Key":_idem()}), timeout=15)
    assert r1.status_code in (200,201); media1=r1.json()["media"][0]
    body={"message":"mp16 flow","lat":37.7749,"lon":-122.4194,"media":[media1]}
    r2=requests.post(f"{API_BASE}/alerts", json=body, headers=_h({"Idempotency-Key":_idem()}), timeout=15)
    assert r2.status_code in (200,201); aid=r2.json()["id"]
    r3=requests.post(f"{API_BASE}/alerts/{aid}/comments", json={"body":"hello"}, headers=_h(), timeout=15)
    assert r3.status_code in (200,201)
    r4=requests.get(f"{API_BASE}/alerts/{aid}/comments", headers=_h(), timeout=15)
    assert r4.status_code==200 and any("hello" in (c.get("body","")) for c in r4.json().get("items",[]))
