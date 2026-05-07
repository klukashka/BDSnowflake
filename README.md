# BigDataSnowflake

Анализ больших данных — лабораторная работа №1: нормализация исходных данных в модель **звезда / снежинка** (факт + измерения) в PostgreSQL.

<img width="1411" height="692" alt="Схема" src="https://github.com/user-attachments/assets/0282c756-76a3-48f7-86e4-df6e1ec6ac89" />

**Цель:** загрузить данные из 10 CSV в staging-таблицу (10000 строк) и сформировать аналитическую модель (DDL + DML) в PostgreSQL.

---

### Состав репозитория

| Файл | Зачем |
|------|--------|
| `.env.example` | Пример переменных окружения (копируется в `.env`) |
| `docker-compose.yml` | Подъём PostgreSQL и выполнение SQL-инициализации при первом запуске |
| `sql/01_staging_load.sql` | Загрузка CSV в `stage.mock_data` (ожидается 10000 строк) |
| `sql/02_ddl_star.sql` | Создание таблиц аналитической модели в схеме `dw` |
| `sql/03_dml_populate.sql` | Заполнение таблиц `dw` из staging |
| `исходные данные/` | Исходные CSV: `MOCK_DATA.csv` … `MOCK_DATA (9).csv` |

Итог в БД: `stage.mock_data` (источник), в `dw` — измерения и таблица фактов `fact_sales`.

---

### Запуск

Требуется запущенный Docker. Один раз подготовьте файл окружения:

```bash
cd BDSnowflake
cp .env.example .env
docker compose up -d
```

Параметры подключения (DBeaver и т.д.): хост `localhost`; порт и учётные данные — в `.env` (`POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`).

Подключение через контейнер (имя контейнера — `POSTGRES_CONTAINER_NAME` из `.env`):

```bash
docker exec -it bdsnowflake-postgres psql -U bdsnowflake -d bdsnowflake
```

---

### Проверка результата

```sql
SELECT COUNT(*) FROM stage.mock_data;  -- 10000
SELECT COUNT(*) FROM dw.fact_sales;    -- 10000
```

---

### Пересоздание окружения

SQL-инициализация выполняется при создании тома данных. Для полного пересоздания:

```bash
docker compose down -v
docker compose up -d
```
