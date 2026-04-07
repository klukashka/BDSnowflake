# BigDataSnowflake

Лаба №1: из плоских CSV собрать модель **звезда / снежинка** (факт + измерения) в PostgreSQL.

<img width="1411" height="692" alt="Схема" src="https://github.com/user-attachments/assets/0282c756-76a3-48f7-86e4-df6e1ec6ac89" />

**Задание по сути:** 10 файлов по 1000 строк → одна таблица на 10 000 строк, потом DDL и DML для витрины.

---

### Что лежит в репо

| Файл | Зачем |
|------|--------|
| `.env.example` | Шаблон переменных; скопировать в `.env` |
| `docker-compose.yml` | Поднимает Postgres, сам прогоняет SQL при первом старте |
| `sql/01_staging_load.sql` | Загрузка CSV в `stage.mock_data` |
| `sql/02_ddl_star.sql` | Таблицы в схеме `dw` |
| `sql/03_dml_populate.sql` | Заполнение `dw` из staging |
| `исходные данные/` | `MOCK_DATA.csv` … `MOCK_DATA (9).csv` |

Итог в БД: `stage.mock_data` (сырьё), в `dw` — измерения + `fact_sales`.

---

### Как запустить

Нужен запущенный Docker. Один раз скопируй настройки:

```bash
cd BDSnowflake
cp .env.example .env
docker compose up -d
```

Подключение (DBeaver и т.д.): хост `localhost`, порт и учётка — как в `.env` (`POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`).

Через контейнер (имя из `POSTGRES_CONTAINER_NAME` в `.env`, по умолчанию `bdsnowflake-postgres`):

```bash
docker exec -it bdsnowflake-postgres psql -U bdsnowflake -d bdsnowflake
```

Проверка, что всё загрузилось:

```sql
SELECT COUNT(*) FROM stage.mock_data;  -- 10000
SELECT COUNT(*) FROM dw.fact_sales;    -- 10000
```

Если нужно пересоздать базу с нуля (скрипты из `sql/` выполняются только при первой инициализации тома):

```bash
docker compose down -v
docker compose up -d
```
