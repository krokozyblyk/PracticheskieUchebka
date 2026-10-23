# Учебный API (зоомагазин)

Запуск:

```
node mock-server.js --port 8080 --origin http://localhost:5555
```

Клиент должен работать на том же источнике, что указан в `--origin`:

```
cd ..
flutter run -d web-server --web-port=5555 --release
```

## Эндпоинты

Базовый адрес: `http://localhost:8080/api`

| Метод | Путь | Описание |
|---|---|---|
| GET | `/api/__health` | проверка доступности |
| POST | `/api/__reset` | сброс данных к начальным |
| GET | `/api/<collection>` | список с поиском, сортировкой и пагинацией |
| GET | `/api/<collection>/:id` | одна запись |
| POST | `/api/<collection>` | создание |
| PUT | `/api/<collection>/:id` | изменение |
| DELETE | `/api/<collection>/:id` | мягкое удаление |
| DELETE | `/api/<collection>/:id?hard=true` | физическое удаление |
| POST | `/api/<collection>/:id/restore` | восстановление |
| POST | `/api/<collection>/bulk-delete` | мягкое удаление списка `{ "ids": [1,2] }` |
| POST | `/api/<collection>/bulk-delete` с `{ "ids": [...], "hard": true }` | физическое удаление списка |
| POST | `/api/<collection>/bulk-restore` | восстановление списка |

`<collection>`: `animals`, `categories`, `suppliers`, `vets`, `customers`.

## Параметры списка

| Параметр | Описание |
|---|---|
| `search` | поиск по текстовым полям |
| `sort` | `поле,asc` или `поле,desc` |
| `page` | номер страницы, начиная с 1 |
| `size` | размер страницы (до 5000) |
| `includeDeleted` | `true` — вместе с удалёнными |
| `categoryId`, `supplierId`, `vetId`, `priceFrom`, `priceTo`, `sku` | фильтры животных |

Ответ списка:

```json
{
  "items": [],
  "page": 1,
  "size": 10,
  "total": 20,
  "totalPages": 2
}
```

## Коды ответов

| Код | Тело |
|---|---|
| 200 / 201 | запись или результат операции |
| 204 | удаление |
| 400 | `{ "message": "..." }` |
| 404 | `{ "message": "..." }` |
| 409 | `{ "message": "..." }` — связанные записи |
| 422 | `{ "message": "Ошибка валидации", "errors": { "поле": "текст" } }` |

## Проверки сбоев

- `?__delay=1500` — задержка ответа;
- `?__fail=500` — ответ с указанным кодом ошибки;
- остановка сервера — состояние сетевой ошибки на клиенте.
