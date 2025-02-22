FROM python:3.11-buster AS builder

WORKDIR /app

RUN pip install --upgrade pip && pip install poetry

COPY ./pyproject.toml ./
COPY ./poetry.lock ./

RUN poetry config virtualenvs.create false \
&& poetry install --no-root --no-interaction --no-ansi

FROM python:3.11-buster AS app

WORKDIR /app

# set a special env var in the container
ENV PYTHONUNBUFFERED=1

# copy the installed dependencies from the builder stage, as well as the application code
COPY --from=builder /app /app
COPY --from=builder /usr/local /usr/local

EXPOSE 8000

CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
