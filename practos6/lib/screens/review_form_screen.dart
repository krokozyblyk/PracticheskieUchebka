import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/review.dart';
import '../repositories/animal_repository.dart';
import '../repositories/review_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';
import '../widgets/entity_form.dart';

class ReviewFormScreen extends StatefulWidget {
  final int? id;

  const ReviewFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();
  Review? _review;
  List<Animal> _animals = const [];
  bool _loading = true;
  bool _notFound = false;
  Map<String, String> _serverErrors = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final animalRepository = context.read<AnimalRepository>();
    final reviewRepository = context.read<ReviewRepository>();
    final animals = await animalRepository.find(const AnimalQuery(size: 1000));
    Review? review;
    if (widget.id != null) {
      review = await reviewRepository.findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _animals = animals.items;
      _review = review;
      _notFound = widget.id != null && review == null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() => _serverErrors = const {});
    if (!form.validate()) return;
    final review = Review(
      id: _review?.id ?? 0,
      userId: _review?.userId ?? 0,
      animalId: form.dropdownValue<int>('animalId') ?? 0,
      rating: form.dropdownValue<int>('rating') ?? 5,
      text: form.textValue('text'),
    );
    final repository = context.read<ReviewRepository>();
    final notifier = context.read<EntityListNotifier<Review>>();
    try {
      if (widget.isEditing) {
        await repository.update(review);
      } else {
        await repository.create(review);
      }
    } on ValidationException catch (error) {
      setState(() => _serverErrors = error.errors);
      form.revalidate();
      return;
    } on ApiException catch (error) {
      if (mounted) showApiError(context, error);
      return;
    }
    await notifier.load();
    if (!mounted) return;
    _close();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/reviews');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? 'Редактирование отзыва' : 'Новый отзыв',
      currentPath: '/reviews',
      showNavigation: false,
      leading: IconButton(
        tooltip: 'Назад',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _formKey.currentState?.requestExit(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notFound) {
      return const Center(child: Text('Отзыв не найден'));
    }
    final review = _review;
    return EntityForm(
      key: _formKey,
      fields: [
        DropdownFieldSpec<int>(
          key: 'animalId',
          label: 'Животное',
          initialValue: review?.animalId,
          items: [
            for (final animal in _animals)
              DropdownMenuItem(value: animal.id, child: Text(animal.name)),
          ],
          validator: (value) => value == null ? 'Выберите животное' : null,
        ),
        DropdownFieldSpec<int>(
          key: 'rating',
          label: 'Оценка',
          initialValue: review?.rating ?? 5,
          items: [
            for (var rating = 1; rating <= 5; rating++)
              DropdownMenuItem(value: rating, child: Text('$rating из 5')),
          ],
        ),
        TextFieldSpec(
          key: 'text',
          label: 'Текст отзыва',
          initialValue: review?.text ?? '',
          maxLines: 4,
          maxLength: 1000,
        ),
      ],
      submitLabel: widget.isEditing ? 'Сохранить' : 'Отправить',
      onSubmit: _save,
      onCancel: _close,
      serverErrors: _serverErrors,
    );
  }
}
