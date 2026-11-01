from fastapi import FastAPI, HTTPException
from mangum import Mangum

app = FastAPI(title="${{ values.name }}", description=${{ values.description | dump }})


@app.get("/health")
def health():
    return {"status": "ok"}

{% for api in values.apis %}

@app.${{ api.method | lower }}("${{ api.path }}")
def ${{ api.name | replace('-', '_') }}():
    raise HTTPException(status_code=501, detail="Not implemented")
{% endfor %}

# Adaptador para AWS Lambda. En Kubernetes uvicorn usa "app" y este objeto no se usa.
handler = Mangum(app, lifespan="off")
