import '../widgets/list_filter_bar.dart';

const categoryFilterSpecs = [
  ListFilterSpec(
    key: 'section',
    label: 'Раздел',
    options: [
      ListFilterOption('Аквариум', 'Аквариум'),
      ListFilterOption('Домашние', 'Домашние'),
      ListFilterOption('Мелкие', 'Мелкие'),
      ListFilterOption('Пернатые', 'Пернатые'),
      ListFilterOption('Экзотика', 'Экзотика'),
    ],
  ),
  ListFilterSpec(
    key: 'hasAnimals',
    label: 'Есть животные',
    options: [ListFilterOption('true', 'Да'), ListFilterOption('false', 'Нет')],
  ),
];

const supplierFilterSpecs = [
  ListFilterSpec(
    key: 'hasAnimals',
    label: 'Есть животные',
    options: [ListFilterOption('true', 'Да'), ListFilterOption('false', 'Нет')],
  ),
  ListFilterSpec(
    key: 'hasEmail',
    label: 'Есть e-mail',
    options: [ListFilterOption('true', 'Да'), ListFilterOption('false', 'Нет')],
  ),
  ListFilterSpec(
    key: 'hasPhone',
    label: 'Есть телефон',
    options: [ListFilterOption('true', 'Да'), ListFilterOption('false', 'Нет')],
  ),
];

const vetFilterSpecs = [
  ListFilterSpec(
    key: 'specializationCategoryId',
    label: 'Специализация (ID)',
    text: true,
  ),
  ListFilterSpec(
    key: 'hasAnimals',
    label: 'Есть животные',
    options: [ListFilterOption('true', 'Да'), ListFilterOption('false', 'Нет')],
  ),
];

const customerFilterSpecs = [
  ListFilterSpec(
    key: 'hasCard',
    label: 'Есть карта',
    options: [ListFilterOption('true', 'Да'), ListFilterOption('false', 'Нет')],
  ),
  ListFilterSpec(
    key: 'hasOrders',
    label: 'Есть заказы',
    options: [ListFilterOption('true', 'Да'), ListFilterOption('false', 'Нет')],
  ),
  ListFilterSpec(key: 'address', label: 'Адрес', text: true),
];

const orderFilterSpecs = [
  ListFilterSpec(
    key: 'status',
    label: 'Статус',
    options: [
      ListFilterOption('new', 'Новый'),
      ListFilterOption('paid', 'Оплачен'),
      ListFilterOption('cancelled', 'Отменён'),
    ],
  ),
  ListFilterSpec(key: 'customerId', label: 'ID покупателя', text: true),
  ListFilterSpec(key: 'animalId', label: 'ID животного', text: true),
];

const appointmentFilterSpecs = [
  ListFilterSpec(
    key: 'status',
    label: 'Статус',
    options: [
      ListFilterOption('planned', 'Запланирована'),
      ListFilterOption('done', 'Завершена'),
      ListFilterOption('cancelled', 'Отменена'),
    ],
  ),
  ListFilterSpec(key: 'vetId', label: 'ID ветеринара', text: true),
  ListFilterSpec(key: 'customerId', label: 'ID покупателя', text: true),
];

const reviewFilterSpecs = [
  ListFilterSpec(
    key: 'rating',
    label: 'Оценка',
    options: [
      ListFilterOption('5', '5 из 5'),
      ListFilterOption('4', '4 из 5'),
      ListFilterOption('3', '3 из 5'),
      ListFilterOption('2', '2 из 5'),
      ListFilterOption('1', '1 из 5'),
    ],
  ),
  ListFilterSpec(key: 'animalId', label: 'ID животного', text: true),
  ListFilterSpec(key: 'userId', label: 'ID пользователя', text: true),
];
