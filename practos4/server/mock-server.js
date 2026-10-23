'use strict';

const http = require('node:http');

const args = process.argv.slice(2);
function arg(name, fallback) {
  const i = args.indexOf('--' + name);
  return i !== -1 && args[i + 1] ? args[i + 1] : fallback;
}

const PORT = Number(arg('port', 8080));
const ORIGIN = arg('origin', '*');

const COLLECTIONS = ['animals', 'categories', 'suppliers', 'vets', 'customers'];

let db;

const nowIso = () => new Date().toISOString();

function push(collection, data) {
  db.seq[collection] = (db.seq[collection] || 0) + 1;
  const id = db.seq[collection];
  db[collection].push({ id, ...data, createdAt: nowIso(), deletedAt: null });
  return id;
}

function seed() {
  db = {
    seq: {},
    animals: [],
    categories: [],
    suppliers: [],
    vets: [],
    customers: [],
  };

  [
    ['Кошки', 'Домашние'],
    ['Собаки', 'Домашние'],
    ['Птицы', 'Пернатые'],
    ['Грызуны', 'Мелкие'],
    ['Рыбки', 'Аквариум'],
    ['Рептилии', 'Экзотика'],
    ['Кролики', 'Мелкие'],
    ['Амфибии', 'Экзотика'],
  ].forEach(([name, section]) => push('categories', { name, section }));

  [
    ['ЗооМир', 'Иван Кузьмин', '+7 900 111-22-33', 'sales@zoomir.ru'],
    ['Питомец+', 'Анна Лебедева', '+7 900 222-33-44', 'info@petsplus.ru'],
    ['АкваДом', 'Сергей Орлов', '+7 900 333-44-55', 'orders@akvadom.ru'],
    ['Хвостик', 'Татьяна Ежова', '+7 900 444-55-66', 'mail@hvostik.ru'],
  ].forEach(([name, contactPerson, phone, email]) =>
    push('suppliers', { name, contactPerson, phone, email }),
  );

  [
    ['Анна Петрова', 1, '+7 910 100-10-01', 'a.petrova@vet.ru'],
    ['Игорь Соколов', 2, '+7 910 100-10-02', 'i.sokolov@vet.ru'],
    ['Мария Волкова', 3, '+7 910 100-10-03', 'm.volkova@vet.ru'],
    ['Ольга Смирнова', 4, '+7 910 100-10-04', 'o.smirnova@vet.ru'],
    ['Павел Кузнецов', 5, '+7 910 100-10-05', 'p.kuznetsov@vet.ru'],
    ['Елена Морозова', 6, '+7 910 100-10-06', 'e.morozova@vet.ru'],
  ].forEach(([fullName, specializationCategoryId, phone, email]) =>
    push('vets', { fullName, specializationCategoryId, phone, email }),
  );

  [
    ['Барсик', 'Кот', 'AN-001', 2, 5000, 1, [1], [1], 4],
    ['Мурка', 'Кошка', 'AN-002', 3, 4500, 2, [1], [1], 2],
    ['Рекс', 'Собака', 'AN-003', 1, 12000, 1, [2], [2], 3],
    ['Бобик', 'Собака', 'AN-004', 4, 8000, 3, [2], [2], 1],
    ['Кеша', 'Попугай', 'AN-005', 1, 2500, 4, [3], [3], 6],
    ['Гоша', 'Попугай', 'AN-006', 2, 3000, 4, [3], [3], 5],
    ['Шарик', 'Хомяк', 'AN-007', 1, 500, 2, [4], [4], 10],
    ['Пушок', 'Кролик', 'AN-008', 1, 1500, 3, [4], [4], 7],
    ['Немо', 'Рыба', 'AN-009', 1, 300, 3, [5], [5], 20],
    ['Дори', 'Рыба', 'AN-010', 1, 350, 3, [5], [5], 18],
    ['Тоша', 'Черепаха', 'AN-011', 5, 2000, 1, [6], [6], 2],
    ['Кузя', 'Ящерица', 'AN-012', 2, 3500, 4, [6], [6], 3],
    ['Снежок', 'Кошка', 'AN-013', 1, 5500, 2, [1], [1], 4],
    ['Граф', 'Собака', 'AN-014', 3, 15000, 1, [2], [2], 2],
    ['Чип', 'Морская свинка', 'AN-015', 1, 1200, 2, [4], [4], 9],
    ['Дейл', 'Морская свинка', 'AN-016', 1, 1200, 2, [4], [4], 8],
    ['Ара', 'Попугай', 'AN-017', 4, 8000, 4, [3], [3], 1],
    ['Злата', 'Рыба', 'AN-018', 1, 600, 3, [5], [5], 12],
    ['Барон', 'Хомяк', 'AN-019', 2, 450, 1, [4], [4], 11],
    ['Лаки', 'Собака', 'AN-020', 2, 11000, 2, [2], [2], 3],
  ].forEach(
    ([name, species, sku, age, price, supplierId, categoryIds, vetIds, quantity]) =>
      push('animals', {
        name,
        species,
        sku,
        age,
        price,
        supplierId,
        categoryIds,
        vetIds,
        quantity,
        description: '',
      }),
  );

  push('customers', {
    fullName: 'Дмитрий Злобин',
    email: 'zlobin@example.com',
    phone: '+7 915 000-11-22',
    address: 'г. Москва, ул. Лесная, 10',
    loyaltyCard: {
      cardNumber: 'LC-1001',
      issuedAt: new Date(Date.UTC(2025, 2, 12)).toISOString(),
      discountPercent: 5,
      active: true,
    },
  });
  push('customers', {
    fullName: 'Мария Иванова',
    email: 'ivanova@example.com',
    phone: '+7 915 000-33-44',
    address: 'г. Москва, ул. Полевая, 4',
    loyaltyCard: {
      cardNumber: 'LC-1002',
      issuedAt: new Date(Date.UTC(2024, 10, 2)).toISOString(),
      discountPercent: 10,
      active: true,
    },
  });
  push('customers', {
    fullName: 'Алексей Смирнов',
    email: 'smirnov@example.com',
    phone: '+7 915 000-55-66',
    address: 'г. Подольск, ул. Садовая, 8',
    loyaltyCard: null,
  });
}

function slim(list, id, field) {
  const item = list.find((x) => x.id === Number(id));
  return item ? { id: item.id, [field]: item[field] } : null;
}

function expand(collection, row) {
  if (collection === 'animals') {
    return {
      ...row,
      supplier: slim(db.suppliers, row.supplierId, 'name'),
      categories: row.categoryIds
        .map((id) => slim(db.categories, id, 'name'))
        .filter(Boolean),
      vets: row.vetIds.map((id) => slim(db.vets, id, 'fullName')).filter(Boolean),
    };
  }
  if (collection === 'vets') {
    return {
      ...row,
      specialization: slim(
        db.categories,
        row.specializationCategoryId,
        'name',
      ),
    };
  }
  return row;
}

function searchable(collection, item) {
  switch (collection) {
    case 'animals':
      return [item.name, item.species, item.sku, item.description].join(' ');
    case 'categories':
      return [item.name, item.section].join(' ');
    case 'suppliers':
      return [item.name, item.contactPerson, item.phone, item.email].join(' ');
    case 'vets':
      return [item.fullName, item.phone, item.email].join(' ');
    case 'customers':
      return [item.fullName, item.email, item.phone, item.address].join(' ');
    default:
      return '';
  }
}

function sortValue(collection, item, field) {
  if (collection === 'animals') {
    if (field === 'sku') return item.sku;
    if (field === 'species') return item.species;
    if (field === 'age') return item.age;
    if (field === 'price') return item.price;
    if (field === 'quantity') return item.quantity;
    return item.name;
  }
  if (collection === 'categories') {
    return field === 'section' ? item.section : item.name;
  }
  if (collection === 'suppliers') {
    return field === 'contactPerson' ? item.contactPerson : item.name;
  }
  if (collection === 'vets') return item.fullName;
  if (collection === 'customers') return item.fullName;
  return '';
}

function applyFilters(collection, rows, q) {
  let result = rows;
  if (q.search) {
    const needle = String(q.search).trim().toLowerCase();
    result = result.filter((x) =>
      searchable(collection, x).toLowerCase().includes(needle),
    );
  }
  if (collection === 'animals') {
    if (q.categoryId) {
      result = result.filter((a) =>
        a.categoryIds.includes(Number(q.categoryId)),
      );
    }
    if (q.supplierId) {
      result = result.filter((a) => a.supplierId === Number(q.supplierId));
    }
    if (q.vetId) {
      result = result.filter((a) => a.vetIds.includes(Number(q.vetId)));
    }
    if (q.priceFrom) {
      result = result.filter((a) => a.price >= Number(q.priceFrom));
    }
    if (q.priceTo) {
      result = result.filter((a) => a.price <= Number(q.priceTo));
    }
    if (q.sku) {
      const needle = String(q.sku).trim().toLowerCase();
      result = result.filter((a) => a.sku.toLowerCase() === needle);
    }
  }
  return result;
}

function applySort(collection, rows, sort) {
  const [field, dirRaw] = String(sort || '').split(',');
  const dir = String(dirRaw || 'asc').toLowerCase() === 'desc' ? -1 : 1;
  return [...rows].sort((a, b) => {
    const av = sortValue(collection, a, field);
    const bv = sortValue(collection, b, field);
    if (typeof av === 'number' && typeof bv === 'number') {
      return (av - bv) * dir;
    }
    return String(av).localeCompare(String(bv), 'ru') * dir;
  });
}

function paginate(rows, q) {
  const page = Math.max(1, Number(q.page) || 1);
  const size = Math.min(5000, Math.max(1, Number(q.size) || 10));
  const total = rows.length;
  return {
    items: rows.slice((page - 1) * size, page * size),
    page,
    size,
    total,
    totalPages: Math.max(1, Math.ceil(total / size)),
  };
}

const strOf = (v) => (v == null ? '' : String(v).trim());
const numOf = (v) => (v == null || v === '' ? null : Number(v));
const intOf = (v) => {
  const n = numOf(v);
  return n != null && Number.isInteger(n) ? n : null;
};
const idsOf = (v) =>
  Array.isArray(v) ? v.map(Number).filter((n) => Number.isInteger(n)) : [];

function validate(collection, body, id = null) {
  const errors = {};
  const str = strOf;

  if (collection === 'animals') {
    if (!str(body.name)) errors.name = 'Обязательное поле';
    else if (str(body.name).length < 2 || str(body.name).length > 40) {
      errors.name = 'Длина от 2 до 40 символов';
    }

    const sku = str(body.sku);
    if (!sku) errors.sku = 'Обязательное поле';
    else if (!/^[A-Za-z0-9-]{3,20}$/.test(sku)) {
      errors.sku = 'Артикул: 3–20 символов, латиница, цифры и дефис';
    } else if (
      db.animals.some(
        (a) => a.sku.toLowerCase() === sku.toLowerCase() && a.id !== id && !a.deletedAt,
      )
    ) {
      errors.sku = 'Артикул уже используется';
    }

    if (!str(body.species)) errors.species = 'Обязательное поле';
    else if (str(body.species).length < 2 || str(body.species).length > 30) {
      errors.species = 'Длина от 2 до 30 символов';
    }

    const age = intOf(body.age);
    if (age == null) errors.age = 'Введите целое число';
    else if (age < 0 || age > 50) errors.age = 'Допустимо от 0 до 50';

    const price = numOf(body.price);
    if (price == null || Number.isNaN(price)) errors.price = 'Введите число';
    else if (price <= 0) errors.price = 'Цена должна быть больше нуля';
    else if (price > 1000000) errors.price = 'Слишком большая цена';

    const quantity = intOf(body.quantity);
    if (quantity == null) errors.quantity = 'Введите целое число';
    else if (quantity < 0) errors.quantity = 'Количество не может быть отрицательным';
    else if (quantity > 10000) errors.quantity = 'Слишком большое количество';

    const supplierId = intOf(body.supplierId);
    if (supplierId == null) errors.supplierId = 'Выберите поставщика';
    else if (!db.suppliers.some((s) => s.id === supplierId && !s.deletedAt)) {
      errors.supplierId = 'Поставщик не найден';
    }

    const categoryIds = idsOf(body.categoryIds);
    if (!categoryIds.length) errors.categoryIds = 'Выберите хотя бы одну категорию';
    else if (
      categoryIds.some(
        (cid) => !db.categories.some((c) => c.id === cid && !c.deletedAt),
      )
    ) {
      errors.categoryIds = 'Категория не найдена';
    }

    const vetIds = idsOf(body.vetIds);
    if (vetIds.some((vid) => !db.vets.some((v) => v.id === vid && !v.deletedAt))) {
      errors.vetIds = 'Ветеринар не найден';
    }

    if (str(body.description).length > 300) {
      errors.description = 'Максимум 300 символов';
    }
  }

  if (collection === 'categories') {
    if (!str(body.name)) errors.name = 'Обязательное поле';
    else if (str(body.name).length < 2 || str(body.name).length > 30) {
      errors.name = 'Длина от 2 до 30 символов';
    }
    if (!str(body.section)) errors.section = 'Обязательное поле';
    else if (str(body.section).length < 2 || str(body.section).length > 30) {
      errors.section = 'Длина от 2 до 30 символов';
    }
  }

  if (collection === 'suppliers') {
    if (!str(body.name)) errors.name = 'Обязательное поле';
    else if (str(body.name).length < 2 || str(body.name).length > 40) {
      errors.name = 'Длина от 2 до 40 символов';
    }

    if (!str(body.contactPerson)) errors.contactPerson = 'Обязательное поле';
    else if (
      str(body.contactPerson).length < 2 ||
      str(body.contactPerson).length > 60
    ) {
      errors.contactPerson = 'Длина от 2 до 60 символов';
    }

    if (!str(body.phone)) errors.phone = 'Обязательное поле';
    else {
      const digits = str(body.phone).replace(/\D/g, '');
      if (digits.length < 10 || digits.length > 12) {
        errors.phone = 'Неверный формат телефона';
      }
    }

    if (!str(body.email)) errors.email = 'Обязательное поле';
    else if (!/^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$/.test(str(body.email))) {
      errors.email = 'Неверный формат почты';
    }
  }

  if (collection === 'vets') {
    if (!str(body.fullName)) errors.fullName = 'Обязательное поле';
    else if (str(body.fullName).length < 3 || str(body.fullName).length > 60) {
      errors.fullName = 'Длина от 3 до 60 символов';
    }

    const categoryId = intOf(body.specializationCategoryId);
    if (categoryId == null) errors.specializationCategoryId = 'Выберите специализацию';
    else if (!db.categories.some((c) => c.id === categoryId && !c.deletedAt)) {
      errors.specializationCategoryId = 'Категория не найдена';
    }

    if (!str(body.phone)) errors.phone = 'Обязательное поле';
    else {
      const digits = str(body.phone).replace(/\D/g, '');
      if (digits.length < 10 || digits.length > 12) {
        errors.phone = 'Неверный формат телефона';
      }
    }

    if (!str(body.email)) errors.email = 'Обязательное поле';
    else if (!/^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$/.test(str(body.email))) {
      errors.email = 'Неверный формат почты';
    }
  }

  if (collection === 'customers') {
    if (!str(body.fullName)) errors.fullName = 'Обязательное поле';
    else if (str(body.fullName).length < 3 || str(body.fullName).length > 60) {
      errors.fullName = 'Длина от 3 до 60 символов';
    }

    const email = str(body.email);
    if (!email) errors.email = 'Обязательное поле';
    else if (!/^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$/.test(email)) {
      errors.email = 'Неверный формат почты';
    } else if (
      db.customers.some(
        (c) =>
          c.email.toLowerCase() === email.toLowerCase() &&
          c.id !== id &&
          !c.deletedAt,
      )
    ) {
      errors.email = 'Этот адрес почты уже используется';
    }

    if (!str(body.phone)) errors.phone = 'Обязательное поле';
    else {
      const digits = str(body.phone).replace(/\D/g, '');
      if (digits.length < 10 || digits.length > 12) {
        errors.phone = 'Неверный формат телефона';
      }
    }

    if (str(body.address).length > 100) errors.address = 'Максимум 100 символов';

    const card = body.loyaltyCard;
    if (card != null && typeof card === 'object') {
      const number = str(card.cardNumber);
      if (!number) errors.cardNumber = 'Обязательное поле';
      else if (!/^[A-Za-z0-9-]{4,20}$/.test(number)) {
        errors.cardNumber = 'Номер карты: 4–20 символов, латиница, цифры и дефис';
      }

      if (!str(card.issuedAt) || Number.isNaN(Date.parse(card.issuedAt))) {
        errors.issuedAt = 'Формат даты: ГГГГ-ММ-ДД';
      }

      const discount = intOf(card.discountPercent);
      if (discount == null) errors.discountPercent = 'Введите целое число';
      else if (discount < 0 || discount > 100) errors.discountPercent = 'Скидка от 0 до 100%';
    }
  }

  return errors;
}

function normalize(collection, body) {
  const str = strOf;
  const num = numOf;
  if (collection === 'animals') {
    return {
      name: str(body.name),
      species: str(body.species),
      sku: str(body.sku).toUpperCase(),
      age: intOf(body.age) ?? 0,
      price: num(body.price) ?? 0,
      supplierId: intOf(body.supplierId) ?? 0,
      categoryIds: idsOf(body.categoryIds),
      vetIds: idsOf(body.vetIds),
      quantity: intOf(body.quantity) ?? 0,
      description: str(body.description),
    };
  }
  if (collection === 'categories') {
    return { name: str(body.name), section: str(body.section) };
  }
  if (collection === 'suppliers') {
    return {
      name: str(body.name),
      contactPerson: str(body.contactPerson),
      phone: str(body.phone),
      email: str(body.email),
    };
  }
  if (collection === 'vets') {
    return {
      fullName: str(body.fullName),
      specializationCategoryId: intOf(body.specializationCategoryId) ?? 0,
      phone: str(body.phone),
      email: str(body.email),
    };
  }
  if (collection === 'customers') {
    const card = body.loyaltyCard;
    return {
      fullName: str(body.fullName),
      email: str(body.email),
      phone: str(body.phone),
      address: str(body.address),
      loyaltyCard:
        card == null || typeof card !== 'object'
          ? null
          : {
              cardNumber: str(card.cardNumber),
              issuedAt: new Date(card.issuedAt).toISOString(),
              discountPercent: intOf(card.discountPercent) ?? 0,
              active: card.active !== false,
            },
    };
  }
  return { ...body };
}

function linkedCount(collection, id) {
  if (collection === 'categories') {
    const animals = db.animals.filter(
      (a) => !a.deletedAt && a.categoryIds.includes(id),
    ).length;
    const vets = db.vets.filter(
      (v) => !v.deletedAt && v.specializationCategoryId === id,
    ).length;
    return animals + vets;
  }
  if (collection === 'suppliers') {
    return db.animals.filter((a) => !a.deletedAt && a.supplierId === id).length;
  }
  if (collection === 'vets') {
    return db.animals.filter((a) => !a.deletedAt && a.vetIds.includes(id)).length;
  }
  return 0;
}

function conflictMessage(collection, count) {
  const name = {
    categories: 'категорию',
    suppliers: 'поставщика',
    vets: 'ветеринара',
  }[collection];
  return `Нельзя удалить ${name}: связанных записей — ${count}`;
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  if (!chunks.length) return {};
  try {
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    return null;
  }
}

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', ORIGIN);
  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  );
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Max-Age', '86400');
  res.setHeader('Vary', 'Origin');
}

function send(res, status, payload) {
  cors(res);
  if (payload === undefined || status === 204) {
    res.writeHead(204);
    res.end();
    return;
  }
  const body = JSON.stringify(payload, null, 2);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function fail(res, status, message) {
  send(res, status, { message });
}

async function handle(req, res, url) {
  const q = Object.fromEntries(url.searchParams.entries());
  const path = url.pathname.replace(/\/+$/, '') || '/';
  const method = req.method.toUpperCase();

  if (q.__fail) {
    return fail(res, Number(q.__fail), 'Ошибка вызвана параметром __fail');
  }

  if (path === '/api/__health' && method === 'GET') {
    return send(res, 200, { status: 'ok', time: nowIso() });
  }

  if (path === '/api/__reset' && method === 'POST') {
    seed();
    return send(res, 200, { message: 'Данные восстановлены' });
  }

  const bulkDelete = path.match(/^\/api\/([a-z]+)\/bulk-delete$/);
  if (bulkDelete && method === 'POST') {
    const collection = bulkDelete[1];
    if (!COLLECTIONS.includes(collection)) return fail(res, 404, 'Раздел не найден');

    const body = await readBody(req);
    if (body === null) return fail(res, 400, 'Тело запроса не является корректным JSON');
    const ids = idsOf(body.ids);
    if (!ids.length) {
      return send(res, 422, {
        message: 'Ошибка валидации',
        errors: { ids: 'Передайте список идентификаторов' },
      });
    }

    if (body.hard === true) {
      for (const id of ids) {
        const count = linkedCount(collection, id);
        if (count > 0) return fail(res, 409, conflictMessage(collection, count));
      }
      const before = db[collection].length;
      db[collection] = db[collection].filter((x) => !ids.includes(x.id));
      return send(res, 200, { deleted: before - db[collection].length });
    }

    let deleted = 0;
    for (const row of db[collection]) {
      if (ids.includes(row.id) && !row.deletedAt) {
        row.deletedAt = nowIso();
        deleted += 1;
      }
    }
    return send(res, 200, { deleted });
  }

  const bulkRestore = path.match(/^\/api\/([a-z]+)\/bulk-restore$/);
  if (bulkRestore && method === 'POST') {
    const collection = bulkRestore[1];
    if (!COLLECTIONS.includes(collection)) return fail(res, 404, 'Раздел не найден');

    const body = await readBody(req);
    if (body === null) return fail(res, 400, 'Тело запроса не является корректным JSON');
    const ids = idsOf(body.ids);
    if (!ids.length) {
      return send(res, 422, {
        message: 'Ошибка валидации',
        errors: { ids: 'Передайте список идентификаторов' },
      });
    }

    let restored = 0;
    for (const row of db[collection]) {
      if (ids.includes(row.id) && row.deletedAt) {
        row.deletedAt = null;
        restored += 1;
      }
    }
    return send(res, 200, { restored });
  }

  const match = path.match(/^\/api\/([a-z]+)(?:\/(\d+))?(?:\/(restore))?$/);
  if (!match) return fail(res, 404, `Маршрут ${method} ${path} не найден`);

  const collection = match[1];
  const id = match[2] ? Number(match[2]) : null;
  const action = match[3] || null;

  if (!COLLECTIONS.includes(collection)) return fail(res, 404, 'Раздел не найден');

  if (action === 'restore' && method === 'POST') {
    const row = db[collection].find((x) => x.id === id);
    if (!row) return fail(res, 404, 'Запись не найдена');
    row.deletedAt = null;
    return send(res, 200, expand(collection, row));
  }

  if (id === null && method === 'GET') {
    let rows = db[collection];
    if (q.includeDeleted !== 'true') rows = rows.filter((x) => !x.deletedAt);
    rows = applyFilters(collection, rows, q);
    rows = applySort(collection, rows, q.sort);
    const page = paginate(rows, q);
    return send(res, 200, {
      ...page,
      items: page.items.map((x) => expand(collection, x)),
    });
  }

  if (id !== null && method === 'GET') {
    const row = db[collection].find(
      (x) => x.id === id && (q.includeDeleted === 'true' || !x.deletedAt),
    );
    if (!row) return fail(res, 404, 'Запись не найдена');
    return send(res, 200, expand(collection, row));
  }

  if (id === null && method === 'POST') {
    const body = await readBody(req);
    if (body === null) return fail(res, 400, 'Тело запроса не является корректным JSON');

    const errors = validate(collection, body);
    if (Object.keys(errors).length) {
      return send(res, 422, { message: 'Ошибка валидации', errors });
    }

    const newId = push(collection, normalize(collection, body));
    const row = db[collection].find((x) => x.id === newId);
    return send(res, 201, expand(collection, row));
  }

  if (id !== null && (method === 'PUT' || method === 'PATCH')) {
    const row = db[collection].find((x) => x.id === id && !x.deletedAt);
    if (!row) return fail(res, 404, 'Запись не найдена');

    const body = await readBody(req);
    if (body === null) return fail(res, 400, 'Тело запроса не является корректным JSON');

    const merged = method === 'PATCH' ? { ...row, ...body } : body;
    const errors = validate(collection, merged, id);
    if (Object.keys(errors).length) {
      return send(res, 422, { message: 'Ошибка валидации', errors });
    }

    Object.assign(row, normalize(collection, merged));
    return send(res, 200, expand(collection, row));
  }

  if (id !== null && method === 'DELETE') {
    const index = db[collection].findIndex((x) => x.id === id);
    if (index === -1) return fail(res, 404, 'Запись не найдена');

    const count = linkedCount(collection, id);
    if (count > 0) return fail(res, 409, conflictMessage(collection, count));

    if (q.hard === 'true') {
      db[collection].splice(index, 1);
    } else {
      db[collection][index].deletedAt = nowIso();
    }
    return send(res, 204);
  }

  return fail(res, 404, `Маршрут ${method} ${path} не найден`);
}

seed();

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  if (req.method === 'OPTIONS') {
    cors(res);
    res.writeHead(204);
    return res.end();
  }

  const delay = Number(url.searchParams.get('__delay') || 0);
  if (delay > 0) await new Promise((r) => setTimeout(r, Math.min(delay, 10000)));

  const started = Date.now();
  try {
    await handle(req, res, url);
  } catch (error) {
    console.error(error);
    if (!res.headersSent) fail(res, 500, 'Внутренняя ошибка сервера: ' + error.message);
  }
  console.log(
    `${req.method} ${url.pathname}${url.search} -> ${res.statusCode} ${Date.now() - started}ms`,
  );
});

server.listen(PORT, () => {
  console.log(`mock API: http://localhost:${PORT}/api`);
  console.log(`allow origin: ${ORIGIN}`);
});
